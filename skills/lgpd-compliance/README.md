# lgpd-compliance

Helps a web app/SaaS comply with the **LGPD** (Lei 13.709/2018): **audit** the codebase for gaps,
**implement** the required controls, and **draft** the legal documents (privacy policy, DPA).

> ⚠️ Technical guidance, **not legal advice** — a DPO/lawyer signs off on legal bases, retention and DPA terms.

## When to use
"adequação LGPD", "política de privacidade", "banner de cookies / consentimento", "opt-in de
analytics", "direitos do titular", "exclusão/portabilidade de dados", "DPO/DPA", "GDPR".

## Modes
- **Audit** (default) — gap analysis vs the ANPD checklist, with file evidence + remediation, P0/P1/P2.
- **Implement** — guided implementation of a control (cookie opt-in, deletion cascade, export, MFA/crypto/logs).
- **Docs** — scaffold a privacy policy / DPA from templates, filled from the data inventory.

## What it covers (grounded in the law + ANPD)
- Roles (controlador/operador), legal bases (art. 7/11), data-subject rights (art. 18), sanctions (art. 52).
- Privacy policy + data inventory + retention/TTL + DPO.
- Real cookie opt-in (ANPD guide), IP anonymization, Sentry `sendDefaultPii:false`.
- Deletion cascade, data export/portability, consent revocation.
- Security by design (MFA, TLS1.3/AES-256, argon2/bcrypt, SAST/DAST, PII-free logs).
- DPA & third parties.

## Chains with
`review-security` (broader security pass) · `tech-discovery` (privacy-by-design architecture) ·
`greenfield-monorepo` (CI SAST/gitleaks).

## Install
`cp -r lgpd-compliance ~/.claude/skills/` (Claude Code + opencode) or `.codex/skills/` (Codex). Portable; see PORTABILITY.md.
