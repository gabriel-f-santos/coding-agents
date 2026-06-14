# Deploy Workflows

Deploy runs on **push to `main`** (or a **tag**), **never on `pull_request`**, and is **gated by a
GitHub Environment** (manual approval + scoped secrets). Prefer **OIDC** over long-lived secrets.

## Shape
```yaml
on: { push: { branches: [main] } }          # or tags: ['v*']
concurrency: { group: deploy-main, cancel-in-progress: false }   # don't cancel a deploy mid-flight
permissions: { contents: read, id-token: write }   # id-token only for OIDC
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production                  # ← approval gate + environment secrets
    steps:
      - uses: actions/checkout@<sha>  # v5
      - # build…
      - # deploy step (target-specific, below)
```
- **`environment:`** is the key control — required reviewers, wait timers, and secrets scoped to
  that environment (not exposed to PR/check runs).
- **`cancel-in-progress: false`** for deploys (cancelling a half-done deploy is worse than queuing).

## OIDC over secrets (cloud targets)
Long-lived cloud keys in repo secrets are a standing liability. Use **OIDC**: the workflow requests
a short-lived token the cloud trusts (configure a trust policy on the cloud side).
- **AWS:** `aws-actions/configure-aws-credentials@<sha>` with `role-to-assume` + `id-token: write`.
- **GCP:** `google-github-actions/auth@<sha>` (Workload Identity Federation).
- **Azure:** `azure/login@<sha>` with federated credentials.

## Targets
- **Cloudflare Workers/Pages** (e.g. cota8's frontend uses `wrangler.toml`): `cloudflare/wrangler-action@<sha>`
  with `CLOUDFLARE_API_TOKEN` (scoped, environment secret) — set `compatibility_date`; secrets via
  `wrangler secret`, never in `vars`.
- **Docker image** (e.g. cota8's backend `Dockerfile`): build + push to a registry
  (`docker/build-push-action@<sha>`, login via OIDC/registry token), then the host (Coolify/k8s)
  pulls — or trigger the host's deploy webhook. Keep registry creds as environment secrets.
- **Static/SSG:** deploy to Pages with the official Pages action + `environment`.

## Gating & safety
- Require approval via the environment for `production`; auto-deploy a `staging` environment on
  push if desired.
- **Smoke check after deploy** (health endpoint) and a documented rollback (redeploy previous SHA).
- Tag the release (`v*`) so a rollback target is explicit.
- Deploy job needs only `contents: read` (+ `id-token: write` for OIDC) — nothing else.

## Don't
- No deploy on `pull_request`/`pull_request_target`. No long-lived cloud keys when OIDC is
  available. No secrets in `vars`/logs. No unpinned deploy actions.
