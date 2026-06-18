# Publishing, consuming & dispatch — broker as a detail

Goal: business code says "do this work" and never touches AMQP. All transport wiring lives in
the Celery config; callers and handlers stay broker-agnostic.

## §producing — keep the broker invisible

Three ways to enqueue, from most to least coupled:

```python
# 1. Direct call (producer imports the task) — simplest
process_event.delay(envelope)
process_event.apply_async(args=[envelope], countdown=10)   # delay 10s

# 2. By name (producer does NOT import the task) — best decoupling
app.send_task("events.process", args=[envelope])

# 3. Signature by name (for chains/groups/chords)
app.signature("events.process", args=[envelope]).apply_async()
```

Prefer **`send_task` by name** when the producer is a different service/module than the worker
— the producer needs only the Celery `app` (broker URL), not the task code. The queue is chosen
centrally, so callers never pass `queue=`/`routing_key=`:

```python
app.conf.task_routes = {
    "events.process": {"queue": "main"},
    "events.*":       {"queue": "main"},   # glob also works
}
```

Now `app.send_task("events.process", ...)` lands on `main` with the right routing key, and
swapping queues/exchanges is a config change — the producer is untouched. **That is what
"broker is a detail" means in practice.**

> Override per-call only for genuine exceptions:
> `process_event.apply_async(args=[e], queue="priority.high")`.

## §dispatch — one task, many handlers (the messagebus pattern)

Instead of one Celery task per event type, use **one** task that dispatches on `type`. Adding a
new event = registering a handler, not declaring a new task/route.

```python
# handlers.py
def handle_user_approved(payload): ...
def handle_lesson_published(payload): ...

HANDLERS = {
    "user.approved":    handle_user_approved,
    "lesson.published": handle_lesson_published,
}

# tasks.py
@app.task(name="events.process", bind=True, acks_late=True,
          autoretry_for=(TransientError,), max_retries=5, retry_backoff=True)
def process_event(self, envelope):
    handler = HANDLERS.get(envelope["type"])
    if handler is None:
        # unknown type: don't retry forever — dead-letter it
        from celery.exceptions import Reject
        raise Reject(requeue=False)
    handler(envelope["payload"])
```

Envelope shape (standardize it):

```json
{ "type": "user.approved", "version": 1, "payload": { "...": "..." }, "idempotency_key": "uuid" }
```

### Idempotency (mandatory with acks_late)

`acks_late=True` means a worker crash *after* doing the work but *before* acking causes
**redelivery** — the handler runs twice. Guard it:

```python
def process_once(idempotency_key) -> bool:
    # INSERT ... ON CONFLICT DO NOTHING; return True if the row was newly inserted.
    # Run the handler only when this returns True.
    ...
```

Keep a `processed_events(idempotency_key PRIMARY KEY, processed_at)` table, check-and-insert in
the same transaction as the side effect when possible. Without this, every retry/redelivery
risks duplicate emails, double charges, etc.

## §consuming — run the worker

```bash
# consume the main queue; tune concurrency to the workload
celery -A app.worker worker -Q main --concurrency=4 --loglevel=info

# long/IO-bound tasks: cap prefetch so one worker doesn't hoard unacked messages
celery -A app.worker worker -Q main --prefetch-multiplier=1
```

- `-Q main` — which queue(s) this worker pulls from. Do **not** consume the `dead` queue with a
  normal worker; it's for inspection/replay.
- Run workers as a managed service (systemd / container) with auto-restart. On the ASG model,
  workers can run on the app instances **or** on the broker box — just not Beat on more than one.
- Graceful shutdown: send `TERM`; the worker finishes in-flight tasks before exiting (warm
  shutdown). `acks_late` ensures anything unfinished is redelivered.

## §beat — scheduled / cron tasks

```python
from celery.schedules import crontab

app.conf.beat_schedule = {
    "daily-report": {
        "task": "events.process",
        "schedule": crontab(hour=6, minute=0),
        "args": [{"type": "report.daily", "version": 1, "payload": {}, "idempotency_key": "..."}],
    },
    "every-5-min-sync": {"task": "sync.run", "schedule": 300.0},  # seconds
}
```

```bash
celery -A app.worker beat --loglevel=info
```

> **Run exactly ONE Beat process.** Two schedulers = every cron fires twice. Do not put Beat in
> an autoscaling group with >1 replica. Options: a dedicated single instance (the broker box is
> a natural home), or a locking scheduler like `celery-redbeat` (Redis lock) / a leader-election
> sidecar if you must run it HA. Beat only *schedules*; the work still runs on normal workers.

## Verify producing/consuming end-to-end

1. Start a worker on `main`.
2. From a shell: `app.send_task("events.process", args=[{"type":"user.approved","payload":{...},"idempotency_key":"t1"}])`.
3. Confirm the handler ran (log/side effect) and the queue drained to 0.
4. Send the same `idempotency_key` again → handler must **not** repeat the side effect.
