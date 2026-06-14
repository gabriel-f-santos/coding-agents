---
name: review-functionality
description: >
  Review implemented code for conformance to a phase/feature contract and for correctness bugs.
  Use to check that what was built actually meets its acceptance criteria — "revisa se a feature
  faz o que devia", "conformance review", "review against the spec", "achou bug na fase?". Reads
  the phase contract (acceptance criteria, deliverables) + the diff and reports, confidence-based,
  whether each criterion is met and any correctness defects (logic, edge cases, error paths,
  concurrency). Read-only — reports findings, does not fix. Designed to run standalone or as a
  subagent of review-phase. Do not use for security (review-security) or style/cleanup
  (review-quality).
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *)
---

# review-functionality — does it do what the contract says?

Review the changed code against the **phase contract**, not in a vacuum. The differentiator vs a
generic code review: every finding ties back to an **acceptance criterion** or a concrete
correctness defect.

## Inputs

- The **contract**: `docs/phases/phase-NN-<slug>.md` — Objective, each SI's **acceptance
  criteria** and **deliverables**. (As a subagent, you receive the relevant excerpt.)
- The **change set**: the files/diff to review (`git diff`).

## What to check

### 1. Conformance (against the contract)
- For **each acceptance criterion**: is it actually implemented and satisfied by the changed
  code? Quote the criterion; cite the code that meets it — or flag it **unmet/partial**.
- Are all **deliverables** present (files, endpoints, migrations, tests the SI promised)?
- **Scope drift:** anything implemented that the contract didn't ask for (note it), or a
  criterion silently skipped.

### 2. Correctness (defects in the changed code)
- **Logic:** off-by-one, inverted conditions, wrong operator, incorrect default.
- **Edge cases:** empty/null/huge inputs, boundary values, unicode, timezones, money rounding.
- **Error paths:** unhandled failure, swallowed exceptions, partial writes without rollback,
  missing transaction around multi-step mutations.
- **Concurrency/idempotency:** races, double-submit, retried-but-not-idempotent operations,
  lost updates.
- **Contracts:** does the change break a caller, an API/wire format, or a DB constraint
  (uniqueness, length) reachable with legitimate input?
- **State & side effects:** related entities updated/cascaded correctly; derived values can't
  collide or overflow.

## Confidence & output

Report **HIGH** only (clear issue confirmed in the changed code); **MEDIUM** as "needs
verification"; **drop LOW**. For each finding return:
`{dimension: functionality, severity, confidence, file:line, acceptance_criterion (quoted, if
conformance), issue, evidence, why_it_matters, fix}`.

Lead with **failed/partial acceptance criteria** (these are the highest-value findings), then
correctness defects. If everything conforms and you find no defects, say so plainly — don't
invent findings.
