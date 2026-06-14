# Cookies, Analytics & Error Tracking (the part apps get wrong)

Monitoring tools are the most common source of **unconsented personal-data leakage**. IPs and
browser data tied to a user are personal data under the LGPD.

## Real opt-in consent (ANPD cookie guide, out/2022)
A banner that only **warns** while GA4/Pixel already loaded is **non-compliant**. Requirements:
- **Trackers load ONLY after the user clicks "Aceitar"** — not in `<head>` on page load. Gate the
  script injection behind the consent state.
- **"Recusar" as easy/visible as "Aceitar"** — same size/prominence; both on the 1st-level banner.
- **Non-essential cookies OFF by default**; offer **"Gerenciar/Selecionar"** for granular choice.
- **Revocable** — a 2nd-level banner / a "Preferências de cookies" link lets the user change later.
- Essential cookies (session/auth/security) don't need consent; everything else (analytics,
  marketing) does.

### Implementation pattern
```
state = readConsent()            // from a 1st-party cookie: {essential:true, analytics:?, marketing:?}
if (!state) showBanner()          // Aceitar tudo | Recusar não-essenciais | Gerenciar
onAccept(categories) =>
  persistConsent(categories)
  if (categories.analytics) loadGA4()     // inject the script ONLY now
  if (categories.marketing) loadPixel()
// "Preferências" reopens the manager → can flip analytics off → stop/re-init trackers
```
Use a CMP (consent manager) or a small first-party implementation — but the **gating** (load after
consent) is the non-negotiable part, not the banner UI.

## IP & browser data — anonymize
- Don't store/log raw IPs. **Truncate** (drop the last octet/segment) or **hash with a salt**.
- GA4: enable IP anonymization / avoid sending identifiers without consent.
- Don't tie click/usage logs to a raw IP + identity.

## Error tracking (Sentry et al.)
- **`sendDefaultPii: true` exports PII** — request headers, cookies, session, user ip — to a third
  party **without consent**. Set **`sendDefaultPii: false`**.
- Scrub PII before send (`beforeSend`): strip auth headers, tokens, emails, bodies. Use server-side
  data scrubbing / allowlists.
- Same logic for any APM/RUM/session-replay tool — replay especially can capture form inputs;
  mask them.

## Audit signals to grep
`gtag(` · `google-analytics` · `fbq(` · `facebook.*pixel` · `<script.*analytics` in `<head>` ·
`sendDefaultPii` · `Sentry.init` · logging of `req.ip`/`X-Forwarded-For` · `document.cookie` writes
before consent. Each hit → check it's gated/scrubbed.
