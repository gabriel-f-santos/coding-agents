# Secure by Default (apply at generation time)

Every workflow this skill generates must ship with these defaults — security isn't a later review,
it's the baseline. (Same controls the REVIEW mode checks for; here we *bake them in*.)

## 1. Least-privilege `GITHUB_TOKEN`
The single most effective mitigation. Default the token to read-only at the **workflow** top; grant
the minimum extra **per job** that needs it.
```yaml
permissions:
  contents: read          # workflow default
jobs:
  release:
    permissions:          # elevate only here
      contents: write     # e.g. to create a release/tag
```
Never leave permissions implicit (inherits the repo default, often read/write).

## 2. Pin third-party actions to a full SHA
Tags (`@v4`, `@main`) are mutable — a compromised action upstream becomes your RCE.
```yaml
- uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8  # v5.0.0
```
First-party `actions/*` by SHA too for high-security repos. Keep the `# vX.Y` comment so updates are
legible. (Renovate/Dependabot can bump the SHA + comment.)

## 3. No `${{ }}` in `run:` blocks
The runtime substitutes the expression **before** the shell runs → shell metacharacters in an
attacker-controlled value execute. Pass via `env:` and reference the shell var (quoted):
```yaml
# ❌ VULNERABLE
- run: echo "Title: ${{ github.event.pull_request.title }}"
# ✅ SAFE
- env: { TITLE: ${{ github.event.pull_request.title }} }
  run: echo "Title: $TITLE"
```
`${{ }}` is safe in `if:`, `with:`, and job-level `env:` (runtime-evaluated, not shell). It's only
dangerous inside `run:`.

## 4. Right trigger for the job
- **Checks** → `on: pull_request` (read-only token, fork context). **Never** `pull_request_target`
  + checkout of fork code (that's a pwn request → RCE with the base-repo token).
- **Deploy/secrets** → `push`/`tag` on protected branches (require write access to trigger).

## 5. Operational guards
- `concurrency: { group: ..., cancel-in-progress: true }` (false for deploys).
- `timeout-minutes:` on every job (cap runaway/abuse).
- **Path filters** (`paths:` or `dorny/paths-filter`) so jobs run only when relevant files change.
- **Pin the runner** (`runs-on: ubuntu-24.04`, not floating `ubuntu-latest`, for reproducibility in
  security-sensitive repos).

## 6. Secrets hygiene
- Scope secrets to an **environment**; don't expose them to PR/check runs.
- Never `echo` a secret; never put secrets in `vars`; mask anything derived.
- Prefer **OIDC** for cloud deploys (no long-lived keys) → `deploy.md`.

## 7. Supply-chain on deps too
Wire `gitleaks` + `osv-scanner` jobs and a dependency **cooldown** (`minimumReleaseAge`) — see
`ci-house-example.md` / `greenfield-monorepo`. Unpinned deps are the other half of supply chain.

## Self-check
After generating, run the REVIEW checklist (`security-review.md`) against your own output. A
workflow that fails its own audit doesn't ship.
