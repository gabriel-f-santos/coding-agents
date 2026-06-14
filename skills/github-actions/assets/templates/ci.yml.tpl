# .github/workflows/ci.yml — checks on PR (read-only token, no secrets). Secure by default.
name: CI
on:
  pull_request: {}
  push: { branches: [main] }            # also run on main to keep it green
permissions:
  contents: read                        # least privilege
concurrency:
  group: "ci-${{ github.ref }}"
  cancel-in-progress: true
jobs:
  {{app}}:
    runs-on: ubuntu-24.04               # pinned runner
    timeout-minutes: 15
    # defaults: { run: { working-directory: {{app-path}} } }
    steps:
      - uses: actions/checkout@{{sha}}            # v5  (PIN to a real SHA)
      - uses: actions/setup-node@{{sha}}          # v4
        with: { node-version: '22', cache: 'npm' }
      - run: npm ci                                # install FROM the lockfile (not npm install)
      - run: npm run lint
      - run: npm test
      # ❌ never: run: echo "${{ github.event.pull_request.title }}"   (expression injection)
      # ✅ if you need it:  env: { TITLE: ${{ github.event.pull_request.title }} }  then  "$TITLE"
  # gitleaks + osv-scan jobs: see references/ci-house-example.md
