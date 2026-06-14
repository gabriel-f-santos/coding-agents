# Quality Bar — good vs. weak PRD content

A PRD's job is to let an agent (and a human) execute without constant clarification. These
contrasts are what separate a spec that drives clean AI-generated code from one that invites
scope creep and rework. Grounded in PRD-for-AI-codegen best practice + the repo's own PRDs.

## Problem statement

❌ *"O dashboard precisa de melhorias."*
✅ *"A home (`Dashboard.tsx`) mostra cards estáticos; pra ver qualquer tendência o dono sai pra
`/dashboard/financeiro`, onde os ~13 gráficos são fixos. Não dá pra perguntar 'mostra vendas
por mês' e ver o gráfico aparecer onde a decisão acontece."*

Grounded, names real surfaces, describes the status quo and the gap.

## Out of scope (Não-objetivos)

❌ Empty, or "tudo que não for essencial".
✅ A concrete bulleted list: *"Edição manual de gráficos (drag-and-drop); exportar PNG/PDF;
persistência de layout por usuário; mobile otimizado; substituir os relatórios de
`/financeiro`."*

Rule: if you can't name ≥3 things you're **not** doing, the scope isn't thought through.

## Critical constraints (NÃO QUEBRAR)

❌ "Não quebrar nada."
✅ Numbered, each pointing at a real contract:
> **R1 — `tool_calls` em streaming no copilot** — o wire AG-UI atual emite `TOOL_CALL_*`;
> qualquer mudança no gateway tem que preservar o formato consumido pelo front.

Each constraint names a thing that *could* break and why it matters. This is the highest-
leverage section for AI codegen — it's the guardrail.

## Open decisions (→ /research)

❌ Pre-deciding everything, or listing trivia ("usar TypeScript?").
✅ Genuine forks with alternatives + a recommendation:
> | Estado chat↔página | (a) re-render a cada pergunta; (b) estado de agente (AG-UI state) |
> A decidir — (b) é o caminho do "atualiza o gráfico que já está na tela" |

A decision belongs here only if there's a real alternative in the stack. Obvious choices don't.

## Acceptance criteria

❌ "Funciona bem e é rápido."
✅ Testable, bucketed, 3–7 per story. For flows use Given-When-Then:
> **Dado** um usuário não autenticado, **quando** chama `POST /…-wa`, **então** recebe 401 e
> nenhuma escrita ocorre.

For features, measurable metrics with targets and a window:
> *"% de sessões da home que geram ≥1 gráfico via IA > 25% em 30 dias."*

Fewer than 3 criteria = edge cases unconsidered; more than 7 = the story is too big, split it.

## User stories (when used)

✅ `Como <tipo de usuário> quero <ação> para <benefício>` + 3–7 Given-When-Then acceptance
criteria. The specificity of the criteria directly controls the quality of the generated code.

## Phase outline (→ /plan-phase)

❌ Writing step-implementations in the PRD.
✅ Coarse phases in delivery order, each with a goal and the capability it ships, dependencies
noted. Detail is plan-phase's job — the PRD just sequences the work.

## Grounding

Every PRD claim should be checkable: real file paths, real symbols, real endpoints, real
existing PRDs linked with `[[wikilinks]]`. A PRD that invents a framework or an endpoint is a
liability — the agent will build on the fiction.

## The end-to-end clarity test

Before finishing, ask: *could `/plan-phase` and then `/implement-phase` run on this PRD without
coming back to ask what I meant?* If a section would force a clarifying question, tighten it or
mark it explicitly **(a confirmar)** so the gap is visible, not silent.
