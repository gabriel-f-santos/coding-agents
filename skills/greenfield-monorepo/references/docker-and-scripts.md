# Local dev orchestration — Docker Compose + seed + dev scripts

Open when wiring `task up/down/restart/seed`: the Compose file, idempotent seeding, and the
`scripts/dev_*.sh` the AGENTS.md references. Target: frontend + backend + Postgres (+ optional mobile).

> Pinned to the current **Compose Specification** (no `version:` key) + Compose CLI v2 (`docker compose`).
> Canonical filename `compose.yaml`. Pin image tags (`postgres:17-alpine`, not `:latest`).

## `infra/docker/compose.yaml` (base — long-running services only)
One-shot `migrate`/`seed` are **profile-gated** so they don't auto-run on every `up`.
```yaml
name: acme                         # deterministic prefix for containers/networks/volumes
services:
  db:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-app}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-app}
      POSTGRES_DB: ${POSTGRES_DB:-app}
    ports: ["${DB_PORT:-5432}:5432"]   # host-overridable to dodge clashes
    volumes: [db_data:/var/lib/postgresql/data]
    healthcheck:                        # $$ escapes literal $ for the container shell
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
      start_interval: 1s                # poll fast during start → "healthy" sooner
    networks: [backend]

  backend:
    build: { context: ../../apps/backend-app, dockerfile: Dockerfile }
    restart: unless-stopped
    env_file: [../../.env]
    environment:
      DATABASE_URL: postgresql+asyncpg://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD:-app}@db:5432/${POSTGRES_DB:-app}
    ports: ["${BACKEND_PORT:-8000}:8000"]
    depends_on:
      db: { condition: service_healthy }       # waits for the healthcheck, not just "running"
      migrate: { condition: service_completed_successfully, required: false }
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 20s
      start_interval: 2s
    develop:
      watch:
        - { path: ../../apps/backend-app/src, action: sync, target: /app/src }
        - { path: ../../apps/backend-app/pyproject.toml, action: rebuild }
    networks: [backend]

  frontend:
    build: { context: ../../apps/frontend-app, dockerfile: Dockerfile, target: dev }
    restart: unless-stopped
    environment: { VITE_API_URL: "http://localhost:${BACKEND_PORT:-8000}" }
    ports: ["${FRONTEND_PORT:-5173}:5173"]
    depends_on: { backend: { condition: service_started } }
    develop:
      watch:
        - { path: ../../apps/frontend-app/src, action: sync, target: /app/src }
        - { path: ../../apps/frontend-app/package.json, action: rebuild }
    networks: [frontend]

  migrate:                                       # one-shot, profile-gated
    build: { context: ../../apps/backend-app, dockerfile: Dockerfile }
    profiles: ["seed", "migrate"]
    env_file: [../../.env]
    environment: { DATABASE_URL: postgresql+asyncpg://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD:-app}@db:5432/${POSTGRES_DB:-app} }
    command: ["./scripts/migrate.sh"]            # idempotent: applies pending migrations
    depends_on: { db: { condition: service_healthy } }
    restart: "no"
    networks: [backend]

  seed:                                          # one-shot, profile-gated
    build: { context: ../../apps/backend-app, dockerfile: Dockerfile }
    profiles: ["seed"]
    env_file: [../../.env]
    environment: { DATABASE_URL: postgresql+asyncpg://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD:-app}@db:5432/${POSTGRES_DB:-app} }
    command: ["./scripts/seed.sh"]               # idempotent (UPSERT / guard flag)
    depends_on:
      db: { condition: service_healthy }
      migrate: { condition: service_completed_successfully }
    restart: "no"
    networks: [backend]

networks: { backend: {}, frontend: {} }
volumes: { db_data: {} }                         # survives `down`; wiped only by `down -v`
```
Add a `mobile` service behind `profiles: ["mobile"]` (Metro on `${METRO_PORT:-8081}`) only if mobile exists.
Adjust `build.context` paths to where the apps actually live.

## Seeding — must be idempotent
Postgres' `/docker-entrypoint-initdb.d` runs **only on first init of an empty volume** — fine for static
bootstrap, but won't re-run. Use the `seed` service for app-level seeding you control. Two valid patterns:
idempotent by construction (`INSERT ... ON CONFLICT DO NOTHING` / UPSERT, preferred), or a guard flag for
expensive one-time fixtures. Example `apps/backend-app/scripts/seed.sh`:
```sh
#!/usr/bin/env sh
set -eu
: "${DATABASE_URL:?DATABASE_URL is required}"
already() { psql "$DATABASE_URL" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='_seed_marker'" 2>/dev/null | grep -q 1; }
if already; then echo "seed: already applied — skipping"; exit 0; fi
psql "$DATABASE_URL" <<'SQL'
BEGIN;
INSERT INTO users (id, email, name)
VALUES ('00000000-0000-0000-0000-000000000001','dev@example.com','Dev User')
ON CONFLICT (id) DO NOTHING;
CREATE TABLE IF NOT EXISTS _seed_marker (applied_at timestamptz DEFAULT now());
INSERT INTO _seed_marker DEFAULT VALUES;
COMMIT;
SQL
echo "seed: done"
```
`migrate.sh` delegates to the app's migration tool (`alembic upgrade head` | `prisma migrate deploy` | …).

