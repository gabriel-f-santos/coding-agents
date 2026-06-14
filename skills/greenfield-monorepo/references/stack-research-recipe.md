# Generic path — research-and-scaffold an unknown stack

Open when the requested stack is **not** one of the two pinned ones (react-cloudflare, fastapi-async).
This is the method to derive current best practices live (context7/web) and scaffold, plus 3 seed recipes
to start from. **Re-verify versions live before emitting** — the seeds below age.

## A. Method — resolve these dimensions for ANY stack
Source-selection rule: **context7** (`resolve-library-id` → `query-docs`) for any library/framework/CLI
docs (init, config schema, idiomatic examples) — prefer it over web even for well-known libs, training
lags. **Official docs site** (WebFetch the canonical domain) for the recommended layout + exact min
runtime. **WebSearch** for "what's idiomatic in 2026", tie-breaks, latest release, and deprecations
(include the year). **Registry** (PyPI/npm/pkg.go.dev/pub.dev) for the exact version string.
> Pin discipline: never emit a floating "latest" — resolve the concrete version, then write it.

- **A.0 Project type & architecture (FIRST).** If *what* they're building is fuzzy → chain to
  **`product-brainstorming`**. Real architecture decisions (boundaries, data model, NFRs, threat model) →
  chain to **`tech-discovery`** (its brief drives stack + boundaries). LangGraph/agentic system → chain to
  **`langgraph-architect`** if present. See also `references/architecture.md`.
- **A.1 Init command** — the canonical "create project" (`flutter create`, `go mod init`, `langgraph new`, `cargo new`, …).
- **A.2 Idiomatic directory structure** — official "project layout" page first, then confirm it's current.
- **A.3 Dependency manager + manifest** — the tool + the file it owns.
- **A.4 Lint + format tool + a MINIMAL non-empty config** (config schema changes across majors).
- **A.5 Test framework + one passing hello test + the run command.**
- **A.6 Type checking** — separate checker or built into the compiler? what command surfaces it in CI.
- **A.7 Build / run** — dev-run + production-build commands.
- **A.8 Dockerfile shape** — multi-stage, right base/runtime, non-root; prefer distroless/slim/static.
- **A.9 Dev port** — the conventional default; **register it in the monorepo port table** so siblings don't collide.
- **A.10 Monorepo join + per-package `AGENTS.md`** — workspace (pnpm/cargo/pub/go work) or standalone behind a task target; the AGENTS.md covers stack+versions, install/run/test/lint, dev port, gotchas, pointer to root.
- **A.11 Gotchas** — major-version config breakage, archived/renamed libs, runtime min-version, concurrency/state footguns, monorepo bootstrap order.

| Situation | Chain to |
|---|---|
| Project type/goal unclear | `product-brainstorming` |
| Need architecture/boundaries/NFR/threat | `tech-discovery` |
| LangGraph/agentic design | `langgraph-architect` (if present) |
| Stack = one of the 2 pinned recipes | use the pinned reference directly |
| Stack unknown | run A.1–A.11 live, then scaffold |

After research, scaffold the same shape as the pinned stacks: hello-world + test, lint/format config,
Dockerfile, per-app `Taskfile.yml` (install/lint/test/fmt/dev), per-app `AGENTS.md`, dev port registered,
pre-commit + CI blocks added for the new language (see precommit-and-ci.md).

## B. Seed recipes (verify live before emitting)

### B.1 — AI/agents: LangGraph (Python AND Node/TS)
Pick **Python** (`langgraph` + uv/ruff/pytest) when the mesh is Python or you need the richest
checkpointer/store ecosystem; **Node/TS** (`@langchain/langgraph` + eslint/vitest) when the agent lives in
a JS/TS app or the team is TS-first. Graph API + `langgraph.json` are mirrored across both.
Versions (2026): `langgraph` 1.2.x, `langgraph-cli` 0.4.x, `@langchain/langgraph[-cli]` 1.2.x.
- Init: `langgraph new <path> --template <T>` (either lang), or manual (`uv add langgraph langchain` / `npm i @langchain/langgraph @langchain/core`).
- Structure: `src/agent/{graph,state}.py|ts` + `langgraph.json` (keys: `dependencies`, `graphs`
  `"name":"./path:graph"`, `env`, `python_version`, `dockerfile_lines`) + tests.
