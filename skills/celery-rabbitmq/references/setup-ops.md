# Setup, async integration & operations

App/broker config, the asyncio gotcha, durable queue choices, monitoring stuck messages, and
DLQ replay.

## §app — Celery app & broker config

```python
import os
from celery import Celery

app = Celery("myproj")
app.conf.update(
    broker_url=os.environ["BROKER_URL"],          # amqp://user:pass@host:5672/vhost
    result_backend=os.environ.get("RESULT_BACKEND"),  # optional; omit if you don't read results
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    broker_connection_retry_on_startup=True,      # reconnect if broker is briefly down at boot
    broker_transport_options={"confirm_publish": True},  # publisher confirms — don't lose on publish
    # reliability flags (see retry-and-dlq.md):
    task_acks_late=True,
    task_acks_on_failure_or_timeout=False,
    task_reject_on_worker_lost=True,
    worker_prefetch_multiplier=1,
)
app.autodiscover_tasks(["app"])
```

- **Never hardcode `broker_url`.** Read it from the environment / the project's secret store.
  The password is a secret — it does not belong in source or in logs.
- `confirm_publish: True` makes the producer wait for a broker ack — a publish won't silently
  vanish if the broker drops the connection mid-send.
- `result_backend` is optional. If you don't `.get()` results, omit it (RabbitMQ as a result
  backend is discouraged; use Redis/db if you need results). For fire-and-forget events you
  usually don't.

## §quorum — durable queue type (RabbitMQ ≥ 3.8)

Classic mirrored queues are deprecated. Prefer **quorum queues** for anything that must survive
a node failure — they replicate via Raft and have a built-in redelivery cap:

```python
Queue("main", Exchange("main"), routing_key="task", durable=True,
      queue_arguments={
          "x-queue-type": "quorum",
          "x-dead-letter-exchange": "dlx",
          "x-delivery-limit": 5,    # NATIVE: after 5 redeliveries -> dead-letter automatically
      })
```

`x-delivery-limit` is a clean native backstop: even without the acks flags, a message
redelivered 5× is dead-lettered instead of poison-looping. Quorum queues support DLX normally.
Note: quorum queues don't support per-message priority — if you need `x-max-priority`, stay on a
classic durable queue for that one.

## §async — Celery inside an asyncio app (asyncpg / SQLAlchemy async)

Celery workers are **synchronous**; an async stack needs a bridge. The trap: a module-level
async engine breaks because Celery's prefork pool forks workers and asyncpg connections /
event loops do not survive `fork()`.

Build the engine **per worker process**, lazily, and run handlers with `asyncio.run`:

```python
from celery.signals import worker_process_init, worker_process_shutdown
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from sqlalchemy.pool import NullPool

_engine = None
_Session = None

@worker_process_init.connect
def init_engine(**_):
    global _engine, _Session
    _engine = create_async_engine(os.environ["DATABASE_URL"], poolclass=NullPool)
    _Session = async_sessionmaker(_engine, expire_on_commit=False)

@worker_process_shutdown.connect
def close_engine(**_):
    if _engine:
        asyncio.run(_engine.dispose())

def run_async(coro):
    return asyncio.run(coro)   # fresh event loop per task; fine for prefork

@app.task(name="events.process", acks_late=True)
def process_event(envelope):
    return run_async(_handle_async(envelope))   # _handle_async uses _Session()
```

- `NullPool` — don't pool across the fork; open/close per task. For high throughput, consider
  `--pool=solo`/`threads` with a single loop, or evaluate an async-native runner — but that's a
  different tool, out of scope here.
- One `asyncio.run` per task creates a fresh loop each time. Simple and correct; if profiling
  shows it's hot, hold a long-lived loop per worker instead.

## §monitoring — count stuck messages (RabbitMQ Management API)

Enable the management plugin on the broker:

```bash
rabbitmq-plugins enable rabbitmq_management   # exposes HTTP API + UI on :15672
```

Query queue depth from your own admin (no Flower needed). `%2F` is the URL-encoded default
vhost `/`:

```
GET http://<broker>:15672/api/queues/%2F/dead   ->  JSON, field "messages" = stuck count
GET http://<broker>:15672/api/queues/%2F/main   ->  backlog on the main queue
```

```python
import httpx
async def queue_depths():
    auth = (os.environ["RABBIT_USER"], os.environ["RABBIT_PASS"])
    base = f"http://{os.environ['RABBIT_HOST']}:15672/api/queues/%2F"
    async with httpx.AsyncClient(auth=auth, timeout=5) as c:
        main = (await c.get(f"{base}/main")).json()
        dead = (await c.get(f"{base}/dead")).json()
    return {"main": main["messages"], "dead": dead["messages"]}
```

Expose this as an admin endpoint and **alert when `dead` > threshold**. Flower
(`celery -A app flower`) is an alternative dashboard for task-level visibility, but for "how
many are stuck" the Management API is the source of truth.

## §replay — reprocess the DLQ

Once you've fixed the bug, move dead-lettered messages back to the main exchange. Options:

1. **RabbitMQ Shovel** (operational, no code): configure a dynamic shovel from `dead` →
   `main` exchange; it drains the DLQ back. Good for one-off bulk replays.
2. **Small republish task**: consume `dead`, inspect each message's `x-death` header (why it
   failed, how many times), and `send_task("events.process", ...)` the payload back. Cap replays
   per message so a permanently-broken message doesn't loop.
3. **Manual UI**: the management UI can "move messages" between queues for tiny volumes.

Always look at `x-death` before replaying — if `count` is already high or `reason` is
`rejected` for a permanent error, fix the data/handler first; blind replay re-fills the DLQ.

## §ports & secrets (infra hygiene)

- AMQP `5672` and management `15672` must be reachable **only** from the app/worker network
  (security group / firewall) — never the public internet.
- Broker credentials live in the project's secret store; the worker reads `BROKER_URL` from the
  environment at boot.
- If the project manages infrastructure as code, declare the broker host, networking, and the
  credential there — don't create it by hand.
