# Architecture Decision Records (ADRs)

An ADR captures one significant decision with its context, the choice, and the consequences —
so a future reader understands *why*, not just *what*. The Tech Discovery Brief **seeds** ADRs
for the irreversible decisions it makes.

## When a decision deserves an ADR

Write one only when **all three** hold (otherwise skip — you'll just reverse it, or nobody will
wonder why):
1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will ask "why on earth this way?".
3. **A real trade-off** — there were genuine alternatives and you picked one for reasons.

Qualifies: architectural shape ("modular monolith, split later"), integration pattern between
contexts (events vs sync), tech with lock-in (DB, message bus, auth provider), boundary/scope
("Customer data owned by the Customer context; others reference by ID"), deliberate deviations
("manual SQL, not an ORM, because…"), constraints not visible in code ("no AWS — compliance").

If a `grill-with-docs` skill is present, reuse its ADR format/criteria rather than duplicating.

## Format (keep it tiny)

ADRs live in `docs/adr/`, numbered sequentially (`0001-slug.md`). Most are a single paragraph.

```markdown
# {Short title of the decision}

{1–3 sentences: the context, what we decided, and why.}

<!-- optional, only when they add value: -->
## Status        proposed | accepted | superseded by ADR-NNNN
## Considered options   {only if the rejected ones are worth remembering}
## Consequences         {only for non-obvious downstream effects}
```

The value is recording *that* a decision was made and *why* — not filling sections.

## Seeding ADRs from the brief

In the Tech Discovery Brief, list **seed ADRs**: title + one-line decision + why, for each
irreversible choice you made (style, boundaries, storage, key integration patterns, security
posture). After the human accepts the brief, these become real files in `docs/adr/`. Number them
in decision order.

## Output into the brief

A "Seed ADRs" section: a short table of `proposed ADR title | decision | rationale` for every
choice that meets the three-part test above.

> **These ADRs are first-class downstream constraints.** Once accepted in `docs/adr/`, both
> `research` and `plan-phase` read `docs/adr/` and must not violate accepted ADRs. That's the
> altitude split: **ADRs (here) = architectural / irreversible**;
> **`docs/decisions/technical-decisions-*` (from `research`) = granular, per-phase.** Keep
> high-level architecture decisions as ADRs; leave lib/pattern forks to `research`.
