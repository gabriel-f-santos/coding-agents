# Retries & Dead-Letter Queues (DLQ) — the mechanics

This is the heart of the skill. Get the flags right or the DLQ stays empty and failures vanish.

## Why a DLQ is empty by default (recap)

1. **Default `acks_late=False`** → Celery acks the message the moment the worker receives it,
   *before* running it. A crash mid-execution = message gone, nothing dead-lettered.
2. **Celery retry republishes** → `autoretry_for` / `self.retry()` sends a *brand-new* message
   to the same queue with a countdown. When `max_retries` is hit the task is FAILURE in the
   result backend, but the broker delivery was already acked. The dead-letter exchange is
   **never** involved.

RabbitMQ only dead-letters a message when the consumer **rejects** it (`basic.reject` /
`basic.nack` with `requeue=false`) or it expires (TTL) or hits a length/delivery limit. So the
job is: make Celery reject the in-flight delivery on final failure.

## Topology — declare exchanges and queues

```python
from kombu import Exchange, Queue

main_exchange = Exchange("main", type="direct", durable=True)
dlx_exchange  = Exchange("dlx",  type="direct", durable=True)

task_queues = (
    Queue(
        "main",
        main_exchange,
        routing_key="task",
        durable=True,
        queue_arguments={
            "x-dead-letter-exchange": "dlx",          # where rejected msgs go
            "x-dead-letter-routing-key": "dead",      # routing key used in the DLX
            # optional native cap (quorum queues only) — see setup-ops.md §quorum:
            # "x-delivery-limit": 5,
        },
    ),
    Queue("dead", dlx_exchange, routing_key="dead", durable=True),
)

app.conf.task_queues = task_queues
app.conf.task_default_queue = "main"
app.conf.task_default_exchange = "main"
app.conf.task_default_exchange_type = "direct"
app.conf.task_default_routing_key = "task"
```

`durable=True` on both queues and exchanges (and persistent messages, which Celery uses by
default) lets messages survive a broker restart.

> A queue's `x-dead-letter-exchange` is **immutable after creation**. If you change DLX
> arguments later, RabbitMQ raises `PRECONDITION_FAILED` and the worker won't boot. You must
> delete and re-declare the queue (drain it first). Plan the arguments up front.

## Gotcha — the terminal DLQ is NOT declared automatically (dead-letters vanish)

Putting the DLQ in `task_queues` does **not** guarantee it exists on the broker. **Celery only
declares the queues the worker actually consumes** (the ones in `-Q ...`, or all of `task_queues`
if you pass none). The DLQ is *terminal* — nobody consumes it — and nothing is ever *published*
to it directly (RabbitMQ routes there via the DLX), so `task_create_missing_queues` never fires
for it either. Net result: **neither the `dead` queue nor the `dlx` exchange is created.**

The main queue then dead-letters into an exchange that doesn't exist, and RabbitMQ **drops those
messages silently**. The DLQ you "configured" retains nothing — and you only find out when you go
looking for a failed message that should be there.

**Fix — declare the dead-letter topology explicitly at worker boot, off the consume path.** A
Celery **bootstep** that requires the `Pool` runs on every worker startup; grab a connection and
declare the DLX + DLQ + binding in one idempotent call. Running on every boot means it survives a
broker-instance replacement (a one-off manual `declare` only survives a restart).

```python
from celery import bootsteps
from kombu import Exchange, Queue

dlx = Exchange("dlx", type="direct", durable=True)
dead = Queue("dead", dlx, routing_key="dead", durable=True)

class DeclareDLQ(bootsteps.StartStopStep):
    requires = {"celery.worker.components:Pool"}

    def start(self, worker):
        with worker.app.connection_for_write() as conn:
            # declares the exchange + queue + binding in one shot, idempotent,
            # without consuming the DLQ
            dead.bind(conn).declare()

app.steps["worker"].add(DeclareDLQ)
```

Alternatives: declare it in the broker's `definitions.json` / via `rabbitmqadmin` at broker boot
(good if you manage the broker as infra-as-code), or in a `worker_ready` signal. The bootstep is
the most portable — it travels with the app and needs no broker-side config.

## Pattern A (recommended) — native failure → DLX, no manual code

Let exhausted retries fail the task and let Celery reject the delivery:

