# Monorepo layout, AGENTS.md, and the task-runner vocabulary

Open when laying out the repo root: the directory tree, the root + per-app **AGENTS.md**, the
language-agnostic task runner, and the root config files. This is the spine every app slots into.

## Layout (apps + shared packages + tooling)
```
my-monorepo/
├── AGENTS.md                 # ROOT agent context (canonical source of truth)
├── CLAUDE.md                 # one line: `@AGENTS.md` (Claude-only; lets Claude users add notes)
├── README.md  LICENSE  CODEOWNERS
├── Taskfile.yml              # the single task entrypoint (see below)
├── .editorconfig  .gitignore  .gitattributes  .tool-versions
├── .pre-commit-config.yaml   # see references/precommit-and-ci.md
├── pnpm-workspace.yaml       # if any JS app exists (workspace + catalogs)
├── apps/
│   ├── frontend-app/  AGENTS.md  package.json  Taskfile.yml      # JS/TS
│   ├── backend-app/   AGENTS.md  pyproject.toml  Taskfile.yml    # Python
│   └── mobile/        AGENTS.md  pubspec.yaml  Taskfile.yml       # Dart/Flutter
├── services/                 # (optional) Go services: gateway/ with go.mod + AGENTS.md
├── packages/                 # shared, language-scoped sub-roots: ts/ py/ go/ proto/
├── infra/                    # IaC + docker/ (compose backs `task up`); has its own AGENTS.md
├── scripts/                  # cross-cutting helpers the task verbs call (seed.sh, dev_*.sh)
├── docs/                     # adr/ + README
└── .github/workflows/        # CI with path filtering
```
Keep each language's shared code under its own sub-root in `packages/` so single-language tooling
(pnpm, go modules, uv, pub) sees a clean root. `packages/proto` (protobuf/OpenAPI) is the **one**
sanctioned cross-language coupling point — editing it should regenerate clients (a task, not manual).

## AGENTS.md — the open standard
- `AGENTS.md` is an open, schema-less Markdown "README for agents", read natively by Codex, Cursor,
  opencode, Jules, Aider, Copilot, Zed, Gemini CLI and 20+ tools. **Claude Code reads `CLAUDE.md`** —
  the exception. Keep `AGENTS.md` canonical; make `CLAUDE.md` a single `@AGENTS.md` import (Claude expands
  `@path`; other agents won't, so keep nothing Claude-only in AGENTS.md itself). Symlink is the alternative
  (`ln -sf AGENTS.md CLAUDE.md`) but leaves no room for Claude-only notes.
- **Nearest-file-wins**: agents read the closest AGENTS.md up the tree. **Root = repo-wide rules; per-app =
  only the delta** (its commands, its quirks). Don't repeat the root in app files. An explicit user prompt
  overrides every AGENTS.md.
- Good sections (all optional): Project overview (langs + framework **with versions**), **Setup/build/test
  commands with full flags** (placed early), Dev environment, Code style (only deviations from defaults),
  Testing, Security (secrets, never-read files), PR/commit rules, Boundaries (Allowed / Ask-first / Never).
  Drop a "Project Structure" section when the layout follows framework conventions the agent already knows.
- **Surface the dev scripts as one task vocabulary** in the Dev section — `task up/down/restart/seed/lint/
  test/fmt` — not per-language commands leaking into the root file. Templates: `assets/templates/
  AGENTS.root.md.tpl` and `assets/templates/AGENTS.app.md.tpl`.

## Task runner — pick go-task (Taskfile)
**Recommend go-task (Taskfile v3.45+)** as the root orchestrator; `just` is the runner-up. **Avoid
Turborepo/Nx as the root** — they key off `package.json` and can't natively schedule Python/Go/Dart tasks
(layer Turborepo *inside* the JS subtree if wanted). Make works but is tab-sensitive. Taskfile gives
readable YAML, `includes:` with per-dir `dir:` (per-app composition), and one `task <verb>` UX; it fails
the parent task if any child fails → a single green/red gate for CI.

Minimal root `Taskfile.yml`:
```yaml
version: '3'
includes:
  fe:     { taskfile: ./apps/frontend-app, dir: ./apps/frontend-app }
  be:     { taskfile: ./apps/backend-app,  dir: ./apps/backend-app }
  mobile: { taskfile: ./apps/mobile,       dir: ./apps/mobile }
tasks:
  up:      { desc: Bring the dev stack up, cmds: ["docker compose -f infra/docker/compose.yaml up -d", { task: be:install }, { task: fe:install }] }
  down:    { desc: Tear it down,            cmds: ["docker compose -f infra/docker/compose.yaml down"] }
  restart: { desc: Restart,                 cmds: [{ task: down }, { task: up }] }
  seed:    { desc: Seed dev data,           cmds: ["./scripts/dev_seed.sh"] }
  lint:    { desc: Lint all,                cmds: [{ task: fe:lint }, { task: be:lint }, { task: mobile:lint }] }
  test:    { desc: Test all,                cmds: [{ task: fe:test }, { task: be:test }, { task: mobile:test }] }
  fmt:     { desc: Format all,              cmds: [{ task: fe:fmt }, { task: be:fmt }, { task: mobile:fmt }] }
```
Each per-app `Taskfile.yml` defines `install/lint/test/fmt/dev` in its own terms (`uv sync`, `ruff check`,
`pytest`; `pnpm install`, `eslint`, `vitest`; etc.) and the root never needs to know.
Only emit the includes/sub-tasks for apps that actually exist.

## Root config files
| File | Purpose |
|---|---|
| `.editorconfig` | one cross-language style anchor (indent/charset/EOL) |
| `.gitignore` | **layered**: root for repo-wide (`.env`, `*.log`, `.DS_Store`) + **per-app** for language noise (`node_modules/`, `.venv/`, `__pycache__/`, `.dart_tool/`, `build/`) |
| `.gitattributes` | `* text=auto eol=lf`; mark lockfiles `-diff` / `merge=binary`; `linguist-generated` for generated code |
| `.tool-versions` | mise/asdf pins for node/python/go/dart — the polyglot analogue of one lockfile; gate `task up` on `mise install` |
| `CODEOWNERS` | per-path reviewers (`/apps/backend-app/ @team`) — leverages the monorepo path structure |
| `README.md` `LICENSE` | human entrypoint + single SPDX license at root |

## Gotchas (polyglot monorepos)
- Monorepo tools (Turbo/Nx/Lerna) key off `package.json` — don't make a JS tool the root orchestrator.
- Dependency stores don't mix (`node_modules`/`.venv`/`pub-cache`/go cache) — per-app install + per-app ignore;
  `task up` calls each ecosystem's installer.
- **CI path filtering is mandatory** (see precommit-and-ci.md) or every push runs every language.
- Multiple lockfiles → mark `-diff`/`merge=binary` in `.gitattributes`, never hand-edit; use pnpm catalogs.
- Pin toolchains in `.tool-versions` or contributors drift across language versions.

## SOURCES
agents.md (spec, nesting, sections); Augment/Codersera/Morphllm AGENTS.md guides 2026; coding-with-ai.dev
(CLAUDE.md sync via @-import/symlink); Steve Kinney + DEV (Nx vs Turborepo JS-centric); taskfile.dev +
go-task releases (v3.45.3, includes-with-dir); pnpm 11 catalogs. 2026-06-14.
