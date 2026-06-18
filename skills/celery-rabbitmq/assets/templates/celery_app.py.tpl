"""Celery app + RabbitMQ topology with a working dead-letter queue.

Copy into your project (e.g. app/worker.py), adjust names/env vars, and read
references/retry-and-dlq.md for why each flag is here. Run:

    celery -A app.worker worker -Q main --concurrency=4 --loglevel=info
    celery -A app.worker beat   --loglevel=info          # ONE process only
"""
import os

from celery import Celery
from kombu import Exchange, Queue

# --- exchanges --------------------------------------------------------------
main_exchange = Exchange("main", type="direct", durable=True)
dlx_exchange = Exchange("dlx", type="direct", durable=True)

# --- queues -----------------------------------------------------------------
# main: rejected/failed messages dead-letter to the DLX -> `dead` queue.
task_queues = (
    Queue(
        "main",
        main_exchange,
        routing_key="task",
        durable=True,
        queue_arguments={
            "x-dead-letter-exchange": "dlx",
            "x-dead-letter-routing-key": "dead",
            # Prefer quorum queues for HA + native redelivery cap (RabbitMQ >= 3.8):
            # "x-queue-type": "quorum",
            # "x-delivery-limit": 5,
        },
    ),
    Queue("dead", dlx_exchange, routing_key="dead", durable=True),
)

app = Celery("myproj")
app.conf.update(
    broker_url=os.environ["BROKER_URL"],  # amqp://user:pass@host:5672/vhost  (from secret store)
    # result_backend=os.environ.get("RESULT_BACKEND"),  # only if you read task results
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    broker_connection_retry_on_startup=True,
    broker_transport_options={"confirm_publish": True},
    # topology
    task_queues=task_queues,
    task_default_queue="main",
    task_default_exchange="main",
    task_default_exchange_type="direct",
    task_default_routing_key="task",
    task_routes={"events.*": {"queue": "main"}},
    # reliability — these three make the DLQ actually fill (see retry-and-dlq.md):
    task_acks_late=True,
    task_acks_on_failure_or_timeout=False,
    task_reject_on_worker_lost=True,
    worker_prefetch_multiplier=1,
)

app.autodiscover_tasks(["app"])