```python
app.conf.update(
    task_acks_late=True,                     # ack AFTER execution
    task_acks_on_failure_or_timeout=False,   # KEY: on failure/timeout, REJECT (requeue=False) -> DLX
    task_reject_on_worker_lost=True,         # worker crash -> reject -> DLX (no silent loss)
    worker_prefetch_multiplier=1,            # for long tasks: don't hoard unacked messages
)

@app.task(
    bind=True,
    autoretry_for=(ConnectionError, TimeoutError),  # transient errors -> retry
    max_retries=5,
    retry_backoff=True,          # exponential: 1s, 2s, 4s, ...
    retry_backoff_max=600,
    retry_jitter=True,           # spread retries to avoid thundering herd
)
def process_event(self, envelope):
    handle(envelope)             # raises on failure
```

Flow: transient error → Celery retries up to 5×. Still failing → `MaxRetriesExceededError` is
raised → task fails → because `task_acks_on_failure_or_timeout=False` the worker **rejects**
the in-flight delivery with `requeue=False` → RabbitMQ routes it to `dlx` → it lands in `dead`.

`task_acks_on_failure_or_timeout` only has an effect when `task_acks_late=True` (it governs the
post-execution ack).

## Pattern B — explicit, selective dead-lettering

When you want to dead-letter *some* failures immediately (e.g. a permanent validation error)
and keep `task_acks_on_failure_or_timeout=True` for the rest, raise `Reject` yourself. Requires
`acks_late=True`:

```python
from celery.exceptions import Reject

@app.task(bind=True, acks_late=True, max_retries=3)
def process_event(self, envelope):
    try:
        handle(envelope)
    except PermanentError:
        # unprocessable — straight to DLQ, no retries
        raise Reject(requeue=False)
    except TransientError as exc:
        try:
            raise self.retry(exc=exc, countdown=2 ** self.request.retries)
        except self.MaxRetriesExceededError:
            # retries spent — dead-letter the current delivery
            raise Reject(requeue=False)
```

`raise Reject(requeue=False)` nacks the **current** delivery → DLX. `Reject(requeue=True)` would
put it back on the same queue (infinite-loop risk — avoid unless you have a delivery limit).

## Retry tuning cheatsheet

| Setting | Effect |
|---|---|
| `autoretry_for=(Exc, ...)` | auto-retry on these exception types |
| `max_retries=N` | attempts before giving up (then → DLX with the flags above) |
| `retry_backoff=True` | exponential delay between retries |
| `retry_backoff_max=600` | cap the delay (seconds) |
| `retry_jitter=True` | randomize delay (avoid synchronized retries) |
| `self.retry(exc=e, countdown=s)` | manual retry with explicit delay |
| `acks_late=True` | ack after execution (required for reject-on-failure) |

## Pattern C (advanced) — delayed retries via a retry queue

Celery's `self.retry(countdown=...)` holds the task in the worker, consuming a slot. For
*delayed* retries without occupying workers, use a **retry queue** with a per-message TTL whose
DLX points back at the main exchange:

```python
Queue("retry", Exchange("retry"), routing_key="task",
      queue_arguments={
          "x-message-ttl": 30000,                 # wait 30s
          "x-dead-letter-exchange": "main",       # then re-deliver to main
          "x-dead-letter-routing-key": "task",
      })
```

Reject the failed task into `retry`; after the TTL expires RabbitMQ dead-letters it back to
`main` for another attempt. Track attempt count in a message header (`x-death` array, populated
by RabbitMQ) and route to the real DLQ once it exceeds the limit. Only reach for this when
worker-held retries are too costly — it adds moving parts.

## Inspecting the DLQ

Each dead-lettered message carries an `x-death` header (count, reason: `rejected`/`expired`,
original queue, timestamps). Read it when replaying to decide what's retryable. Counting and
replaying stuck messages → `setup-ops.md` §monitoring.

## Verification checklist

- [ ] Confirm the `dead` queue and `dlx` exchange **exist on the broker before sending the first
      message** (Management UI / `rabbitmqadmin list queues exchanges`). If they're missing,
      dead-letters are dropped silently — see the terminal-DLQ gotcha above.
- [ ] Send a task that always raises `ValueError` (not in `autoretry_for`) → it should fail and
      land in `dead` immediately (1 message).
- [ ] Send a task that raises a retryable error forever → it retries `max_retries` times, then
      lands in `dead`.
- [ ] Kill the worker mid-task → message is redelivered (not lost), thanks to `acks_late` +
      `reject_on_worker_lost`.
- [ ] Change a queue's DLX argument and reboot → expect `PRECONDITION_FAILED` (proves the
      queue is durable/immutable); delete+redeclare to fix.
