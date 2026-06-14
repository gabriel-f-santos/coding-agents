# Founder Interview — phases, categories, and loops

Transform a vague idea into a detailed, validated understanding through deep, iterative
questioning. Works with technical and non-technical users. Ask **one question at a time**, each
with a recommended answer, using `AskUserQuestion`. Explore the codebase/web instead of asking
when the answer is discoverable.

## Phase 1 — Orientation (2–3 questions max)

Broad questions to learn the shape (problem / who / new-vs-existing). Classify **project type**
(backend·API / web app / CLI / mobile / full-stack / automation / library) and **business
context** (B2B/B2C, who pays, single vs multi-tenant). This sets the focus for everything after.

## Phase 2 — Category deep-dive (in order)

For each relevant category: ask 2–4 questions, detect uncertainty, educate when needed, track
decisions.

| Cat | Focus | Probe | Gap signal |
|---|---|---|---|
| **A. Problem & Goals** | the real pain, today's workaround, success metric, stakeholders, cost of *not* building | "Como resolvem isso hoje? Quanto custa (tempo/dinheiro)?" | can't state the problem, or states a *solution* instead |
| **B. UX & Journey** | first-run, the ONE core action, error states, user technical level | "Abre pela 1ª vez — o que vê? o que faz?" | hasn't mapped the flow; lists features not journeys |
| **C. Data & State** | what's stored, temp vs permanent, source/destination, ownership, privacy | "Que informação precisa guardar e por quê?" | "só um banco de dados" with no schema thought |
| **D. Technical Landscape** | existing systems, constraints, deploy env, team expertise | "Com o que isso precisa conversar?" | picks tech without tradeoffs (real-time over REST, etc.) |
| **E. Scale & Performance** | users/requests now vs future, latency, spikes, read/write mix | "Quantos usuários agora e em 1 ano?" | "milhões de usuários" with no infra grasp |
| **F. Integrations** | external services, APIs consumed/created, fallbacks, auth | "Quais serviços externos? E se caírem?" | assumes integrations are trivial (ignores rate limits, auth, failure) |
| **G. Security & Access** | who-can-do-what, sensitive data (PII/financial/health), compliance, authN | "Que dado é sensível? Há GDPR/LGPD/HIPAA?" | "só um login básico" |
| **H. Deployment & Ops** | how/by-whom deployed, monitoring, updates/rollback, DR | "Como isso vai pro ar e quem opera?" | "só roda" — no ops thought |

## Phase 3 — Research loops

When uncertainty/gaps appear, offer research with options: *"Yes, research it" / "No, I know
what I want" / "Tell me briefly."* If yes: spawn a subagent (`Task`) or use `WebSearch`/
`WebFetch`, summarize in plain language, return with **informed** follow-up questions.

Triggers: "ouvi que X é bom" → research X vs alternatives · "usamos Y mas não sei se…" →
research Y's limits · a tech mismatch detected → research the correct approach.

## Phase 4 — Conflict resolution

Surface collisions explicitly and force a priority choice, naming what's lost each way. Common:
simple AND feature-rich · real-time AND cheap infra · secure AND frictionless · flexible AND
performant · fast-to-build AND future-proof.

## Knowledge-gap signals → what to do

| Signal | Do |
|---|---|
| "acho que…" / "talvez…" | probe deeper, offer research |
| "isso parece bom" (to your suggestion) | verify they understand the implication |
| "só um X simples/básico" | challenge — define what "simple" means here |
| buzzword without context | ask what they think it does |
| conflicting requirements | surface the conflict |
| "o que for padrão" | explain there's no universal standard |
| long pauses / terse answers | they may be overwhelmed — simplify |

## Adapting to the user

- **Technical:** skip basic education; still probe assumptions; focus on tradeoffs.
- **Non-technical:** use analogies ("uma API é como um garçom…"); offer more research; don't
  flood with options.
- **In a hurry:** acknowledge it; prioritize core UX + data model; record what was skipped as
  risk.

## Anti-slop rules

Never write the brief after 3–5 questions. Minimum 10–15 across categories, ≥2 per relevant
category, ≥1 research loop for any real project. Always run the completeness check and summarize
understanding before finalizing.
