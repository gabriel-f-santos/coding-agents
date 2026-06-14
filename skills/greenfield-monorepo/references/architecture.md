# Architecture — ask, or consume an existing `architecture.md`

Open during the interview to settle the system architecture before scaffolding. Two entry paths:

1. **The user provides an `architecture.md`** (path, or pasted) → treat it as the blueprint. Parse it for:
   the apps and their boundaries, the chosen stacks per app, the data stores, the cross-app contracts
   (`packages/proto`), NFRs, and any deployment targets. Echo back a one-paragraph summary + the file tree
   you'll generate from it, and reconcile any gaps with a couple of targeted questions. Do **not** re-ask
   what the doc already answers.
2. **No doc** → ask the architecture style (below), then **generate** an `architecture.md` from the answers
   using `assets/templates/architecture.md.tpl`, and commit it at the repo root (`docs/architecture.md`).
   It becomes the source of truth the per-app AGENTS.md files point back to.

For non-trivial systems (real boundaries, NFRs, data model, threat model), **chain to the `tech-discovery`
skill** instead of free-handing the architecture — its Tech Discovery Brief feeds this step directly.

## The architecture-style question (when asked)
Offer a recommended default and calibrate to the user's experience (educate if unsure). Common styles:

| Style | Fits when | Monorepo shape |
|---|---|---|
| **Modular monolith** (Recommended default) | one deployable, clear internal module boundaries; fastest to ship, easiest to evolve | one backend app with internal modules; split later if needed |
| **Frontend + backend (BFF)** | a SPA/mobile client + one API; the common 2-app shape | `apps/frontend-app` + `apps/backend-app` + db |
| **Microservices / service mesh** | independent deploy/scale per bounded context, multiple teams | `services/*` each with own AGENTS.md + the `packages/proto` contract |
| **Event-driven** | async workflows, decoupling via a broker | services + a broker (e.g. NATS/Kafka) in compose; contracts in `packages/proto` |

Pick the **simplest that fits** — most greenfield projects are a modular monolith or a frontend+backend
pair; reach for microservices only when independent deploy/scale/ownership is a real requirement now, not
speculative. Whatever is chosen, the **one sanctioned cross-app coupling point is `packages/proto`**
(protobuf/OpenAPI); editing it should regenerate clients (a task, not manual).

## What the architecture decision drives in the scaffold
- Which `apps/*` and `services/*` directories exist, and each one's stack (→ route to the matching stack
  reference, pinned or generic).
- The Compose services + their dependencies and the seed flow (`references/docker-and-scripts.md`).
- The per-app dev ports (maintain a small port table in the root README so nothing collides).
- The CI `paths-filter` roots and the pre-commit `files:` scoping (`references/precommit-and-ci.md`).
- The root + per-app AGENTS.md content (each app's commands and quirks).

## `architecture.md` to generate (when none provided)
Use `assets/templates/architecture.md.tpl`. It captures: overview + style + a context/container sketch
(text or C4), the apps with stack + responsibilities + dev port, data stores, cross-app contracts, NFRs
(perf/scale/availability), security notes (secrets, authn/z boundary), and open decisions. Keep it short
and real — it's a living doc, not a thesis.
