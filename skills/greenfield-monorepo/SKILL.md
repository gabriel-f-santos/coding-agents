---
name: greenfield-monorepo
description: >
  Bootstrap a brand-new polyglot monorepo from zero — interview for the apps and stacks, then
  scaffold a runnable hello-world per app with current best-practice harness, lint, tests, pre-commit,
  Docker Compose dev stack with seed data, dev scripts (up/down/restart/seed), root + per-app AGENTS.md,
  and CI. Use when the user wants to "start a new project/monorepo", "scaffold a greenfield repo",
  "set up frontend + backend + mobile", "iniciar um projeto do zero", "criar o monorepo", "montar o
  esqueleto", "configurar lint/test/pre-commit/docker do projeto novo", or hands over an architecture.md
  to build from. Ships two pinned stacks (Vite+React→Cloudflare Workers, FastAPI async) and a generic
  research-and-scaffold path (context7/web) for any other stack (LangGraph, Go realtime, Flutter, …).
  Do not use to add a feature to an existing app, to write a single Dockerfile/CI file in isolation, or
  to design product/architecture from scratch (chain to product-brainstorming / tech-discovery for that).
# --- Claude Code-only (inert in Codex/opencode) ---
allowed-tools: Read Write Edit Bash Glob Grep Task AskUserQuestion
compatibility: >
  Generates files in the target repo. The generated dev loop needs docker + docker compose v2; per-app
  toolchains (node/uv/go/flutter) are needed to run that app. The skill itself only needs shell + the
  file tools. Live stack research uses context7 (MCP) and web when available.
metadata:
  author: skill-gen
  version: "1.0.0"
  grounded: "2026-06-14"
---

# greenfield-monorepo

Stand up a new polyglot monorepo: interview → plan → confirm → scaffold a runnable skeleton with the
harness, lint, tests, pre-commit, a Docker Compose dev stack (+ seed), dev scripts, and root + per-app
`AGENTS.md`. Two stacks are pinned and curated; any other stack is researched live and scaffolded.

## When to use
- "Start a new project / monorepo", "scaffold a greenfield repo", "iniciar um projeto do zero", "criar o
  monorepo", "montar o esqueleto hello-world", "configurar lint/test/pre-commit/docker do projeto novo".
- The user hands over an `architecture.md` (or describes the apps) and wants the repo built from it.

## When NOT to use
- Adding a feature/module to an **existing** app → no skill; just build it.
- Writing one isolated artifact (a single Dockerfile, one CI file) → do it directly.
- Validating a product idea or designing system boundaries from scratch → chain to `product-brainstorming`
  / `tech-discovery` first, then come back here to scaffold.

## Interaction
Be a thinking partner, not a form. Ask **one question at a time**, each with a **recommended default**
(mark it "(Recomendado)") and a one-line why tied to their context. Calibrate to expertise — educate a
less-experienced user with a brief analogy and fewer options; go straight to trade-offs with an expert.
Never make them choose blind. Use `AskUserQuestion` for the discrete forks. Prefer the user's language
(Portuguese if they write in Portuguese).

## Process

### 0. Detect ground truth (read before asking)
- Run `ls -la` and `git status` in the target dir. Confirm it's **empty / greenfield** — if it already has
  a project, STOP and confirm intent before writing anything (this skill assumes a fresh repo).
- Look for an existing `architecture.md` / `docs/architecture.md` (or ask if they have one). If present,
  read it and let it answer the interview — open `references/architecture.md`.
- Note what's installed (`docker compose version`, `node`, `uv`, `go`, `flutter`) so the plan flags
  missing toolchains instead of failing mid-build.

### 1. Interview (settle the shape)
Open `references/architecture.md` and resolve, one question at a time:
1. **Architecture** — consume their `architecture.md`, or ask the style (modular monolith / frontend+backend
   / microservices / event-driven). Recommend the simplest that fits. For non-trivial systems, offer to
   chain to `tech-discovery`. Generate `docs/architecture.md` from the answers if none exists.
2. **Which apps** — which of `frontend-app`, `backend-app`, `mobile`, extra `services/*` exist.
3. **Stack per app** — for each, pick the stack. Map to a reference:
   - frontend React SPA on Cloudflare Workers → `references/stack-react-cloudflare.md` (pinned)
   - backend FastAPI async → `references/stack-fastapi-async.md` (pinned)
   - anything else (LangGraph, Go realtime, Flutter, Node, …) → `references/stack-research-recipe.md`
     (research live via context7/web; chain to a technical skill when one fits).
