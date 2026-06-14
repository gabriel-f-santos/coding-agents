# House CI Patterns

Our reference CI (from `greenfield-monorepo/references/precommit-and-ci.md`) — polyglot, path-
scoped, secure. Reuse these shapes; for a brand-new repo, `greenfield-monorepo` scaffolds the lot.
(cota8-smart-chat has **no** GHA yet — frontend deploys via Cloudflare `wrangler`, backend via
Docker — so this is the house template, not a copy of cota8.)

## Structure
- A **`changes`** job (`dorny/paths-filter@<sha>`) computes which app changed; per-language jobs
  gate on it (`needs: changes`, `if: needs.changes.outputs.<app> == 'true'`).
- Per-language jobs: install **from the lockfile** (`npm ci`, `uv sync --frozen`,
  `pnpm install --frozen-lockfile`), then lint + test.
- A **`pre-commit`** job as backstop (`pre-commit/action@<sha>`) — runs the same hooks CI-side.
- **`gitleaks`** job (secrets) + **`osv-scan`** job (known-vulnerable AND malicious deps).
- Top-level `permissions: { contents: read }`; `concurrency` cancel-in-progress.

## Skeleton
```yaml
name: CI
on: { pull_request: {}, push: { branches: [main] } }
permissions: { contents: read }
concurrency: { group: "ci-${{ github.ref }}", cancel-in-progress: true }
jobs:
  changes:
    runs-on: ubuntu-latest
    outputs: { web: "${{ steps.f.outputs.web }}", api: "${{ steps.f.outputs.api }}" }
    steps:
      - uses: actions/checkout@<sha>  # v5
      - uses: dorny/paths-filter@<sha>  # v4
        id: f
        with: { filters: "web: ['apps/frontend-app/**']\napi: ['apps/backend-app/**']" }
  web:
    needs: changes
    if: ${{ needs.changes.outputs.web == 'true' }}
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: apps/frontend-app } }
    steps:
      - uses: actions/checkout@<sha>  # v5
      - uses: actions/setup-node@<sha>  # v4
        with: { node-version: '22', cache: 'npm', cache-dependency-path: apps/frontend-app/package-lock.json }
      - run: npm ci
      - run: npm run lint
      - run: npm test
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>  # v5
        with: { fetch-depth: 0 }
      - uses: gitleaks/gitleaks-action@<sha>  # v2
        env: { GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}", GITLEAKS_CONFIG: .gitleaks.toml }
  osv-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>  # v5
      - uses: google/osv-scanner-action/osv-scanner-action@<sha>  # v2
        with: { scan-args: "-r --skip-git ./" }
```
(SHAs shown as `<sha>` — resolve the real pin for the version comment; Renovate keeps them current.)

## Notes
- `${{ }}` here is in `if:`/`with:`/`concurrency` → safe (runtime-evaluated, not shell).
- Add `go`/`mobile` jobs analogously; keep each path-scoped.
- Supply-chain: commit lockfiles, dependency cooldown (`minimumReleaseAge: 10 days`) — see
  `greenfield-monorepo`.
- Deploy is a **separate** workflow (`deploy.md`), not bolted onto this CI.
