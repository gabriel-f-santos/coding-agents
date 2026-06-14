# Architecture Style & Boundaries

Decide the *shape* of the system and where the seams go. Default to the simplest style that
meets the NFRs; justify every step toward distribution with a concrete requirement.

## Choosing a style (in order of increasing cost)

| Style | Fits when | Cost it adds |
|---|---|---|
| **Modular monolith** (default) | one team, shared data, NFRs met by one deployable | least; refactor seams later |
| **Modular monolith + async workers** | some work is slow/bursty (jobs, emails, AI calls) | a queue + worker lifecycle |
| **Service-oriented / microservices** | independent scaling/teams/deploy cadence, hard isolation | network, distributed data, ops, observability |
| **Event-driven** | decoupled producers/consumers, audit/replay, fan-out | eventual consistency, idempotency, schema mgmt |

> Distribution is a tax you pay in latency, consistency, and ops. Pay it only when an NFR or
> org constraint forces it. "We might scale" is not a reason; a load number is.

## C4 — describe the system at the right zoom

Use the C4 levels (draw with mermaid in the brief):
1. **Context** — the system as a box + users + external systems it talks to.
2. **Containers** — deployable/runtime units (web app, API, worker, DB, cache, queue).
3. **Components** — major modules inside a container and their responsibilities.
4. (Code level — skip; that's implementation.)

Plus, when useful: a **dynamic** view for a key flow, and a **deployment** view (where
containers run). Keep it to what clarifies a decision — don't diagram for ceremony.

## Bounded contexts (DDD) — where the seams go

A bounded context is a boundary inside which one model and its **ubiquitous language** are
consistent. Draw boundaries where the language changes ("order" means different things to Sales
vs Fulfillment) or where teams/lifecycles differ.

- Name each context and its core responsibility + the language it owns.
- Define the **integration** at each boundary: shared IDs only, published events, an ACL
  (anti-corruption layer) translating another context's model, or a shared kernel (use sparingly).
- These context boundaries are the strongest candidates for future service boundaries — but you
  can keep them as modules in a monolith first (modular monolith), splitting only when an NFR
  demands it.

If a `ddd` skill is available in the repo, load it for the deeper bounded-context / context-map
guidance instead of re-deriving here.

## Reuse before you build

Inventory what already exists in the codebase (auth, jobs, storage, an LLM gateway, a design
system). The cheapest component is the one you don't build. Map each capability to "reuse / extend
/ build" and justify any new build.

## Output into the brief

- Chosen style + the one-line NFR/constraint that justifies it (and what you rejected).
- C4 context + container diagrams (mermaid).
- Bounded-context list with responsibilities, language, and boundary integration patterns.
