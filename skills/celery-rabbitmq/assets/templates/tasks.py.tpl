"""Dispatch-by-type task + handler registry (the messagebus pattern).

One task consumes the envelope and routes to a handler by `type`. Adding a new
event = registering a handler, not declaring a new task. See
references/publish-consume.md.
"""
from celery.exceptions import Reject

from app.worker import app  # the Celery() instance from celery_app.py.tpl


# --- handlers ---------------------------------------------------------------
def handle_user_approved(payload: dict) -> None:
    ...


def handle_lesson_published(payload: dict) -> None:
    ...


HANDLERS = {
    "user.approved": handle_user_approved,
    "lesson.published": handle_lesson_published,
}


class TransientError(Exception):
    """Raise for retryable failures (network, locks, 5xx)."""


# --- idempotency guard (mandatory with acks_late) ---------------------------
def claim_event(idempotency_key: str) -> bool:
    """INSERT ... ON CONFLICT DO NOTHING. Return True only if newly claimed.

    Back this with a `processed_events(idempotency_key PRIMARY KEY, processed_at)`
    table. Run the handler only when this returns True so redelivery is a no-op.
    """
    raise NotImplementedError


# --- the single dispatch task ----------------------------------------------
@app.task(
    name="events.process",
    bind=True,
    acks_late=True,
    autoretry_for=(TransientError,),
    max_retries=5,
    retry_backoff=True,
    retry_backoff_max=600,
    retry_jitter=True,
)
def process_event(self, envelope: dict) -> None:
    handler = HANDLERS.get(envelope["type"])
    if handler is None:
        # unknown type: don't poison-loop — straight to the DLQ
        raise Reject(requeue=False)

    if not claim_event(envelope["idempotency_key"]):
        return  # already processed — redelivery no-op

    handler(envelope["payload"])
    # On unhandled errors after retries are spent, task_acks_on_failure_or_timeout=False
    # causes the worker to reject the delivery -> it dead-letters to `dead`.


# --- producing (broker stays invisible to callers) --------------------------
def emit(event_type: str, payload: dict, idempotency_key: str) -> None:
    app.send_task(
        "events.process",
        args=[{
            "type": event_type,
            "version": 1,
            "payload": payload,
            "idempotency_key": idempotency_key,
        }],
    )
