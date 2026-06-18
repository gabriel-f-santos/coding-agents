---
name: celery-rabbitmq
description: >-
  Implement reliable async task processing with Celery on a RabbitMQ broker —
  native retries, dead-letter queues (DLQ), publishing and consuming, with the
  broker kept as an implementation detail. Use when the user wants to "add Celery",
  "set up a task queue", "process events/jobs async", "configure RabbitMQ with Celery",
  "add retries", "set up a dead letter queue / DLQ", "handle failed tasks", "publish a
  message and consume it", "Celery beat / cron", or move fire-and-forget background work
  (asyncio.create_task, BackgroundTasks, threads) onto a durable broker. Covers the
  acks_late + acks_on_failure_or_timeout=False pattern that actually routes failures to
  the DLX, the dispatch-by-event-type handler pattern, producing tasks by name, and
  monitoring stuck messages. Not for Redis-only queues (arq/taskiq), raw pika/aio-pika
  without Celery, or Kafka.
license: MIT
metadata:
  category: backend-infra
  stack: python, celery, rabbitmq, amqp
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Celery + RabbitMQ — reliable tasks, retries, DLQ

Build async task processing where **Celery is the worker/dispatch layer** and **RabbitMQ
is the durable transport** — and the application code never speaks AMQP directly. Producers
call a task by name; consumers run handlers; failures retry and then land in a dead-letter
queue you can inspect and replay.

## Mental model — keep three layers separate

| Layer | Responsibility | Where it lives |
|---|---|---|
| **Transport** | durable delivery, exchanges, DLQ | RabbitMQ (broker URL + queue declarations) |
| **Worker** | pull, execute, retry, ack/reject | Celery worker process |
| **Dispatch** | "for this event type, call this function" | a `HANDLERS` dict inside one task |

The goal the user asked for — *"broker is a detail"* — is achieved by: callers use
`task.delay(...)` / `app.send_task("name", ...)` and never touch channels or exchanges;
all AMQP wiring (exchanges, routing keys, DLX) is declared **once** in the Celery config.

## The one thing everyone gets wrong (read this first)

**A DLQ does not fill up by default.** Two independent reasons:

1. Celery's default `acks_late=False` acks the message *on receipt*, before execution — a
   crash mid-task loses the message and nothing is dead-lettered.
2. Celery's **retry** (`autoretry_for` / `self.retry`) **re-publishes a new message** to the
   *same* queue. When retries are exhausted the task is marked FAILURE in the result backend,
   but the broker message was already acked — it is **never** routed to the dead-letter exchange.

To make RabbitMQ dead-letter a failed task you must let the broker *reject* the in-flight
delivery (`basic.reject` / `basic.nack` with `requeue=false`). The clean native way:

```python
task_acks_late = True                     # ack only AFTER the task returns
task_acks_on_failure_or_timeout = False   # on final failure -> REJECT (requeue=False) -> DLX
task_reject_on_worker_lost = True         # worker died -> reject -> DLX (don't silently drop)
```

Combine with a queue that declares `x-dead-letter-exchange`, and exhausted retries flow to the
DLQ automatically — no manual `Reject` needed. Full mechanics, plus the manual-`Reject` variant
for selective dead-lettering, are in `references/retry-and-dlq.md`.

## Workflow

1. **Ground the versions.** Check what's installed before writing config — `celery`, `kombu`,
   and the RabbitMQ server version each change available features (quorum queues, delivery-limit).
   Run `pip show celery kombu 2>/dev/null | grep -E 'Name|Version'` (or read the lockfile) and,
   for any uncertain API, pull current docs via context7 (`/websites/celeryq_dev_en_stable`).
   Match the project's existing style (config location, settings source, async vs sync DB).

2. **Declare the topology** — main exchange/queue with a `x-dead-letter-exchange`, plus the DLX
   and dead-letter queue. The terminal DLQ won't be created by listing it in `task_queues`
   (Celery only declares queues the worker *consumes*) — declare it explicitly at boot or
   dead-letters drop silently. → `references/retry-and-dlq.md` §topology and §terminal-DLQ
   gotcha. Start from `assets/templates/celery_app.py.tpl`.

3. **Wire reliability flags** — `acks_late`, `acks_on_failure_or_timeout=False`,
   `reject_on_worker_lost`, `prefetch_multiplier=1` for long tasks, and per-task
   `autoretry_for` / `max_retries` / `retry_backoff`. → `references/retry-and-dlq.md`.

4. **Write the dispatch task + handlers** — one `process_event` task that reads an envelope
   `{type, payload, idempotency_key}` and calls `HANDLERS[type]`. Make handlers **idempotent**
   (acks_late guarantees occasional double delivery). → `references/publish-consume.md` §dispatch.
   Start from `assets/templates/tasks.py.tpl`.

5. **Producing — keep the broker invisible.** Callers use `task.delay()` /
   `app.send_task("events.process", args=[envelope])` and `task_routes` maps the name to a
   queue. No queue/exchange in business code. → `references/publish-consume.md` §producing.

6. **Consuming & scheduling** — run the worker (`celery -A app.worker worker -Q main`), and
   if cron is needed add Celery **Beat as a single process** (never N replicas, or it
   double-fires). → `references/publish-consume.md` §consuming and §beat.

7. **Async app? mind the gotcha.** If the project is asyncio (asyncpg / SQLAlchemy async),
   Celery is sync — wrap handlers with `asyncio.run(...)` and build the async engine **per
   worker** in the `worker_process_init` signal with a NullPool (asyncpg does not survive the
   prefork). → `references/setup-ops.md` §async.

8. **Monitor & replay** — expose stuck-message counts from the RabbitMQ Management API
   (`GET /api/queues/%2F/<queue>` → `messages`); replay the DLQ with a shovel or a small
   republish task. → `references/setup-ops.md` §monitoring.

9. **Verify.** Send a task that always raises and confirm: it retries `max_retries` times, then
   the message appears in the **dead** queue (check the count). A green path that never
   dead-letters means the reliability flags are wrong — re-read §the-one-thing.

## References (open only what the step needs)

| Open when you need to… | Read |
|---|---|
| wire retries and make the DLQ actually fill | `references/retry-and-dlq.md` |
| publish by name, consume, dispatch-by-type, Beat cron | `references/publish-consume.md` |
| app/broker config, async-in-Celery, quorum queues, monitoring, DLQ replay | `references/setup-ops.md` |
| copy a working Celery app / tasks skeleton | `assets/templates/` |

## Guardrails

- **Never declare infra (the RabbitMQ host, security groups, credentials) ad hoc** if the
  project manages infra as code — add it there and keep broker secrets in the project's secret
  store, not in source. Restrict the AMQP (5672) and management (15672) ports to the app's
  network, never public.
- **Idempotency is mandatory** with `acks_late`. If a handler is not safe to run twice, add a
  processed-key guard (dedup table on `idempotency_key`) — see `references/publish-consume.md`.
- Don't put secrets or large blobs in the task payload; pass IDs and refetch.
- Don't block a DLQ forever: alert when `dead` queue depth crosses a threshold.
