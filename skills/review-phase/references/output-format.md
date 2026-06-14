# Review Output — priorities, confidence, dedup, report skeleton

## Confidence (each reviewer applies before returning)

| Level | Criteria | Action |
|---|---|---|
| **HIGH** | clear issue + confirmed in the changed code | **report** with severity |
| **MEDIUM** | suspicious but context unclear / not confirmed | **note** as "needs verification" |
| **LOW** | theoretical / pure style / best-practice only | **drop** (don't report) |

No adversarial second pass — trust the confidence tag, but never promote a MEDIUM to the P0/P1
list without the evidence to back it.

## Priority (orchestrator assigns after merge)

| Priority | Meaning | Examples |
|---|---|---|
| **P0** | blocks ship | a failed acceptance criterion; exploitable security (injection, cross-tenant/IDOR, secret leak); data loss; crash on the happy path |
| **P1** | fix before merge | correctness bug on an edge/error path; missing validation; N+1 on a hot path; broken contract with a caller |
| **P2** | cleanup / nice-to-have | duplication, dead code, naming, minor simplification, non-hot-path inefficiency |

Rule: a quality/"crap" finding is **never P0**. A security or failed-acceptance finding is
**never below P1**.

## De-dup

If the same `file:line` (or the same root issue) is raised by more than one dimension, keep one
entry, attach the strongest evidence, and tag which dimensions flagged it. Don't list the same
fix three times.

## Map functionality findings to the contract

Every functionality finding cites the **acceptance criterion** it fails (quote it). A
functionality review that doesn't reference the phase contract is just a generic code review —
the point here is conformance.

## Report skeleton

```markdown
# Review — phase-NN <slug>  ·  <date>

**Veredito:** ship ✅ | fix-then-ship ⚠️ | blocked ⛔
**Findings:** P0 <n> · P1 <n> · P2 <n>   (functionality <n> · security <n> · quality <n>)
**Escopo:** <N arquivos> — <base>...HEAD

## P0 — bloqueia
### [F-01] <título>  (functionality · HIGH)
- **Critério de aceite que falha:** "<quote do phase-NN.md>"
- **Local:** `path:line`
- **Problema:** …
- **Evidência:** `<trecho>`
- **Fix:** …

## P1 — corrigir antes do merge
### [S-01] <título>  (security · HIGH)
- **Local / Problema / Evidência / Risco / Fix:** …

## P2 — limpeza
- [Q-01] `path:line` — <duplicação/dead code/naming> → <fix curto>

## Needs verification (MEDIUM)
- <finding + por que não dá pra confirmar sem rodar/contexto>

## Não coberto / gaps
- <dimensão/arquivo que ficou de fora e por quê>
```

IDs: `F-` functionality, `S-` security, `Q-` quality. The screen summary = the verdict line +
the P0/P1 blocks (skip P2 on screen; they live in the file).