- Lint/format: ruff (py) / eslint flat + prettier (ts). Test: pytest / vitest — hello test invokes
  `graph.invoke({...})`. Build/run: `langgraph dev` (Studio + in-memory server, default port **2024**);
  `langgraph build`/`langgraph dockerfile` generate the image from `langgraph.json`.
- Gotchas: checkpointer choice (in-memory dev → Postgres/SQLite prod; agents are stateful); set
  `python_version` in langgraph.json or the image mismatches; the `./pkg/file:graph` path must resolve.

### B.2 — Go realtime / high-concurrency (multiplayer / sockets)
Versions (2026): Go 1.26.x; golangci-lint v2.12.x (module `.../v2`, config needs `version: "2"`).
- **WebSocket lib: `coder/websocket`** (ex-`nhooyr/websocket`) — context-aware, safe concurrent writes,
  maintained. **`gorilla/websocket` is archived** (keep only for legacy).
- Init: `go mod init github.com/org/<svc>`. Structure: `cmd/server/main.go` (wiring, flags, graceful
  shutdown) + `internal/{hub,ws,game}/` + `.golangci.yml` + Dockerfile. `cmd/`=entrypoints,
  `internal/`=non-importable impl; avoid `pkg/` unless truly exporting a lib.
- Lint/format: `gofmt`/`goimports` + golangci-lint v2 (`.golangci.yml` with `version: "2"`,
  enable errcheck/govet/staticcheck/ineffassign/unused/misspell). Test: `go test ./...` (table tests).
  Types: built into the compiler (`go build`/`go vet`). Build: `CGO_ENABLED=0 go build -o /bin/server ./cmd/server`.
- Dockerfile: multi-stage `golang:1.26` build → `gcr.io/distroless/static-debian12:nonroot` (tiny, non-root).
- **Graceful shutdown is mandatory for sockets**: `signal.NotifyContext` + `srv.Shutdown(ctx)` + close hub.
  Dev port **8080**. Gotchas: goroutine leaks (tie pump lifetimes to a `context.Context`); propagate ctx
  cancellation into game logic; bounded per-client send channels (backpressure — drop/disconnect slow clients).

### B.3 — Flutter multiplatform
Versions (2026): melos 7.x (pub workspaces; needs Dart SDK ≥3.6, 3.9+ recommended); very_good_analysis 10.x
(or lighter official `flutter_lints`).
- **Architecture: feature-first + layers** — per feature `data/` (repositories/services/DTOs) and `ui/`
  (MVVM: view + view-model). **Commit to ONE state-mgmt** (Riverpod = strong default; or Bloc; or
  provider) and state it in AGENTS.md — mixing them rots fast.
- Init: `flutter create <app>` (`--platforms` to scope). Structure: `lib/{main.dart, src/features/<f>/{data,ui}/, shared/}`
  + `test/` + `analysis_options.yaml` + `pubspec.yaml`.
- Lint/format: `dart format` + `analysis_options.yaml` `include: package:very_good_analysis/analysis_options.yaml`
  (or `flutter_lints/flutter.yaml`); run `flutter analyze`. Test: `flutter test`. Types: built into Dart (sound null safety).
- Build/run: `flutter run` (pick device); `flutter build apk|ipa|web|macos|...`. **Usually NOT
  containerized** (ships native artifacts) — for Flutter **web only**, multi-stage `flutter build web` → `nginx:alpine`.
- Monorepo (melos + pub workspaces): root `pubspec.yaml` with `publish_to: none`, `workspace:` list,
  `dev_dependencies: melos: ^7.0.0`, and a `melos:` block; each package adds `resolution: workspace`.
  `melos init` then **`melos bootstrap`** (`melos bs`). Gotchas: **run `melos bootstrap` first after
  clone/clean** or path deps don't resolve; platform channels (native code per target or
  `MissingPluginException` at runtime); pub workspaces need Dart ≥3.6.

## SOURCES
context7: langchain-ai/langgraph, golang/go, golangci/golangci-lint, websites/flutter_dev, invertase/melos.
Web: PyPI/npm/pkg.go.dev/pub.dev releases; websocket.org + coder.com (gorilla archived → coder/websocket);
go.dev/doc/go1.26; pub.dev very_good_analysis/melos. Skills for chaining from the runtime catalog:
product-brainstorming, tech-discovery, langgraph-architect (gated on presence). 2026-06-14.
