# Roles, Legal Bases, Rights & Sanctions (LGPD)

The legal scaffolding the technical work hangs on. (Articles are anchors; the DPO/lawyer owns the
final legal call.)

## Controlador vs Operador (who's who)
- **Controlador** — decides *why* and *how* personal data is processed (your company, for your
  users' data). Owns the obligations to titulares.
- **Operador** — processes data **on the controller's behalf and instructions** (your hosting,
  e-mail provider, payment processor, analytics vendor). Bound by a **DPA**. → `dpa-third-parties.md`
- You are usually the **controlador** for your users' data and an **operador's** customer. A vendor
  can be a controller of *its own* data. Map each relationship explicitly.

## Bases legais (every processing needs one)
- **Art. 7** — personal data: consentimento; execução de contrato; obrigação legal; legítimo
  interesse (with a LIA / balancing test); exercício de direitos; proteção da vida/crédito; etc.
- **Art. 11** — **sensitive** data (saúde, biometria, origem racial, opinião política, etc.):
  stricter — narrower bases, usually **specific consent** or legal obligation.
- Rule: **record the base legal per datum** in the data inventory. "Consent" is the most fragile
  (revocable, must be free/informed/granular) — prefer contract/legitimate-interest where it
  genuinely fits, and don't bundle consents.

## Direitos do titular (Art. 18) — the app must enable these
1. **Confirmação** de tratamento e **acesso** aos dados.
2. **Correção** de dados incompletos/incorretos.
3. **Anonimização, bloqueio ou eliminação** de dados desnecessários/excessivos/em desconformidade.
4. **Portabilidade** a outro fornecedor (formato estruturado).
5. **Eliminação** dos dados tratados **com consentimento**.
6. **Informação** sobre com quem os dados foram **compartilhados**.
7. **Revogação do consentimento**.

→ Implementation of 3–7 lives in `data-subject-rights.md`. A request channel (the DPO e-mail)
covers the rest; self-service UI is the better experience.

## Sanções (Art. 52) — why this matters
ANPD can apply: **advertência** (com prazo de correção); **multa de até 2% do faturamento,
limitada a R$ 50 milhões por infração**; bloqueio/eliminação dos dados; **suspensão parcial ou
total** das atividades de tratamento — plus reputational damage. Only the **ANPD** applies these.

## Privacy by Design / Security by Default
Build protection in from conception, not bolted on later. Minimize collection (only what the
purpose needs), default to the most private setting, and make rights self-service. This is the
posture the rest of the references implement.
