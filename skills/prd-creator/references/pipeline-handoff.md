# Pipeline Handoff — what each downstream skill needs from the PRD

The PRD is the front door. Its sections are **input contracts** for the next skills. Write each
section knowing who consumes it.

```
/prd            docs/prd-<slug>.md
  │  §6 Decisões a tomar  ──────────────►  /research      docs/decisions/technical-decisions-<slug>.md
  │  §8 Plano de fases    ──────────────►  /plan-phase    docs/phases/phase-NN-<slug>.md
  │  §4 Restrições + §7 Critérios ───────►  (carried into both)        phase-NN-<slug>.progress.md  ◄─ /implement-phase
```

## The slug is the spine

Choose one kebab-case slug and reuse it across every artifact:

| Stage | Skill | Artifact |
|---|---|---|
| Spec | `/prd` | `docs/prd-<slug>.md` |
| Decisions | `/research` | `docs/decisions/technical-decisions-<slug>.md` |
| Plan | `/plan-phase` | `docs/phases/phase-NN-<slug>.md` |
| Execute | `/implement-phase` | `docs/phases/phase-NN-<slug>.progress.md` |

Examples already in the repo: `dynamic-charts`, `llm-gateway-module`, `auth-rate-limiting`,
`blog-module-integration`. Keep the slug stable — renaming mid-pipeline orphans artifacts.

## §6 → /research

`/research` reads the **Decisões a tomar** table and turns each fork into a researched decision
with trade-offs. To make that clean:

- List only **genuine forks** — choices with real alternatives in the project's stack (bcrypt
  vs argon2, JWT vs session, refresh rotation vs blacklist). Skip obvious/trivial choices.
- Recommend a default, but don't pre-decide what deserves research.
- If a PRD has **no** real forks, say so explicitly in §11 ("sem decisões em aberto → ir direto
  pro /plan-phase"). `/research` is skippable when there's nothing to research.

## §8 → /plan-phase

`/plan-phase` decomposes a phase into Step-Implementations (SIs) with tests and acceptance
criteria. It reads the phase description and capabilities. To make that clean:

- Keep §8 **coarse**: name each phase + its goal + the capabilities it delivers. Do **not**
  write SIs — that's plan-phase's job.
- Each phase name should become a `phase-NN-<slug>.md`. Number them in delivery order.
- Surface dependencies between phases (phase 2 needs phase 1's contract).

> Note: `/plan-phase` historically references a single `docs/project-plan.md`, but this repo
> works per-feature: the **PRD itself is the project plan** for its slug. When invoking
> `/plan-phase`, point it at `docs/prd-<slug>.md` as the source.

## §4 + §7 carried through

- **Restrições críticas (NÃO QUEBRAR)** become hard constraints in both research and planning —
  no downstream decision may violate them. plan-phase's validation step checks consequences
  against these.
- **Critérios de aceite** seed the Tests/Acceptance sections of each SI and the final
  completion report in `/implement-phase`.

## Validation the PRD enables downstream

`/plan-phase` runs a heavy validation pass (inconsistencies, ambiguities, unmapped
consequences). A good PRD pre-empts findings by being explicit about: edge cases of inputs,
collisions/uniqueness of derived values, side effects on related entities, concurrency, and
failure paths. The more §1/§4/§7 nail these, the less plan-phase has to bounce back.