4. **Conventions** — task runner (default go-task), pre-commit (default on), Conventional Commits hook
   (default optional/off — it's the highest-friction hook), CI (default GitHub Actions).

### 2. Resolve stacks → references
For each chosen app, open its stack reference. For pinned stacks, **re-verify the version pins** (the
references say how). For generic stacks, run the A.1–A.11 method in `stack-research-recipe.md` and capture
the concrete versions before planning. Assign each app a **distinct dev port** (keep a port table).

### 3. Plan → confirm (one gate)
Present the plan and get a single confirmation before writing. Use this skeleton:

```
## Monorepo plan — <name>
Architecture: <style>   (source: <their architecture.md | generated docs/architecture.md>)
Apps:
  - apps/frontend-app  — <stack>  (port <p>)
  - apps/backend-app   — <stack>  (port <p>)
  - <service/app>      — <stack>  (port <p>)
Shared: packages/proto (<contract format>)
Root: Taskfile.yml · AGENTS.md (+CLAUDE.md @import) · .editorconfig/.gitignore/.gitattributes/.tool-versions
      · .pre-commit-config.yaml · .github/workflows/ci.yml · infra/docker/compose.yaml · scripts/dev_*.sh
Dev loop: task up / down / restart / seed  (compose + idempotent seed)
Missing toolchains to install: <... or none>

File tree:
<the tree you will create>
```
Flag anything you could not verify as "(a confirmar)". Only proceed on explicit confirmation.

### 4. Build (scaffold everything)
Lay down, in this order — keep each app a self-contained package:
1. **Root**: `git init` (if needed); the layout + root config from `references/monorepo-and-agents.md`
   (`.editorconfig`, layered `.gitignore`, `.gitattributes`, `.tool-versions`, `README.md`, `LICENSE`,
   `CODEOWNERS`, `Taskfile.yml` with only the includes for apps that exist).
2. **AGENTS.md**: root from `assets/templates/AGENTS.root.md.tpl`; `CLAUDE.md` = one `@AGENTS.md` line;
   per-app from `assets/templates/AGENTS.app.md.tpl`. Each per-app file holds only its delta.
3. **Each app**: hello-world + a passing test, lint/format config, Dockerfile, `pyproject.toml`/`package.json`/
   etc., and a per-app `Taskfile.yml` (`install/lint/test/fmt/dev`). Use the exact snippets in the stack
   reference; don't invent versions.
4. **Dev loop**: `infra/docker/compose.yaml`, `apps/*/scripts/{migrate,seed}.sh`, and `scripts/_common.sh`
   + `dev_{up,down,restart,seed,logs}.sh` from `references/docker-and-scripts.md`; `chmod +x scripts/*.sh`.
5. **Harness**: `.pre-commit-config.yaml` + `.github/workflows/ci.yml` from `references/precommit-and-ci.md`
   — include only the language blocks/jobs for apps that exist; path-scope every hook and CI filter.
6. **`docs/architecture.md`** if you generated it (step 1).

### 5. Validate
- Run `python3 scripts/validate_scaffold.py <repo>` (structure + AGENTS.md + port-collision + script-exec checks).
- Best-effort smoke per available toolchain: `task <app>:install` then `task <app>:lint`/`test` (or the app's
  native commands). Run `pre-commit install && pre-commit run --all-files` if pre-commit is available.
- Report honestly what passed, what was skipped (missing toolchain), and what failed with the output.

### 6. Report
Summarize: the tree created, the dev-loop commands (`task up` / `dev_up.sh --seed`), per-app run commands,
any toolchains the user must install, validation results, and the obvious next steps (first feature, fill
the seed, set `compatibility_date`/secrets). Do not commit unless the user asks.

## Reference routing
| Open when you need to… | Read |
|---|---|
| lay out the repo, AGENTS.md (root+per-app), task runner, root config | `references/monorepo-and-agents.md` |
| scaffold the pinned frontend (Vite+React → Cloudflare Workers) | `references/stack-react-cloudflare.md` |
| scaffold the pinned backend (FastAPI async) | `references/stack-fastapi-async.md` |
| scaffold any other stack (research live; LangGraph/Go/Flutter seeds) | `references/stack-research-recipe.md` |
| settle the architecture, or consume the user's architecture.md | `references/architecture.md` |
| wire the Compose dev stack, seed, and dev_*.sh scripts | `references/docker-and-scripts.md` |
| wire pre-commit + CI (path-filtered, polyglot) | `references/precommit-and-ci.md` |

## Cross-cutting gotchas
- **Greenfield only** — never overwrite an existing project without explicit confirmation.
- **Pin real versions** — re-verify before emitting; never write a floating "latest" into a manifest.
- **One source of truth for agent context** — `AGENTS.md` canonical; `CLAUDE.md` is a thin `@AGENTS.md`.
- **Secrets never in chat or `vars`** — use `.dev.vars`/`wrangler secret`/`.env` (gitignored), `.env.example` committed.
- **Per-app everything** — own manifest, own `.gitignore` rules, own dev port (no collisions), own Taskfile.
- **Idempotent seed, profile-gated** — so it never wipes data or re-runs on every `up`.
- **Only scaffold what exists** — don't emit Go/Flutter/mobile blocks for apps the user didn't choose.

<!-- PORTABILITY: portable body — no load-time shell preprocessing, no skill-dir template variable;
bundled files are referenced by relative path. allowed-tools is Claude-only (inert elsewhere). Codex
sidecar in agents/openai.yaml; opencode/Codex setup in PORTABILITY.md. -->
