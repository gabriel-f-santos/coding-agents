---
name: prd-creator
description: "Draft a Product Requirements Document that feeds the plan→execute pipeline. Use whenever the user wants to write, draft, or scope a PRD, spec out a feature/module/migration before building, or 'criar um PRD', 'escrever o PRD de X', 'spec dessa feature', 'documentar o que vamos construir'. Produces docs/prd-<slug>.md in the repo's house format — grounded in the real codebase — with the slug that carries through /research and /plan-phase. It is the front door of the pipeline: PRD → /research → /plan-phase → /implement-phase. Do not use to write the technical decisions (use /research) or the phase breakdown (use /plan-phase)."
disable-model-invocation: true
allowed-tools: Read Grep Glob Write Bash(ls *) Bash(git log *)
---

# PRD — front door of the plan→execute pipeline

Draft `docs/prd-<slug>.md` — the product spec that defines **what** to build and **why**,
grounded in the real codebase, structured so the downstream skills can consume it directly.

```
/prd-creator  →  /research  →  /plan-phase  →  /implement-phase
prd-<slug>.md   technical-decisions-<slug>.md   phase-NN-<slug>.md   phase-NN-<slug>.progress.md
```

The **slug is the spine.** Pick it once here; every downstream artifact reuses it. A PRD is
*not* a technical-decisions doc and *not* a phase plan — it states the problem, the scope, the
constraints that must not break, the open decisions to resolve, and a coarse phase outline. It
hands the technical "how" to `/research` and the SI-level breakdown to `/plan-phase`.

## References (load only what the step needs)

| Open when you need to… | Read |
|---|---|
| follow the repo's canonical PRD section structure and tone | `references/prd-structure.md` |
| know exactly what each downstream skill expects from the PRD | `references/pipeline-handoff.md` |
| separate good scope/constraints/acceptance criteria from weak ones | `references/quality-bar.md` |
| start from a fill-in skeleton | `assets/prd-template.md` |

---

## Workflow

### Step 1 — Ground in reality first (before asking anything)

A PRD that hallucinates the current system is worse than none. Inspect the codebase to learn
the **actual** starting state:

- Find the surfaces the feature touches (components, modules, services, routes). Use Grep/Glob
  on the real names — quote concrete paths in the PRD (e.g. `Dashboard.tsx`,
  `insight-tools.factory.ts`), the way existing PRDs do.
- Read related PRDs in `docs/prd-*.md` to reuse vocabulary and link them with `[[wikilinks]]`.
- Note what **already exists vs. what's missing** — this becomes the "O que já temos vs. o que
  falta" table and prevents over-scoping.

Capture findings before the interview so you ask sharper questions and skip what you can infer.

### Step 2 — Interview (one question at a time, with a recommendation)

Cover, in order (rationale + good/bad examples in `references/quality-bar.md`):

1. **Problem** — what hurts today, for whom, grounded in the current state you just mapped.
2. **Objective & opportunity** — what changes if we ship this; why now.
3. **Out of scope (Não-objetivos)** — what this version intentionally excludes. *Push for
   this* — it's the strongest defense against scope creep.
4. **Critical constraints (NÃO QUEBRAR)** — existing contracts, flows, wire formats, auth/
   tenant behavior, public URLs that must keep working. Enumerate as R1, R2… These are the
   "gotchas" that most control AI-generated code quality.
5. **Open decisions** — every fork with a real alternative (lib/strategy/pattern/storage/
   limits). These feed `/research`; recommend a default but mark "a confirmar".
6. **Acceptance criteria / success metrics** — testable conditions (Given-When-Then for flows;
   security/parity/DoD buckets; product metrics with targets). Aim for 3–7 per story.
7. **Coarse phase outline** — a rough sequence of phases (not SIs). Detail goes to
   `/plan-phase`.

If the user says "just draft it / skip the interview", infer from Step 1 + the conversation,
mark every assumption with **(a confirmar)**, and proceed.

### Step 3 — Choose the slug

A short kebab-case slug describing the feature: `dynamic-charts`, `llm-gateway-module`,
`auth-rate-limiting`. This becomes `docs/prd-<slug>.md` and propagates to
`docs/decisions/technical-decisions-<slug>.md` and `docs/phases/phase-NN-<slug>.md`. Confirm
it doesn't collide with an existing `docs/prd-*.md`.

### Step 4 — Write `docs/prd-<slug>.md`

Use `assets/prd-template.md` and the section spec in `references/prd-structure.md`. Rules:

- **Portuguese (PT-BR)** to match existing docs, unless the user writes in another language.
- Ground every claim in real files/paths; no invented frameworks or endpoints.
- Make **Não-objetivos** and **Restrições críticas (NÃO QUEBRAR)** explicit and specific.
- Put genuine forks under **Decisões a tomar (preencher via /research)** — don't pre-decide
  what deserves research; recommend, don't dictate.
- Keep the **phase plan coarse** — name phases, not step-implementations.
- End with **Próximos passos** as a checklist that names the next pipeline steps
  (`/research`, `/plan-phase`).

### Step 5 — Validate against the quality bar

Before declaring done, self-check with `references/quality-bar.md`:
- Is the problem grounded and specific (not generic)?
- Is out-of-scope non-empty and concrete?
- Does every critical constraint name a real thing that could break?
- Is each acceptance criterion testable?
- Are open decisions actual forks (not obvious choices), ready for `/research`?
- Does the phase outline map cleanly to `/plan-phase`?

Fix gaps, then report the path, the chosen slug, the open decisions count, and the suggested
next command (`/research <slug>` or, if no research needed, `/plan-phase`).

## Output format

Return:
1. **Summary** — feature, slug, one-line problem & objective.
2. **File** — `docs/prd-<slug>.md` written.
3. **Open decisions** — list of forks to resolve in `/research` (or "none → go straight to
   /plan-phase").
4. **Next step** — exact command to run next.
