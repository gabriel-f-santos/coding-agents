---
name: lgpd-compliance
description: >
  Guide LGPD (Brazilian data-protection) compliance for a web app/SaaS — audit the codebase for
  gaps, implement the required features, and scaffold the legal docs. Use for "LGPD", "adequação
  LGPD", "privacidade / proteção de dados", "política de privacidade", "banner de cookies /
  consentimento", "opt-in de analytics", "direitos do titular", "exclusão / portabilidade de
  dados", "DPO", "DPA", or "GDPR". Audits against the ANPD checklist (privacy policy, real cookie
  opt-in, data-subject rights, security by design, DPA), guides implementation (consent gating for
  GA4/Pixel, account-deletion cascade, data-export endpoint, MFA/crypto/log hygiene, Sentry
  sendDefaultPii:false), and drafts a privacy-policy / DPA. Technical guidance, NOT legal advice —
  a DPO/lawyer signs off. Do not use for general security review unrelated to privacy (use
  review-security) or for app features that don't touch personal data.
allowed-tools: Read Grep Glob Write WebSearch Task
license: MIT
metadata:
  author: skill-gen
  grounded: "2026-06-14"
---

# lgpd-compliance — privacy & data protection (LGPD)

Help a web app/SaaS comply with the **LGPD** (Lei 13.709/2018) — audit what's missing, implement
the controls, and draft the documents. Grounded in the law (art. 7/11 legal bases, art. 18 data
subject rights, art. 52 sanctions) and the **ANPD cookie guidance** (out/2022).

> ⚠️ **Not legal advice.** This is *technical* guidance to build compliant software. Legal
> sign-off (the privacy policy's legal bases, the DPA, retention periods) is the **DPO/lawyer's**
> call. Flag legal decisions as "(confirmar com DPO/jurídico)".

## Modes (detect intent, then route)

| The user wants… | Run | Primary references |
|---|---|---|
| to **audit** the app for LGPD gaps (default) | gap analysis vs the checklist | `references/audit-checklist.md` + all |
| to **implement** a specific control | guided implementation | the matching reference |
| to **draft a document** (privacy policy / DPA) | scaffold from a template | `assets/templates/` |

## References (load only what the step needs)

| Open when you need to… | Read |
|---|---|
| run the compliance gap-analysis checklist (audit mode) | `references/audit-checklist.md` |
| place roles, legal bases, data-subject rights, sanctions correctly | `references/roles-bases-rights.md` |
| write/inventory the privacy policy (data map, retention/TTL, DPO) | `references/privacy-policy.md` |
| do cookie consent + analytics right (real opt-in, IP anonymization, Sentry PII) | `references/cookies-and-analytics.md` |
| implement data-subject rights (deletion cascade, export, consent revocation) | `references/data-subject-rights.md` |
| apply security & privacy-by-design controls (MFA, crypto, logs, SAST/DAST) | `references/security-by-design.md` |
| handle third parties (DPA, controller/operator, subprocessors) | `references/dpa-third-parties.md` |

## Workflow

### Step 1 — Ground in the actual app (read before advising)
Find what personal data the app touches and how. `Grep`/`Glob` for: user/auth models, analytics
(GA4/`gtag`/Facebook Pixel), error tracking (Sentry `sendDefaultPii`), logging of IP/headers,
cookie handling, deletion/export endpoints, password hashing, and third-party SDKs. Build a quick
**data map** (what's collected, where it flows, who it's shared with). Don't advise in the
abstract — cite the real files.

### Step 2 — Run the mode
- **Audit:** walk `references/audit-checklist.md`, marking each item ✅ / ⚠️ partial / ❌ missing,
  each with the file evidence and the remediation. Prioritize by risk (an active PII leak >
  a missing retention clause). Output a gap report.
- **Implement:** open the matching reference and apply the control to the real code (or hand the
  fix to the dev). Read-only by default; only `Write` app code when the user asks.
- **Docs:** scaffold the privacy policy / DPA from `assets/templates/`, filled from the data map.
  Mark every legal/retention value "(confirmar com DPO/jurídico)".

### Step 3 — Report
Summarize: the data map, the gaps by priority (P0 = active PII leak / illegal tracking; P1 =
missing right/control; P2 = doc/clause), what was implemented/drafted, and the **legal items that
need DPO/lawyer sign-off**. Chain to `review-security` for the broader security pass and to
`tech-discovery` if privacy-by-design needs to reshape the architecture.

## Cross-cutting gotchas (the ones apps get wrong)
- **Cookie banner that only "avisa" is illegal** — GA4/Pixel must load **only after** "Aceitar";
  "Recusar" as easy as "Aceitar"; non-essential cookies **off by default** (ANPD guide).
- **IP and browser data are personal data** — anonymize/truncate/hash IPs; don't log them raw.
- **Sentry `sendDefaultPii: true` exports PII** (headers, cookies, session) to a third party
  without consent → set **`false`**.
- **Deletion must cascade** — a "delete account" that leaves orphaned rows isn't deletion.
- **Never log secrets/PII** — no passwords, session ids, or raw PII in logs.
- **Consent is revocable and granular** — and you must record *which* base legal applies per data.
