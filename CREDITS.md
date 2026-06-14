# Créditos — inspirações & adaptações

Várias skills e a forma do nosso fluxo foram **adaptadas ou inspiradas** em trabalho de
terceiros. Onde foi adaptação direta, está dito; onde foi influência conceitual/metodológica,
também. Crédito a quem é devido.

## Sentry — [github.com/getsentry](https://github.com/getsentry) · [getsentry/skills](https://github.com/getsentry/skills)

Plataforma de error tracking/observabilidade; o repo `getsentry/skills` foi fonte **direta**.

- **`skill-scanner`** — adaptado do scanner de segurança de skills do Sentry (prompt injection,
  código malicioso, permissões, secrets, supply chain).
- **`sentry-security-review`** — o review de vulnerabilidades baseado em OWASP, com **reporte
  por nível de confiança** (só HIGH, nota MEDIUM, dropa LOW).
- **`skill-writer`** (Sentry) — não ficou no catálogo, mas **aprendemos com ele**: o loop de
  *iteração a partir de exemplos* e o *description-optimization* foram destilados pra dentro da
  nossa `skill-gen` (`references/iteration.md`, `references/description-optimization.md`).
- O estilo **confidence-based** influenciou os reviewers (`review-security`, `review-phase`).

## Full Cycle — [github.com/devfullcycle](https://github.com/devfullcycle)

Organização brasileira de educação em engenharia de software/arquitetura. Influência
**conceitual e metodológica** (e, nos repos de IA, bem próxima do que fazemos aqui):

- **Arquitetura & DDD** — bounded contexts, clean/hexagonal, **event-driven** (`fc4-event-driven-arch`)
  e a disciplina de modelagem de domínio → moldaram a **`tech-discovery`** (bounded contexts, C4,
  ADRs) e a skill **`ddd`**.
- **IA aplicada ao ciclo de dev** — os projetos `mba-ia-*` (ex.: `mba-ia-refactor-projects-skill`,
  `mba-ia-pull-evaluation-prompt`, `mba-ia-greenfield-project`) ecoam o nosso **`review-phase`**
  (avaliação de PR/feature), **`refactor`/`simplify`** e a mentalidade **greenfield → design →
  plan → execute** do pipeline.
- A cultura "Full Cycle" (do problema à entrega, com qualidade em cada etapa) é o espírito do
  nosso fluxo `product-discovery → tech-discovery → prd-creator → research → plan → implement →
  review`.

## Outras fontes (menores, mas honestas)

- **[agentskills.io](https://agentskills.io)** — o padrão aberto que torna as skills portáveis
  (Claude Code / Codex / opencode).
- **Anthropic `skill-creator`** — examinado e aposentado; ideias de eval/iteração ecoam na
  `skill-gen`.
- **`product-discovery`** apoia-se em *The Mom Test* (Fitzpatrick), *JTBD* (Christensen/Moesta),
  *Value Proposition / Business Model Canvas* (Osterwalder) e *Lean Startup* (Ries) — ver as
  fontes citadas dentro da skill.
- **`tech-discovery`** referencia C4, arc42, ADRs, walking skeleton/tracer bullet, STRIDE.

> Onde adaptamos código/abordagem de terceiros, mantivemos a intenção original e respeitamos as
> licenças dos repositórios de origem.
