---
name: product-discovery
description: >
  Turn a vague product idea into a validated discovery brief through a deep founder interview,
  live market research, and generated user-research instruments. Use when the user has a
  product/SaaS/feature idea and wants to validate the problem before building — "tenho uma
  ideia", "quero validar um produto", "product discovery", "pesquisa de mercado", "vamos
  descobrir se vale a pena", "monta uma entrevista/survey pros usuários", "TAM SAM SOM". It
  interviews the founder (Mom Test + JTBD framing), researches the market (TAM/SAM/SOM,
  competitors, demand signals) using parallel subagents when available, generates user-research
  instruments (interview guide, survey, screener, fake-door landing), and writes a discovery
  brief. Do not use to write a build spec/PRD (that comes after) or to brainstorm features
  without validation — use product-brainstorming for pure ideation.
allowed-tools: Read Write WebSearch WebFetch Task Bash(ls *)
---

# product-discovery — from idea to validated brief

Find out whether a problem is worth solving **before** writing code. The skill runs a rigorous
discovery process and produces a **discovery brief** that can feed a PRD/spec.

```
product-discovery  →  (validated problem)  →  PRD/spec  →  research  →  plan  →  build
```

> **Guiding stance.** Don't ask obvious questions, don't accept surface answers, don't assume.
> Understand what the user *actually* wants (not what they say), surface hidden assumptions and
> tradeoffs, and research when uncertainty appears. Only write the brief when understanding is
> complete. Chase **stories and history, not opinions and hypotheticals** (The Mom Test).

## Modes (detect intent, then route)

| The user wants… | Run | Primary references |
|---|---|---|
| full discovery (default) | the whole workflow below | all |
| just to **interview the founder** | Steps 1–2 + brief | `references/interview-founder.md` |
| just **market research** | Step 3 | `references/market-research.md` |
| just to **generate user-research instruments** | Step 4 | `references/research-instruments.md` |

## References (load only what the step needs)

| Open when you need to… | Read |
|---|---|
| run the founder interview: phases, categories A–H, gap signals, research/conflict loops | `references/interview-founder.md` |
| ask users without biasing them — Mom Test rules + JTBD switch/4-forces | `references/talking-to-users.md` |
| size the market & map competitors & test demand (TAM/SAM/SOM, fake-door) | `references/market-research.md` |
| apply the canvases — Value Proposition, Business Model, Opportunity Solution Tree, Lean/MVP | `references/frameworks.md` |
| generate the 4 user-research instruments with anti-bias rules + templates | `references/research-instruments.md` |
| see the output brief skeleton | `assets/templates/discovery-brief.md` |

---

## Workflow

### Step 1 — Initial orientation (2–3 broad questions)

Understand the shape of the idea before diving deep. Ask, via `AskUserQuestion`:
- "Em uma frase, qual problema você está tentando resolver?"
- "Quem vai usar isso? (usuário final, empresa, time interno…)"
- "É algo novo ou melhora algo que já existe?"

From the answers, classify the **project type** (backend/API, web app, CLI, mobile, full-stack,
automation, library) and the **business context** (B2B vs B2C, who pays). This focuses every
later question. Record a running spec of decisions.

### Step 2 — Founder deep-dive interview

Read `references/interview-founder.md`. Work through the relevant categories **in order**
(Problem & Goals → UX & Journey → Data & State → Technical Landscape → Scale → Integrations →
Security → Ops). For each: ask 2–4 questions, **one at a time**, each with a recommended answer.

- **Detect knowledge gaps** (see the signal table in the reference) and educate rather than let
  the user decide uninformed.
- **Research loops:** when uncertainty appears ("acho que…", a tech mismatch, "ouvi que X é
  bom"), offer to research — spawn a subagent (`Task`) or use `WebSearch`/`WebFetch`, summarize
  findings in plain language, and return with *informed* follow-up questions.
- **Conflict resolution:** when requirements collide ("simples E cheio de features", "real-time
  E barato"), surface the conflict explicitly and ask which matters more.

Minimum bar: 10–15 questions across categories, ≥2 per relevant category, ≥1 research loop for
any non-trivial project. Never write the brief after 3–5 questions — that produces slop.

### Step 3 — Market research (offer it)

Offer market research; if accepted, read `references/market-research.md` and **fan out with
subagents** when available (one per axis), otherwise inline:
- **Market size** — TAM/SAM/SOM, bottom-up *and* top-down, cross-checked.
- **Competitors** — direct / indirect / future entrants; positioning & feature gaps.
- **Demand signals** — where people already spend time/money on this; search volume, forums,
  existing paid alternatives.

Summarize findings in plain language and feed them back into the interview (they often reframe
the opportunity).

### Step 4 — User-research instruments (the "talk to potential users" kit) — offer it

This is the explicit option to **generate a survey/guide to interview people who would use the
platform.** Offer it; if accepted, read `references/research-instruments.md` and
`references/talking-to-users.md`, then generate — grounded in the hypotheses, target persona,
and riskiest assumptions from Steps 1–3 — the instruments the user picks (default: all):

1. **Interview guide** (Mom Test + JTBD switch / 4 forces) — qualitative 1:1.
2. **Quantitative survey** (<10–12 questions, no leading questions, scales + open-ended).
3. **Recruitment screener** — filters for the right target profile before interviewing.
4. **Landing / fake-door copy** — value prop + waitlist CTA + the metrics to track (CTR, opt-in)
   for a pre-MVP demand test.

Every instrument must obey the anti-bias rules (ask about past behavior, not future opinions;
no compliments-fishing; no leading questions). Write them to `docs/discovery/<slug>/`.

### Step 5 — Completeness check

Before the brief, verify you have: a clear problem statement + success metrics + stakeholders;
a mapped user journey + core actions + error states; a data model, integrations, scale,
security, and deployment understanding; and **every tradeoff explicitly chosen with no "TBD"**.
If anything is missing, go back and ask. Then summarize your understanding and confirm with the
user ("Antes de escrever o brief, deixa eu confirmar…").

### Step 6 — Write the discovery brief

Use `assets/templates/discovery-brief.md`. Write to `docs/discovery/<slug>-discovery.md`. It
captures the validated problem, personas, journey, P0/P1/P2 requirements, market summary,
riskiest assumptions + validation plan, out-of-scope, and a research-findings appendix —
structured so a PRD/spec step can consume it directly.

### Step 7 — Handoff

Ask how to proceed: start the spec/PRD now, plan a round of user interviews with the generated
kit, run the fake-door demand test, or stop here. Point to the brief path and the kit.

## Output format

Return: **Summary** (idea, target, validated/at-risk problem) · **Files** (brief + any
instruments) · **Riskiest assumptions** and how to test them next · **Suggested next step**.
