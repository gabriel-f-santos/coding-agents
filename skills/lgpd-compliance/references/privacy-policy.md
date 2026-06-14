# Privacy Policy & Data Inventory

The privacy policy is the public contract with titulares. It must be **easy to find** (footer +
signup flow), **specific** (per-datum legal basis + purpose), and **true** (match what the code
actually does). Build it from a **data inventory**, not boilerplate.

## Data inventory (do this first)
Map every datum the app collects:

| Datum | Classe | Base legal (art. 7/11) | Finalidade | Origem | Compartilhado com | Retenção/TTL |
|---|---|---|---|---|---|---|
| e-mail | pessoal | execução de contrato | login, notificações | cadastro | provedor de e-mail | enquanto conta ativa |
| IP / cliques | pessoal (uso) | consentimento (analytics) | métricas | navegação | GA4 | 14 meses (anonimizado) |
| dado de saúde | **sensível** | consentimento específico | … | … | … | … |

Derive the inventory from the real code/DB (`Step 1` of the skill) — schemas, analytics calls,
third-party SDKs — not from imagination.

## What the policy must contain
1. **Quais dados** são coletados, classificados (pessoal / uso / **sensível**).
2. **Base legal + finalidade** de cada tratamento (specific, not "para melhorar serviços").
3. **Compartilhamento com terceiros** — quem recebe (pagamento, analytics, CRM), por quê,
   salvaguardas. → `dpa-third-parties.md`
4. **Retenção e descarte** — prazo (TTL) por categoria; dados não ficam indefinidamente.
5. **Direitos do titular** — como exercê-los (link pros recursos self-service + canal do DPO).
6. **Cookies** — categorias e como gerenciar consentimento. → `cookies-and-analytics.md`
7. **Contato do DPO/Encarregado** — um e-mail real para solicitações.
8. **Atualizações** — como mudanças são comunicadas; data da última revisão.

## Accessibility
- Link in the **footer** of every page **and** in the **signup/cadastro** flow (consent point).
- Plain language; a layered summary on top is good UX.

## Generate
Scaffold from `assets/templates/privacy-policy.md.tpl`, filled from the data inventory. Mark every
**legal basis, retention period, and DPO identity** as **"(confirmar com DPO/jurídico)"** — those
are legal decisions, not the agent's. The Terms of Use is a separate document; note if it's missing.
