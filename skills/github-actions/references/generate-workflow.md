# Generate a Workflow — interview → assemble

The pipeline shape is the **user's decision** — interview, don't assume. Ask one question at a
time, each with a recommended default and a one-line why; calibrate to their experience. Then
assemble from the secure skeleton.

## The interview (the forks that matter)

1. **What should run?** (multi-select)
   - `lint` · `type-check` · **`test`** · `build` · `security scan` (gitleaks + osv) · `deploy`.
   - *(Recomendado: lint + test + build. Add `deploy` only if this repo ships from CI.)*
2. **On which trigger?** (this is the big one)
   | Trigger | YAML | What belongs here |
   |---|---|---|
   | **Pull Request / MR** *(Recomendado for checks)* | `on: pull_request` | lint/test/build — **read-only** token, runs in fork context, **no secrets** |
   | **Push to `main`** | `on: { push: { branches: [main] } }` | integration + **deploy** |
   | **Tag / release** | `on: { push: { tags: ['v*'] } }` | release/deploy |
   | **Manual** | `workflow_dispatch` | ops/one-off |
   - **Default split:** PR → checks (no secrets); push-main (or tag) → build + deploy. **Never put
     deploy on `pull_request`.**
3. **Deploy?** if yes → target, environment, **approval gate**, OIDC vs secret → `deploy.md`.
4. **Monorepo?** path filters (`dorny/paths-filter`) so each app's jobs run only when its paths
   changed (mirror the `paths-filter` ↔ job map; see `ci-house-example.md`).
5. **Matrix?** multiple Node/Python/OS versions? (default: single current version unless they
   support many).

Record the answers as a short plan (triggers → jobs → secrets/permissions) and confirm before
writing if anything is destructive or ambiguous.

## Assemble (per chosen trigger)

- **Checks workflow** (`ci.yml`, `on: pull_request`): `permissions: contents: read`, the chosen
  check jobs, `concurrency`, path filters, caching, `timeout-minutes`. No secrets.
- **Deploy workflow** (`deploy.yml`, `on: push main`/tag): build + deploy job gated by an
  `environment:`; OIDC; minimal extra permissions (`id-token: write` for OIDC, `contents: read`).
- Keep them **separate files** (different triggers, different blast radius) rather than one mega
  workflow with `if:` everywhere.

## Always apply (from `secure-by-default.md`)
Minimal `permissions`, **actions pinned to SHA**, **no `${{ }}` in `run:`** (use `env:`),
`concurrency`, `timeout-minutes`, and `pull_request` (not `_target`). The generated workflow must
pass the REVIEW checklist — self-audit before finishing.

## House patterns
Reuse `ci-house-example.md` (paths-filter + per-language jobs + pre-commit backstop + gitleaks/osv
+ dependency cooldown). For a brand-new repo, `greenfield-monorepo` scaffolds the whole harness.
