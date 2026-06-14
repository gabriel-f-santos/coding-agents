# Security & Privacy by Design (technical controls)

Security is an LGPD obligation (medidas técnicas e administrativas). Build it in by default. Much of
this overlaps our `review-security`, `tech-discovery` (STRIDE) and `greenfield-monorepo` (CI
gitleaks/SAST) — reuse them; this is the privacy-facing subset.

## Authentication & access
- **MFA** available, and required for sensitive/admin roles.
- **Least privilege** — every role/query scoped to what it needs; for multi-tenant, every read/write
  filtered by the resolved tenant (cross-tenant/IDOR is the classic leak — see `review-security`).
- **Anti-brute-force** — lockout or rate-limit after N failed logins; throttle password reset.
- **Social login (OAuth)** — at consent, disclose exactly which fields you pull (nome, foto, e-mail)
  and why; request the **minimum scopes**.

## Cryptography
- **In transit:** TLS 1.3 (reject downgrade); HSTS.
- **At rest:** AES-256 for sensitive fields/DB; manage keys properly (KMS, not in code).
- **Passwords:** one-way hash with **argon2id** (or bcrypt) + per-user salt. Never reversible
  encryption, never plaintext.
- **Tokens:** unpredictable (CSPRNG); short-lived; rotate refresh tokens.

## Vulnerability management
- **SAST** (static) + **DAST** (dynamic) in CI across prod/stage/dev; keep deps patched (Dependabot
  / `pip-audit` / `npm audit`). Watch for SQL injection, CSRF, XSS.
- This is the same gate as `greenfield-monorepo`'s CI + `review-security`'s diff pass — wire them.

## Logs & audit
- Keep **auditable, append-only** access logs (who did what, when).
- **Never log** secrets/PII: no passwords, tokens, session ids, raw IPs, request bodies with PII.
  Scrub before logging; mask IPs (truncate/hash).
- Set **retention/TTL** on logs too — they're personal data when they contain identifiers.

## Data minimization & retention
- Collect only what the **purpose** needs; don't keep "just in case".
- Every datum has a **TTL**; purge or anonymize on expiry (and on account deletion). Confirm periods
  with DPO/jurídico.

## Output
For each control: status (✅/⚠️/❌), evidence (`file:line` / config), remediation. Hand the broader
code-level security pass to `review-security`; reshape architecture via `tech-discovery` if
privacy-by-design needs structural change.
