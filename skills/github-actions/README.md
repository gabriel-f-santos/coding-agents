# github-actions

Generate and secure **GitHub Actions** workflows — scaffold CI/CD from an interview, or audit
existing workflows for exploitable vulnerabilities. Security is baked in, not bolted on.

## When to use
"criar workflow", "github actions", "pipeline CI/CD", "workflow de deploy", "configurar deploy no
push da main", "set up CI", "revisar segurança do workflow", "audit workflows", "GHA security".

## Modes
- **Generate** — interviews the pipeline shape (lint/test/build/deploy; trigger on **PR/MR** vs
  **push main** vs **tag**; deploy target + approval) and writes **secure-by-default** workflows:
  least-privilege `GITHUB_TOKEN`, actions **pinned to SHA**, **no `${{ }}` in `run:`**, OIDC deploy,
  `concurrency`, path filters, gitleaks/osv + dependency cooldown.
- **Review** — exploitation-focused audit (pwn request, expression injection, comment-triggered
  commands, credential escalation, config poisoning, supply chain) with concrete attack paths,
  external-attacker threat model, HIGH/MEDIUM only.

## Typical pipeline split
PR/MR → **checks** (lint/test/build, read-only, no secrets). Push `main`/tag → **build + deploy**
(gated by a GitHub Environment, OIDC). Never deploy on `pull_request`.

## Chains with
`greenfield-monorepo` (full house CI for a new repo) · `review-security` (broader security pass) ·
`commit-message` (Conventional Commits).

## Credit
The security-review art is adapted from Sentry's
[`gha-security-review`](https://github.com/getsentry/skills/tree/main/skills/gha-security-review)
(real-world cases from StepSecurity's HackerBot Claw analysis). See repo `CREDITS.md`.

## Install
`cp -r github-actions ~/.claude/skills/` (Claude Code + opencode) or `.codex/skills/` (Codex). Portable; see PORTABILITY.md.
