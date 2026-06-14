# Third Parties & DPA (Operadores)

Every external service that touches your users' personal data is an **operador** processing on your
behalf — you stay the **controlador** and remain accountable for their failures unless governed by a
**DPA**.

## Map the operadores
List every third party that receives/stores/processes personal data:
- **Hosting / cloud** (servers, DB, object storage)
- **E-mail / marketing** (transactional + campaigns)
- **Payments** (processor/gateway)
- **Analytics / ads** (GA4, Pixel, CRM)
- **Error/observability** (Sentry, APM, logs)
- **Support / chat**, **auth providers**, any SDK that phones home.

For each: what data it gets, why, where (data residency), and its **subprocessors**.

## DPA (Data Processing Agreement / Acordo de Tratamento)
Strongly recommended with each operador. It must set:
- **Roles** (controlador ↔ operador) and the **scope/purpose** of processing — operator acts only on
  your instructions.
- **Security measures** required of the operator.
- **Retention & deletion** — how long, and return/delete on contract end.
- **Breach handling** — the operator must **notify you** promptly so you can meet your obligations.
- **Subprocessors** — disclosure + your approval; flow-down of the same obligations.
- **Data-subject requests** — the operator assists you in fulfilling art. 18 requests.

Most major vendors publish a DPA you can accept/sign — collect and store them. Scaffold your own for
smaller vendors from `assets/templates/dpa.md.tpl`.

## Disclose the sharing
Every operador that receives personal data must appear in the **privacy policy** (who, what, why,
safeguards) — see `privacy-policy.md`. Hidden sharing is a top cause of complaints.

## Audit signal
Grep the codebase + `package.json`/`pyproject` + env for third-party SDKs and API keys; cross-check
each against "has a DPA?" and "is it disclosed in the policy?". A vendor with PII access, no DPA, and
no disclosure → **P1 gap**.
