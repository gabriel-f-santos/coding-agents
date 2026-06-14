# PRD — {{TÍTULO DESCRITIVO}}

**Status:** Rascunho
**Data:** {{YYYY-MM-DD}}
**Autor:** {{nome}} (via sessão com Claude Code)
**Relacionado:** {{[[prd-relacionado]] · docs/arquivos relevantes}}

---

<!-- Seção 0 é opcional — use quando a feature se inspira em algo externo. -->
## 0. Referências / Inspiração

{{Demo/repo/exemplo + O QUE ele faz + COMO adaptamos à nossa stack (reusa vs. faz diferente).}}

---

## 1. Problema

{{O que dói hoje, pra quem, ancorado no estado atual. Cite superfícies reais: arquivos, rotas,
componentes. Descreva o status quo concretamente.}}

---

## 2. Objetivos / Oportunidade

{{O que muda se entregarmos. Para infra/segurança, liste objetivos em bullets.}}

---

## 3. Não-objetivos / Fora de escopo

- {{o que esta versão NÃO faz}}
- {{...}}
- {{...}}   <!-- mínimo 3 itens concretos -->

---

## 4. Restrições críticas (NÃO QUEBRAR)

### R1 — {{nome curto}}
{{contrato/fluxo/comportamento que não pode quebrar e por quê; aponte o arquivo real}}

### R2 — {{nome curto}}
{{...}}

---

## 5. Proposta de arquitetura / Solução (alto nível)

### 5.1 Visão geral
{{narrativa + sketch ASCII ancorado em módulos reais}}

### 5.2 O que já temos vs. o que falta

| Peça | Estado |
|---|---|
| {{capacidade existente}} | ✅ {{onde}} |
| {{o que falta}} | ❌ não existe |

<!-- Para features, adicione uma tabela de Casos de uso:
| Pergunta do usuário | Tool / dado | Resultado |
|---|---|---|
| "{{...}}" | {{...}} | {{...}} | -->

---

## 6. Decisões a tomar (preencher via /research)

| Tema | Opções | Recomendação inicial |
|---|---|---|
| {{decisão}} | (a) {{...}} ; (b) {{...}} | **(a)** — {{porquê}} (a confirmar) |

<!-- Se NÃO houver forks reais, escreva: "Sem decisões em aberto → ir direto pro /plan-phase." -->

---

## 7. Critérios de aceite {{/ Métricas de sucesso}}

<!-- Escolha a forma adequada. Para segurança/infra/migração: -->
### Segurança
- [ ] {{condição testável}}

### Parity / funcional
- [ ] {{condição testável}}

### Qualidade (DoD)
- [ ] {{testes, lint, sem regressão}}

<!-- Para produto, use métricas:
| Métrica | Meta |
|---|---|
| {{métrica observável}} | {{alvo + janela}} | -->

---

## 8. Plano de migração / fases (detalhe vai pro /plan-phase)

1. **Fase 1 — {{nome}}** — {{objetivo + capacidades entregues}}
2. **Fase 2 — {{nome}}** — {{objetivo}} (depende da Fase 1: {{contrato}})
3. {{...}}

<!-- Coarse: nomeie fases, não SIs. Cada fase → docs/phases/phase-NN-{{slug}}.md -->

---

## 9. Riscos & mitigação

| Risco | Mitigação |
|---|---|
| {{risco}} | {{mitigação}} |

---

## 10. Entregáveis

- {{módulo / endpoint / migração / doc concreto}}

---

## 11. Próximos passos

1. [ ] `/research {{slug}}` para as decisões da seção 6 (ou decisão inline).
2. [ ] `/plan-phase` para decompor a Fase 1 em SIs.
3. [ ] {{ação de produto/protótipo específica}}
