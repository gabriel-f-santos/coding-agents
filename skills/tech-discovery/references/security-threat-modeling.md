# Security & Threat Modeling (STRIDE)

Threat-model at design time — uncovering threats now is far cheaper than post-incident rework.
Work over the architecture you just drew (the data-flow and trust boundaries), not in the
abstract.

## Set the security frame first

- **AuthN** — how users/services prove identity (sessions, JWT, mTLS, API keys).
- **AuthZ** — who can do what; tenancy isolation (every query scoped to the tenant, enforced
  centrally, not per-handler). Name the model (RBAC/ABAC/ownership checks).
- **Sensitive data** — classify it: PII, financial, health, secrets. Where it's stored, encrypted
  (at rest / in transit), who can read it, retention/erasure.
- **Compliance** — LGPD/GDPR/HIPAA/SOC2 obligations that constrain the design (data residency,
  consent, audit, right-to-erasure).

## STRIDE over the trust boundaries

Draw the data-flow (who calls what, crossing which trust boundary), then walk each element
through STRIDE:

| Threat | Question | Typical control |
|---|---|---|
| **S**poofing | can an attacker impersonate a user/service? | strong authN, signed tokens, mTLS |
| **T**ampering | can data be altered in transit/at rest? | TLS, integrity checks, least-privilege writes |
| **R**epudiation | can someone deny an action? | audit logs, signed events |
| **I**nformation disclosure | can data leak (incl. cross-tenant)? | authZ, tenant scoping, encryption, minimal responses |
| **D**enial of service | can it be overwhelmed/made costly? | rate limits, quotas, timeouts, backpressure |
| **E**levation of privilege | can a user gain more rights? | authZ checks at every boundary, deny-by-default |

Focus on **trust boundary crossings** — public→app, app→DB, app→third-party, tenant→tenant.
Those are where real, exploitable threats live.

## Cross-tenant & IDOR (the SaaS classic)

For multi-tenant systems, the dominant risk is **cross-tenant access / IDOR**: a request reading
or writing another tenant's data by changing an ID. Decide the central enforcement point now
(every read/write filtered by the resolved tenant), not as a per-endpoint afterthought. If a
`sentry-security-review` or `auth-e2e-audit` skill exists, plan to run it against the build.

## Turn threats into requirements

Each material threat becomes a security NFR / acceptance criterion (e.g. "unauthenticated call
to a `*-wa` endpoint returns 401 and performs no write"). These flow into the PRD's acceptance
criteria and the plan's tests.

## Output into the brief

- AuthN/AuthZ model + tenancy isolation approach.
- Sensitive-data classification + protection + compliance constraints.
- A STRIDE table over the trust boundaries with the chosen controls.
- The resulting security requirements (testable) and any spike for an unproven control.
