# Design Summary — {{Produto/Feature}}

**Slug:** {{slug}}
**Data:** {{YYYY-MM-DD}}
**Fonte da visão:** [[discovery-{{slug}}]] / [[prd-{{slug}}]]
**Renderização:** {{pencil | figma | design MCP | degradado (wireframes textuais)}}
**Plataforma alvo:** {{desktop-first | mobile-first | responsivo}}

> Este é o índice de design da feature. Quem for fazer o plano de implementação referencia
> **este arquivo** pra saber quais telas implementar e o que cada uma faz.

## Screen inventory (tela → requisito)
| Tela | Propósito | Feature/requisito (PRD) | Estado | Frame |
|---|---|---|---|---|
| {{login}} | {{autenticar}} | {{P0 – auth}} | {{spec ok / wireframe}} | {{link ou —}} |
| {{dashboard}} | {{…}} | {{P0 – …}} | | |

## User flows
```mermaid
flowchart LR
  {{A[Tela] --> B[Tela]}}
```
{{um flow por jornada core; inclua ramos de erro/vazio}}

## Telas (specs)
Cada tela tem spec própria em `docs/design/{{slug}}/screens/<tela>.md` — purpose, layout,
componentes, **estados (vazio/loading/erro/sucesso/permissão)**, ações/transições.

- [{{login}}](screens/login.md) — {{1 linha}}
- [{{dashboard}}](screens/dashboard.md) — {{1 linha}}

## Frames renderizados
{{Links pros frames no Figma/pencil, se houver tool conectada. Senão: "wireframes textuais nas specs".}}

## Mapeamento p/ implementação
{{Resumo: quais telas entram em quais fases (se já houver phases), ou agrupamento sugerido.
É daqui que o plan-phase/implement-phase puxa "o que construir".}}

## Questões em aberto
- {{requisito que o design revelou faltar → flag pro PRD}}
- {{decisão de UX pendente}}
