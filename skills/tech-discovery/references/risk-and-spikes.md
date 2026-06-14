# Risk-First: Unknowns, Spikes & the Walking Skeleton

The point of technical discovery is to **buy down risk before committing**. Find the unknowns
that could sink the design and resolve them cheaply, early — not during the build.

## Surface the riskiest unknowns

For every major decision, ask: "what would make this the *wrong* call, and how confident am I?"
Rank unknowns by **impact × uncertainty**. The top ones get a spike; the rest get a decision
with a recommendation. Categories that hide risk:
- A library/integration you haven't used at this scale or version.
- A performance/cost assumption (latency, throughput, LLM token cost) not yet measured.
- A consistency/concurrency claim ("this is idempotent", "no race here").
- A data migration that's hard to reverse.
- A security control you haven't proven (e.g. tenant isolation, a new auth flow).

## Time-boxed spikes

A **spike** is a short, time-boxed investigation (usually 1–2 days) to reduce uncertainty —
research or a throwaway prototype. Each spike must have:
- **Objective** — the one question it answers.
- **Time box** — explicit (e.g. 1 day).
- **Acceptance / definition of done** — a *decision*, a measured number, a PoC, or a documented
  risk analysis. Not "play with X".
- **Outcome it unblocks** — which architecture decision it lets you finalize.

Spikes are **throwaway** — code quality doesn't matter; the *answer* does. Capture the result as
a finding (and, if it settles an irreversible choice, a seed ADR).

## Walking skeleton / tracer bullet (de-risk integration)

A **walking skeleton** is a tiny end-to-end slice that links the main architectural components
(UI → API → worker → DB → external call), doing one trivial thing. Unlike a spike it's **not
throwaway** — it's built with real practices and becomes the project's skeleton.

Use it to validate the *architecture and stack integration* early — the wiring, the deploy, the
auth, the cross-component calls — before piling on features. It's the cheapest way to flush out
"these pieces don't fit together" while it's still cheap to change.

- **Spike** answers "will this approach work?" (throwaway).
- **Walking skeleton** proves "the chosen pieces connect end-to-end" (kept).

## Options & trade-offs (how to present a decision)

For each major decision, give 2–3 options, each: how it works (2–3 lines), pros, cons — judged
against *this* project's NFRs and constraints. Recommend one, justified by context (not "it's
modern"). If two are equivalent for the stack, say so and pick the reversible one. Leave a
`Decision:` slot for the human.

## Research to resolve unknowns (plan → capture → consolidate)

When an unknown needs external knowledge, fan out with subagents (`Task`), one per question;
use context7 for version-specific docs and `WebSearch`/`WebFetch` for current practice; verify
non-obvious claims against a second source. Save each result separately, then consolidate into
the option write-up and cite it. Degrade gracefully if those tools aren't available.

## Output into the brief

- A ranked **risk register** (unknown → impact/uncertainty → mitigation).
- A **spike list** (objective, time box, acceptance, what it unblocks) — ordered, riskiest first.
- A **walking-skeleton** definition (the end-to-end slice to build first).
