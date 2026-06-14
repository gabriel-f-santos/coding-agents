# Canonical PRD Structure (cota8 house format)

Distilled from the existing `docs/prd-*.md`. Sections converge across PRDs; adapt to the work
(a security remediation PRD leans on "Critérios de aceite"; a feature PRD leans on "Métricas
de sucesso"). Keep the **header block** and the **numbered sections** in this order.

## Header block (always)

```markdown
# PRD — <Título descritivo>

**Status:** Rascunho            <!-- Rascunho | Em revisão | Aprovado -->
**Data:** <YYYY-MM-DD>
**Autor:** <nome> (via sessão com Claude Code)
**Relacionado:** [[prd-outro]] · <docs/arquivos relevantes>
```

## Section sequence

### 0. Referências / Inspiração *(optional)*
External examples, demos, or repos the feature draws from — and, crucially, **how it adapts to
our stack** (what we reuse vs. what we deliberately do differently). Prevents cargo-culting.

### 1. Problema *(required)*
What hurts today, for whom, grounded in the **current** system. Name real surfaces
(`Dashboard.tsx`, `/dashboard/financeiro`). Describe the status quo concretely, not abstractly.

### 2. Objetivos / Oportunidade *(required)*
What changes if we ship. Tie to product vision. For feature PRDs, frame the opportunity; for
infra/security PRDs, list explicit **Objetivos** bullets.

### 3. Não-objetivos / Fora de escopo *(required)*
What this version intentionally excludes — bulleted, specific. This is the single best defense
against scope creep. Never leave empty.

### 4. Restrições críticas (NÃO QUEBRAR) *(required when touching an existing system)*
Numbered `R1`, `R2`… Each names a contract/flow/behavior that must keep working: wire formats,
public URLs, auth/tenant context, streaming tool-calls, API contracts consumed by existing
front-ends. These are the "gotchas" that most control AI-generated code — be precise.

```markdown
### R1 — <nome curto da restrição>
<o que não pode quebrar e por quê; aponte o arquivo/contrato real>
```

### 5. Proposta de arquitetura / Solução (alto nível) *(required)*
The shape of the solution — **high level**, not SI detail. Include where useful:
- **5.x Visão geral** — narrative + an ASCII architecture sketch grounded in real modules.
- **"O que já temos vs. o que falta"** table — current capability inventory. Grounds scope in
  reality and surfaces the real delta.
- **Casos de uso** table (user ask → tool/data → result) for feature PRDs.

```markdown
| Peça | Estado |
|---|---|
| <capacidade existente> | ✅ <onde> |
| <o que falta> | ❌ não existe |
```

### 6. Decisões a tomar (preencher via /research) *(required)*
Every genuine fork with real alternatives. Recommend a default, mark unresolved ones. This
table is the **input contract for `/research`** — see `pipeline-handoff.md`.

```markdown
| Tema | Opções | Recomendação inicial |
|---|---|---|
| <decisão> | (a) … ; (b) … | **(a)** — <porquê> (a confirmar) |
```

### 7. Critérios de aceite / Métricas de sucesso *(required)*
Pick the fitting form:
- **Critérios de aceite** — for security/infra/migrations. Bucket into **Segurança**,
  **Parity / funcional**, **Qualidade (DoD)**. Use Given-When-Then for flows. 3–7 per story.
- **Métricas de sucesso** — for product features. Metric + target + window.

```markdown
| Métrica | Meta |
|---|---|
| <métrica observável> | <alvo + janela> |
```

### 8. Plano de migração / fases (detalhe vai pro /plan-phase) *(required)*
A **coarse** phase sequence — name phases and their goal, not step-implementations. Each phase
name should map to a future `docs/phases/phase-NN-<slug>.md`. This is the **input contract for
`/plan-phase`**.

### 9. Riscos & mitigação *(required)*
Table of risk → mitigation. Include technical, product, and operational risks.

### 10. Entregáveis *(recommended)*
Concrete artifacts this work produces (modules, endpoints, migrations, docs).

### 11. Próximos passos *(required)*
A checklist that explicitly names the next pipeline commands:

```markdown
1. [ ] `/research <slug>` para as decisões em aberto da seção 6 (ou decisão inline).
2. [ ] `/plan-phase` para decompor a fase 1 em SIs.
3. [ ] <ações de produto/protótipo específicas>
```

## Tone & conventions

- PT-BR, direct, grounded. Tables and ASCII sketches over prose.
- Link related PRDs with `[[wikilinks]]`.
- Mark every unconfirmed assumption with **(a confirmar)**.
- Quote real file paths and symbols — a reader (human or agent) should be able to open them.
