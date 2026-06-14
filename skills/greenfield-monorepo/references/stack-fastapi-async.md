# Pinned stack — Backend: FastAPI, async-first (pure Python)

Open when the user picks the **backend-app = FastAPI async** stack. One async FastAPI service as a
package inside the monorepo (`apps/backend-app/` or `services/api/`), Python only.

> Versions current 2026-06-14. App deps are pinned by **`uv.lock`** (committed); `pyproject.toml`
> carries loose floors (`>=`). Don't hard-pin `==` in `pyproject` for an app — let the lockfile do it.

## Decisions (defaults to scaffold)
- **Package/dep manager: `uv`** (one Rust binary: resolve + lock + venv + run + python-install; native
  `pyproject.toml`, fast `uv.lock`, workspace support for monorepos). Over poetry (slower) / pip-tools (glue).
- **Lint + format: `ruff` does both** — `ruff format` is the black-compatible formatter. **black is NOT
  needed** (nor isort/flake8); keeping black alongside ruff is redundant and they can fight.
- **Types: mypy `strict`** as the default gate (pyright is the strong alternative). `ty` (Astral) is fast
  but still **Beta / no plugin system** — don't make it the only gate; run it *alongside* mypy if at all.
- **Async-first**: `lifespan` (not deprecated `on_event`); SQLAlchemy 2.0 async + asyncpg;
  `pydantic-settings` + `@lru_cache` for config.
- **Tests**: pytest + pytest-asyncio (`asyncio_mode="auto"`) + `httpx.AsyncClient(ASGITransport(app))`.

## Version pins to emit
| Tool | Pin | Tool | Pin |
|---|---|---|---|
| Python | `>=3.12` (3.12/3.13) | ruff | `>=0.14.14` |
| fastapi | `>=0.137,<1` | pytest | `>=8.3` |
| pydantic | `>=2.13,<3` | pytest-asyncio | `>=0.24` |
| pydantic-settings | `>=2.7` | httpx | `>=0.28` |
| sqlalchemy | `>=2.0.46,<2.1` | mypy | `>=1.13` (strict) |
| asyncpg | `>=0.30` | uv | `>=0.11` |
| uvicorn`[standard]` | `>=0.34` | | |

## Structure (the tree to emit)
```
apps/backend-app/
├── pyproject.toml      uv.lock(committed)   .env.example(committed; .env gitignored)
├── Dockerfile          README.md
└── src/app/
    ├── main.py                 # FastAPI() + lifespan + include_router
    ├── core/{config.py, db.py} # pydantic-settings (cached) | async engine+sessionmaker+get_db
    ├── api/{deps.py, routers/{health.py, items.py}}
    ├── schemas/                # Pydantic DTOs (the wire contract)
    ├── models/                 # SQLAlchemy ORM (DeclarativeBase) — separate from schemas
    └── services/               # business logic; takes a session, NO fastapi imports
tests/{conftest.py, test_health.py}
```
Rules: `src/` layout (importable, no cwd imports); routers use `APIRouter(prefix=, tags=)` and `main.py`
only wires them; `deps.py` is the only place `Depends()` providers live; `services/` never import fastapi.

## Minimal files

`pyproject.toml`
```toml
[project]
name = "api"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
  "fastapi>=0.137,<1", "uvicorn[standard]>=0.34", "pydantic>=2.13,<3",
  "pydantic-settings>=2.7", "sqlalchemy>=2.0.46,<2.1", "asyncpg>=0.30",
]
[dependency-groups]
dev = ["ruff>=0.14.14", "mypy>=1.13", "pytest>=8.3", "pytest-asyncio>=0.24", "httpx>=0.28"]
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 88
target-version = "py312"
src = ["src", "tests"]
[tool.ruff.lint]
select = ["E", "W", "F", "I", "UP", "B", "SIM", "ASYNC"]  # ASYNC catches blocking-in-async
ignore = ["E501"]                                          # line length handled by the formatter
[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101"]
[tool.ruff.format]
quote-style = "double"
docstring-code-format = true
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
[tool.mypy]
python_version = "3.12"
strict = true
plugins = ["pydantic.mypy"]
```