## `scripts/dev_*.sh` (referenced by AGENTS.md / task verbs)
Shebang choice: the user asked for `set -euo pipefail` — that's **bash**, not POSIX `sh`. Either use
`#!/usr/bin/env bash` + `set -euo pipefail`, or `#!/usr/bin/env sh` + `set -eu` (no `pipefail`). Be
consistent across all scripts. Each sources `_common.sh`, which resolves repo root, detects
`docker compose` (v2) vs `docker-compose` (v1), loads `.env`, and provides `print_urls` + `wait_healthy`.

`scripts/_common.sh` (sourced; not executed):
```sh
#!/usr/bin/env sh
set -eu
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd); cd "$ROOT_DIR"
if docker compose version >/dev/null 2>&1; then DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then DC="docker-compose"
else echo "error: docker compose not found" >&2; exit 127; fi
[ -f .env ] && . ./.env 2>/dev/null || true
FRONTEND_PORT="${FRONTEND_PORT:-5173}"; BACKEND_PORT="${BACKEND_PORT:-8000}"; DB_PORT="${DB_PORT:-5432}"
COMPOSE="-f infra/docker/compose.yaml"
print_urls() { printf '\n  Frontend : http://localhost:%s\n  Backend  : http://localhost:%s (/health)\n  Postgres : localhost:%s\n\n' "$FRONTEND_PORT" "$BACKEND_PORT" "$DB_PORT"; }
wait_healthy() {  # wait_healthy <svc> [tries]
  svc="$1"; tries="${2:-60}"; i=0; printf 'waiting for %s' "$svc"
  while [ "$i" -lt "$tries" ]; do
    cid=$($DC $COMPOSE ps -q "$svc" 2>/dev/null || true)
    if [ -n "$cid" ]; then
      st=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$cid" 2>/dev/null || echo "")
      case "$st" in healthy|running) echo " ok"; return 0;; unhealthy) echo " UNHEALTHY"; return 1;; esac
    fi
    i=$((i+1)); printf '.'; sleep 2
  done; echo " timeout"; return 1
}
```
- `dev_up.sh [--seed] [--mobile] [--build]` — `$DC $COMPOSE up -d`, `wait_healthy db`, `wait_healthy backend`,
  optional `$DC $COMPOSE --profile seed run --rm migrate && ... run --rm seed`, then `print_urls`.
- `dev_down.sh [-v]` — `$DC $COMPOSE --profile seed --profile mobile down --remove-orphans [--volumes]`;
  **confirm before `-v`** (it wipes the DB).
- `dev_restart.sh [--clean] [--seed] [--mobile]` — calls down (`-v` on `--clean`) then up (passing flags).
- `dev_seed.sh [--migrate-only]` — `$DC $COMPOSE --profile seed run --rm migrate` then `... run --rm seed`.
- `dev_logs.sh [svc ...]` — `$DC $COMPOSE logs -f --tail=100 "$@"`.
Each script has a `--help` usage block; `chmod +x scripts/*.sh` after writing.

## Gotchas (each bites real teams)
- **`depends_on` alone does NOT wait for readiness** — pair it with `condition: service_healthy` + a real
  healthcheck, or the backend races an un-ready Postgres and crashes on first connect.
- **One-shot seed/migrate can re-run on every `up`** (Compose #9260 with `service_completed_successfully`).
  Mitigate: profile-gate them, run explicitly via `run --rm`, and make seeding idempotent anyway.
- **Volume permissions**: don't bind-mount over `node_modules`/`.venv`; use named volumes for data dirs; run
  dev containers as your UID if needed.
- **Port clashes**: make every host port env-overridable (`"${DB_PORT:-5432}:5432"`).
- **Apple Silicon**: most official images are multi-arch — do NOT blanket-pin `platform: linux/amd64`
  (forces slow QEMU); add it only to a specific service whose image lacks arm64.
- **`down` keeps volumes; `down -v` wipes them** — make `-v` explicit + confirmed.
- **`watch` needs in-container hot-reload** (uvicorn `--reload`, Vite HMR); use `action: rebuild` for deps.

## SOURCES
Docker Docs: startup-order (depends_on conditions), profiles, compose-file services (obsolete `version:`);
Compose source via context7 (convergence.go, start_interval, watch); docker/compose#9260; oneuptime 2026
(watch, healthcheck, profiles, idempotent entrypoints, multi-arch). 2026-06-14.
