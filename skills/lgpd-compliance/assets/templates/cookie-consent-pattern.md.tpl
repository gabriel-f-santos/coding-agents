# Cookie Consent — pattern + acceptance criteria

A reference for implementing **real opt-in** (ANPD guide). Adapt to the stack; the gating is the
non-negotiable part.

## Acceptance criteria (test these)
- [ ] No analytics/marketing script runs before "Aceitar" (check Network on first load — only
      essential cookies set).
- [ ] "Recusar não-essenciais" is as visible/easy as "Aceitar" on the 1st-level banner.
- [ ] Non-essential categories are **off by default** in "Gerenciar".
- [ ] Consent persists (1st-party cookie/localStorage) and is **revocable** via a "Preferências" link.
- [ ] Revoking analytics actually stops/unloads the tracker.

## Shape
```
// categories: essential (always) | analytics | marketing
const consent = readConsent();                 // null on first visit
if (!consent) renderBanner({                    // 3 actions, equal weight:
  onAcceptAll, onRejectNonEssential, onManage   // "Aceitar tudo" | "Recusar" | "Gerenciar"
});

function applyConsent(c) {
  saveConsent(c);                               // {essential:true, analytics, marketing, ts, policyVersion}
  if (c.analytics) loadAnalytics();             // inject GA4 ONLY here
  else unloadAnalytics();
  if (c.marketing) loadPixel(); else unloadPixel();
}

// "Preferências de cookies" link (footer/settings) re-opens the manager → applyConsent(updated)
```

## Notes
- Essential = session/auth/CSRF/load-balancing — no consent needed.
- Record `policyVersion` + timestamp with the consent (proof of when/what).
- GA4: also enable IP anonymization; never send user identifiers without consent.
- Prefer a vetted CMP if you have many tags — but verify it actually **gates** (some only style a banner).
