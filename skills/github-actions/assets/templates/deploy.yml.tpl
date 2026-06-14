# .github/workflows/deploy.yml — deploy on push main (or tag), gated by an environment. OIDC preferred.
name: Deploy
on:
  push: { branches: [main] }            # or: tags: ['v*']
permissions:
  contents: read
  id-token: write                       # ONLY for OIDC; drop if not using OIDC
concurrency:
  group: deploy-{{env}}
  cancel-in-progress: false             # never cancel a deploy mid-flight
jobs:
  deploy:
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    environment: {{environment}}        # ← approval gate + environment-scoped secrets
    steps:
      - uses: actions/checkout@{{sha}}            # v5  (PIN)
      # --- build ---
      - # {{build steps}}
      # --- deploy (pick one) ---
      # Cloudflare Workers/Pages:
      # - uses: cloudflare/wrangler-action@{{sha}}   # v3
      #   with: { apiToken: "${{ secrets.CLOUDFLARE_API_TOKEN }}" }   # environment secret
      # AWS via OIDC (no long-lived keys):
      # - uses: aws-actions/configure-aws-credentials@{{sha}}  # v4
      #   with: { role-to-assume: "${{ vars.DEPLOY_ROLE_ARN }}", aws-region: {{region}} }
      # Docker image → registry (host pulls):
      # - uses: docker/build-push-action@{{sha}}     # v6
      - # smoke check the deployed health endpoint, then done
