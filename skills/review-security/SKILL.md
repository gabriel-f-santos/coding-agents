---
name: review-security
description: >
  Security review of changed code, scoped to a phase/feature diff. Use to find exploitable
  vulnerabilities in what was just built — "revisa segurança da fase", "tem vuln nessa feature?",
  "security review do diff", "checa injection/authz/IDOR". Reports HIGH-confidence,
  attacker-reachable issues only (injection, broken authZ / cross-tenant / IDOR, secret exposure,
  missing validation, SSRF, deserialization, crypto misuse). Read-only — reports, does not fix.
  Runs standalone or as a subagent of review-phase. Do not use for functional conformance
  (review-functionality) or style/cleanup (review-quality).
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *)
---

# review-security — exploitable issues in the changed code

Find **HIGH-confidence, attacker-reachable** vulnerabilities in the diff. Research the whole repo
to build confidence (where does this input come from? is there validation elsewhere?), but
**report only on the changed code**. Investigate first, then report — don't flag on pattern match
alone.

## Inputs
The change set (files/diff) and, when run by `review-phase`, the phase contract excerpt (helps
spot missing auth/validation a criterion implied).

## What to check (report only what's exploitable)

- **Injection** — SQL/NoSQL/command/template/LDAP: attacker-controlled input concatenated into a
  query/command/path without parameterization or escaping.
- **AuthN/AuthZ** — missing/incorrect authentication; **broken authorization**: an action not
  checked against the caller's rights. For multi-tenant: **cross-tenant / IDOR** — reading or
  writing another tenant's data by changing an ID; trusting a tenant/user id from the request
  body instead of the resolved session.
- **Secret exposure** — hardcoded keys/tokens/passwords; secrets logged or returned in responses.
- **Input validation** — unvalidated/oversized input reaching a sink; mass-assignment.
- **SSRF** — server-side request to an attacker-controlled URL.
- **Deserialization / file handling** — unsafe deserialization; path traversal; unrestricted
  upload.
- **Crypto** — weak/again-static IV, predictable tokens, missing TLS expectation, plaintext
  storage of sensitive data.

## Do NOT flag
- Test files, dead/commented code, docs.
- Server-controlled values (config/env/constants) treated as attacker input.
- Pure best-practice/defense-in-depth with no attacker path (note at most as MEDIUM).
- Anything that requires prior trusted access not reachable from the change.

## Confidence & output

**HIGH** = vulnerable pattern + attacker-controlled input confirmed → report. **MEDIUM** = pattern
present, source unclear → "needs verification". **LOW** = theoretical → drop. Return:
`{dimension: security, severity, confidence, file:line, issue, evidence, attack (how it's
reached), why_it_matters, fix}`. False-positive discipline matters more than coverage — a noisy
security review gets ignored.
