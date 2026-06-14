---
name: github-actions
description: >
  Generate and secure GitHub Actions workflows. Use to scaffold or review CI/CD — "criar
  workflow", "github actions", "pipeline CI/CD", "workflow de deploy", "gera o GHA", "configurar
  deploy no push da main", "set up CI", "revisar segurança do workflow", "audit workflows", "GHA
  security review". GENERATE mode interviews the pipeline shape (lint/test/build/deploy; trigger on
  PR/MR vs push-to-main vs tag; deploy target + approvals) and writes secure-by-default workflows
  (least-privilege GITHUB_TOKEN, third-party actions pinned to SHA, no ${{ }} in run: blocks, OIDC
  deploy, concurrency, path filters, dependency cooldown/osv). REVIEW mode audits existing
  .github/workflows for exploitation vulns (pwn request, expression injection, comment-triggered
  commands, credential escalation, supply chain) with concrete attack paths — security art adapted
  from Sentry's gha-security-review. Do not use for non-GitHub CI (GitLab/CircleCI) or to write app
  code.
allowed-tools: Read Grep Glob Write WebSearch Task
license: MIT
metadata:
  author: skill-gen
  grounded: "2026-06-14"
---

# github-actions — generate & secure GHA workflows

Scaffold CI/CD workflows from an interview, or review existing ones for exploitable
vulnerabilities. **Security is not a separate step** — generated workflows are secure by default,
and the review mode encodes real attack patterns (adapted from Sentry's `gha-security-review`).

## Modes (detect intent)
| The user wants… | Run | Primary references |
|---|---|---|
| to **create/scaffold** a workflow (CI / test / deploy) | interview → generate | `references/generate-workflow.md` (+ `deploy.md`, `secure-by-default.md`) |
| to **review/audit** existing workflows for vulns | exploitation review | `references/security-review.md` |

## References (load only what the step needs)
| Open when you need to… | Read |
|---|---|
| interview the pipeline shape and assemble the workflow | `references/generate-workflow.md` |
| wire a deploy (environments, OIDC, gating, approvals) | `references/deploy.md` |
| apply the security defaults at generation time | `references/secure-by-default.md` |
| audit existing workflows for exploitation (review mode) | `references/security-review.md` |
| copy our house CI patterns (paths-filter, per-lang jobs, gitleaks/osv) | `references/ci-house-example.md` |
| start from a secure skeleton | `assets/templates/` |

---

## GENERATE — workflow

### Step 1 — Ground in the repo
`ls .github/workflows/`, read any existing workflow, and detect the stack (manifests, lockfiles,
test/build scripts) so the generated jobs match reality. Reuse our house patterns →
`references/ci-house-example.md` (and `greenfield-monorepo` if scaffolding a new repo).

### Step 2 — Interview the pipeline (ask, one at a time, with a recommended default)
The shape is the user's call — ask, don't assume (calibrate to their experience). Cover:
1. **What runs?** lint · type-check · **test** · build · security scan (gitleaks/osv) · deploy.
   *(Recomendado: lint + test + build; add deploy only if they ship from here.)*
2. **On which trigger?**
   - **Pull Request / MR** → `on: pull_request` (read-only token, runs in fork context) — checks
     only (lint/test/build). *(Recomendado for the validation pipeline.)*
   - **Push to `main`** → `on: push: branches: [main]` — the integration/deploy line.
   - **Tag / release** → `on: push: tags: ['v*']` — release/deploy.
   - **Manual** → `workflow_dispatch`.
3. **Deploy?** if yes → target (Cloudflare/AWS/etc.), environment, **approval gate**, OIDC vs
   secret. → `references/deploy.md`
4. **Monorepo?** path filters per app (`dorny/paths-filter`) so jobs run only on changed paths.

> Typical split: **PR → checks** (lint/test/build, no secrets); **push main → build + deploy**
> (with environment protection). Don't put deploy on `pull_request`.

### Step 3 — Generate (secure by default)
Write the workflow(s) from `assets/templates/`, applying **every** default in
`references/secure-by-default.md`:
- `permissions:` minimal at top (`contents: read`), elevate per-job only where needed.
- **Pin third-party actions to a full commit SHA** (`uses: owner/action@<sha> # vX`).
- **No `${{ }}` in `run:` blocks** — pass attacker-controllable values via `env:` and reference
  `"$VAR"`. Never use `pull_request_target` + checkout of fork code.
- `concurrency:` to cancel superseded runs; `timeout-minutes:`; path filters.
- Deploy on push-main/tag only, gated by an **environment** (approval), via **OIDC** (no
  long-lived cloud secrets).

### Step 4 — Self-review & report
Run the REVIEW checklist (below) against what you just generated — a generated workflow must pass
its own audit. Report the files, the trigger→job map, the secrets/permissions used, and the manual
steps (set up the environment, OIDC trust, required secrets).

---

## REVIEW — existing workflows

Read `references/security-review.md` and audit `.github/workflows/*`, `action.yml`, local actions.
**Threat model:** only report what an **external attacker without write access** can exploit
(fork PRs, issues, comments). Fan out with subagents per workflow when available. Every HIGH
finding needs the full **attack path** (entry → payload → execution → impact → PoC); report HIGH +
MEDIUM only, never theoretical. Output the findings with concrete fixes (see the reference for the
report format). If nothing is exploitable, say so — don't invent issues.

## Cross-cutting gotchas
- **`pull_request` ≠ `pull_request_target`** — the latter runs with a read/write token in the base
  repo context; checking out fork code under it = remote code execution (pwn request).
- **`${{ }}` is shell-dangerous only in `run:`** — safe in `if:`, `with:`, and job-level `env:`.
- **Unpinned actions are supply chain risk** — `@v4`/`@main` are mutable; pin to SHA.
- **Least privilege is the #1 mitigation** — default the token to `contents: read`.
- **Secrets never reach untrusted code** — no secrets on `pull_request`/fork-triggered jobs.