`src/app/core/config.py`
```python
from functools import lru_cache
from pydantic import PostgresDsn
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")
    app_name: str = "api"
    debug: bool = False
    database_url: PostgresDsn

@lru_cache
def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]
```

`src/app/core/db.py`
```python
from collections.abc import AsyncIterator
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase
from app.core.config import get_settings

class Base(DeclarativeBase): pass

settings = get_settings()
engine = create_async_engine(str(settings.database_url), echo=settings.debug)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)  # mandatory for async

async def get_db() -> AsyncIterator[AsyncSession]:
    async with SessionLocal() as session:
        yield session

async def init_db() -> None:           # dev/seed hook — use Alembic for real migrations
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
```

`src/app/main.py` (lifespan, not on_event)
```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.api.routers import health, items
from app.core.db import engine, init_db

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield
    await engine.dispose()

app = FastAPI(title="api", lifespan=lifespan)
app.include_router(health.router)
app.include_router(items.router)
```

`src/app/api/routers/health.py` + items + tests
```python
# health.py
from fastapi import APIRouter
router = APIRouter(tags=["health"])

@router.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
```
```python
# tests/conftest.py
import pytest
from httpx import ASGITransport, AsyncClient
from app.main import app

@pytest.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c

# tests/test_health.py
async def test_health(client):
    resp = await client.get("/health")
    assert resp.status_code == 200 and resp.json() == {"status": "ok"}
```
Router DB dependency uses `Annotated`:
`DbSession = Annotated[AsyncSession, Depends(get_db)]`.

`Dockerfile` (multi-stage, non-root, uv)
```dockerfile
FROM python:3.13-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project --no-dev
COPY src/ ./src/
RUN uv sync --locked --no-dev

FROM python:3.13-slim AS runtime
RUN useradd --create-home --uid 1000 appuser
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app /app
ENV PATH="/app/.venv/bin:$PATH" PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
USER appuser
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

`.env.example` (committed; `.env` gitignored):
```dotenv
APP_NAME=api
DEBUG=false
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/app
SECRET_KEY=change-me-in-prod
```

Commands: `uv sync` · `uv run uvicorn app.main:app --reload --port 8000` · `uv run ruff check .` ·
`uv run ruff format .` · `uv run pytest` · CI: `uv sync --locked --all-extras --dev`.

## Gotchas (call these out)
- **Sync-in-async blocking**: a blocking call (`requests`, `time.sleep`, sync DB driver, heavy CPU) inside
  `async def` stalls the whole loop. Use async libs, or `await run_in_threadpool(...)` /
  `asyncio.to_thread(...)`. FastAPI auto-threadpools a plain `def` path op — so a blocking handler should be
  `def`, not `async def`. (`ruff` `ASYNC` rules catch many cases.)
- **DB URL must use the async dialect** `postgresql+asyncpg://` — plain `postgresql://` silently picks sync
  psycopg and breaks async.
- **`expire_on_commit=False`** is effectively mandatory with async (else attribute access after commit does IO).
- **Pydantic v2**: `.dict()`→`model_dump()`, `class Config`→`model_config = ConfigDict(...)`,
  `orm_mode`→`from_attributes`, `@validator`→`@field_validator`; `BaseSettings` is in `pydantic-settings`.
- **Settings caching**: wrap `Settings()` in `@lru_cache` (`get_settings`) and inject via `Depends`.
- **Tests don't run lifespan** under `ASGITransport` — wrap with `asgi-lifespan`'s `LifespanManager` if a
  test needs startup state.
- **One session per request**, never a module-level shared `AsyncSession`; share the engine + sessionmaker.

## SOURCES
context7: fastapi_tiangolo (lifespan, routers, settings/lru_cache, async/threadpool), pydantic-settings,
astral_sh_ruff (ruff format = black replacement), sqlalchemy_en_20 (async engine, expire_on_commit, dispose),
pytest-asyncio (asyncio_mode auto), python-httpx (ASGITransport + lifespan caveat), astral-sh/uv. Web:
pypi fastapi 0.137.0, sqlmodel release pins, mypy-vs-pyright-vs-ty comparisons. 2026-06-14.
