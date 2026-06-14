# LGPD Audit Checklist (gap analysis)

Walk every item against the **real code**. Mark `✅` (done), `⚠️` (partial), `❌` (missing) — each
with **file evidence** and a one-line remediation. Then prioritize: **P0** = active PII leak /
illegal tracking; **P1** = missing data-subject right or security control; **P2** = doc/clause.

## A. Transparency & policy
- [ ] **Privacy Policy** published, easy to find (footer + signup), specific on **legal basis** per
  data and purpose. → `privacy-policy.md`
- [ ] **Terms of Use** published.
- [ ] **Data inventory** exists: each datum classified (pessoal / uso / sensível) with base legal,
  finalidade, retention/TTL.
- [ ] **DPO/Encarregado** contact published (a real e-mail for titular requests).

## B. Cookies & analytics  → `cookies-and-analytics.md`
- [ ] **Real opt-in**: GA4 / Facebook Pixel / other trackers load **only after** "Aceitar" (not in
  `<head>` on page load).
- [ ] **"Recusar" as easy as "Aceitar"**; non-essential cookies **off by default**; "Gerenciar".
- [ ] **Consent revocable** (a 2nd-level banner / settings).
- [ ] **IPs anonymized** (truncated/hashed), not stored/logged raw.
- [ ] **Sentry/error tracking** `sendDefaultPii: false` (no headers/cookies/session to 3rd party).

## C. Data-subject rights (art. 18)  → `data-subject-rights.md`
- [ ] **Account + data deletion** by the user (visible button), cascading in the DB.
- [ ] **Data export / portability** (structured format) endpoint or button.
- [ ] **Consent revocation / preferences** UI (change/cancel anytime).
- [ ] **Access/confirmation** of processing; **correction** of data.

## D. Security & privacy by design  → `security-by-design.md`
- [ ] **MFA** available/required; **least privilege**; **anti-brute-force** (lockout/rate-limit).
- [ ] **Social login (OAuth)** discloses exactly which data is pulled and why.
- [ ] **TLS 1.3** in transit; **AES-256** at rest; passwords hashed with **argon2id/bcrypt + salt**.
- [ ] **Vuln management**: SAST + DAST in CI; deps patched (matches our `review-security` + greenfield
  gitleaks/CI).
- [ ] **Logs auditable & immutable** but **no PII/secrets** (no passwords, session ids, raw IP).

## E. Third parties  → `dpa-third-parties.md`
- [ ] Map every **operador** (hosting, e-mail, payments, analytics, CRM).
- [ ] **DPA signed** with each (responsibilities, security, breach handling, retention).
- [ ] Sharing disclosed in the privacy policy.

## Output
A gap report: per item — status, evidence (`file:line`), remediation, priority. End with the
**legal items needing DPO/lawyer sign-off** (legal bases, retention periods, DPA terms).
