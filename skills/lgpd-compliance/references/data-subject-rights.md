# Implementing Data-Subject Rights (Art. 18)

Turn the legal rights into real, **self-service** features. A request channel (DPO e-mail) is the
floor; self-service is the bar.

## Account & data deletion (cascade)
- A **visible "Excluir conta"** in settings — not hidden, not support-only.
- **Cascade** the delete across every table holding the user's data (orders, comments, logs tied to
  them, uploads, sessions, tokens, analytics rows keyed by user). An orphan-leaving delete isn't
  deletion.
- Decide **hard vs soft delete**: legal/financial records may have a **retention obligation** (then
  anonymize instead of delete, and document why). Confirm retention with DPO/jurídico.
- Run it in a **transaction**; confirm to the user; purge backups per your retention policy.
- Implementation gotcha: foreign keys with `ON DELETE` set, or an explicit deletion service that
  walks the graph; verify nothing is missed (grep for `user_id`/`tenant_id` references).

## Data export / portability
- An **"Exportar meus dados"** action → produces a **structured** file (JSON/CSV) of the user's
  personal data, delivered securely (authenticated download / e-mailed signed link, expiring).
- Include what you hold *about them*; exclude other users' data and internal secrets.
- Can be sync (small) or an async job (large) that notifies when ready.

## Consent revocation & preferences
- A **"Privacidade / Preferências"** screen to: toggle cookie/marketing consent, unsubscribe from
  lists, and revoke optional processing — **anytime**, as easily as it was given.
- Revoking consent must **actually stop** the processing it gated (disable the tracker, drop from
  the mailing list) and be **recorded** (when, what).
- Store a **consent record** per user: which purpose, base legal, timestamp, version of the policy.

## Access & correction
- Let the user **view** their profile/data and **edit** it. Surface what's processed and why.

## Verify (don't trust the button exists)
For each right, trace the code path end-to-end: does "delete" really cascade? does "export" include
everything? does "revoke" stop the tracker? Cite the files; flag any right that's UI-only with no
real effect as a **P1 gap**.
