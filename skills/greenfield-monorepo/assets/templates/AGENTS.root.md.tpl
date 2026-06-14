# AGENTS.md — {{PROJECT_NAME}}

Polyglot monorepo. The closest AGENTS.md to the file you're editing wins; this root file holds
repo-wide rules only. Per-app rules live in `apps/*/AGENTS.md` (and `services/*/AGENTS.md`).

## Project overview
{{#APPS}}
- {{APP_NAME}} — {{STACK}} {{VERSIONS}}, in `{{PATH}}` (dev port {{PORT}})
{{/APPS}}
- Shared contracts in `packages/proto` ({{CONTRACT_FORMAT}}) — the only place these apps couple.
  Regenerate clients after editing it.
- Architecture: {{ARCH_STYLE}} — see `docs/architecture.md`.

## Dev environment (single vocabulary — always prefer `task <verb>`)
- Stack up:        `task up`        (or `./scripts/dev_up.sh --seed`)
- Stack down:      `task down`      (`./scripts/dev_down.sh -v` wipes the DB)
- Restart:         `task restart`
- Seed dev data:   `task seed`
- Lint all:        `task lint`
- Test all:        `task test`
- Format all:      `task fmt`
Toolchains are pinned in `.tool-versions` (mise/asdf): run `mise install` before first use.
Local dev needs docker + docker compose v2.

## Code style
- Only deviations from language defaults are listed in each app's AGENTS.md; `task fmt` is authoritative.
- Conventional Commits for all commit messages.

## Testing
- `task test` must pass before any PR. Single app: `task be:test` / `task fe:test` / `task mobile:test`.

## Security
- Never read or commit `.env*`, `*.pem`, `**/secrets*`, or `.dev.vars`. Secrets come from the secret
  manager / env, never hardcoded. `.env.example` documents the variables.

## PR / commit instructions
- Title: `<area>: <imperative summary>`. CI runs path-filtered per app — keep changes scoped to one app.

## Boundaries
- ✅ Allowed: edit app source, add tests, update that app's AGENTS.md.
- ⚠️ Ask first: touch `packages/proto`, `infra/`, or CI workflows.
- 🚫 Never: commit secrets, hand-edit lockfiles, force-push main.
