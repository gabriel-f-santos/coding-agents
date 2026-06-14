---
name: review-phase
description: >
  Review a just-implemented phase/feature across functionality, security, and quality by
  fanning out three reviewers as subagents, scoped to the phase contract. Use after building
  something — "revisa a fase", "review phase X", "code review da feature", "revisa o que foi
  implementado", "revisão da phase-NN". Reads docs/phases/phase-NN-<slug>.md (acceptance
  criteria, deliverables) + the diff, runs review-functionality, review-security and
  review-quality (parallel subagents when available), de-dupes and prioritizes findings P0/P1/P2,
  prints a summary to screen and writes the full report to a gitignored artifacts path. Do not
  use for live UI/runtime smoke (use e2e-test-review) or to apply fixes (use simplify/refactor).
allowed-tools: Read Grep Glob Bash(git *) Bash(ls *) Task Write
---

# review-phase — orchestrated review of an implemented phase

Fan out three focused reviewers over what was just built, **scoped to the phase contract**, then
synthesize one prioritized report. Each reviewer runs as an isolated subagent so its noise
doesn't pollute the others or the main thread.

```
implement-phase  →  review-phase
                    ├─ review-functionality   (does it meet the phase's acceptance criteria? bugs?)
                    ├─ review-security         (injection, authZ/tenant, secrets, validation)
                    └─ review-quality          (reuse, simplification, efficiency, dead code, naming)
                    → de-dupe → P0/P1/P2 → screen summary + gitignored full report
```

## Step 1 — Resolve the target & the change set

- **Phase contract:** find `docs/phases/phase-NN-<slug>.md` (the SIs, **acceptance criteria**,
  deliverables) and its `.progress.md`. If the user named a phase/slug, use it; if multiple
  match, ask. If no phase doc exists, fall back to reviewing the current diff and say so.
- **Change set:** the files the phase touched. Derive from the deliverables / `.progress.md`,
  or from git: `git diff --stat <base>...HEAD` (or `git diff` for uncommitted work). Quote the
  exact paths the reviewers must look at — don't review the whole repo.

## Step 2 — Fan out the three reviewers (subagents when available)

Spawn one subagent per dimension (`Task`), each given: the **phase contract excerpt** (objective
+ acceptance criteria) and the **change set** (paths/diff), and told to run that reviewer skill
and return **structured findings only**:
- `review-functionality` — conformance to acceptance criteria + correctness bugs.
- `review-security` — security issues in the changed code.
- `review-quality` — "crap" reduction: reuse, simplification, efficiency, dead code, naming.

Each reviewer returns findings as: `{dimension, severity, confidence, file:line, issue,
evidence, why_it_matters, fix}`. Reviewers report **confidence-based** (HIGH = report,
MEDIUM = note as "needs verification", LOW = drop) — see `references/output-format.md`.

**Graceful degradation:** if subagents/`Task` aren't available, run the three reviewers inline,
one after another, with the same inputs.

## Step 3 — Synthesize

- **De-dupe** findings that the same `file:line`/issue surfaced from more than one dimension;
  keep the most specific, note the overlap.
- **Prioritize** into **P0 / P1 / P2** (definitions in `references/output-format.md`):
  P0 = blocks ship (broken acceptance criterion, exploitable security, data loss);
  P1 = should fix before merge; P2 = nice-to-have cleanup.
- Map each functionality finding back to the **acceptance criterion** it fails, so the report
  reads against the contract.

## Step 4 — Output (screen always; file gitignored by default)

- **Always print** a prioritized summary to screen (P0/P1/P2 counts + the P0/P1 list).
- **Write the full report** to:
  - `docs/phases/phase-NN-<slug>/review/<date>.md` **if that `review/` dir already exists**, else
  - `artifacts/reviews/phase-NN-<slug>.md` (default).
- Keep the report **out of context bloat**: ensure the artifacts path is gitignored — if
  `artifacts/` (or the chosen dir) isn't in `.gitignore`, add it (and tell the user). Only commit
  the report if the user explicitly asks (e.g. for a PR record).

Use the report skeleton in `references/output-format.md`.

## Step 5 — Report back

Screen summary: counts by priority, the P0/P1 findings inline, the report path, and a one-line
verdict (ship / fix-then-ship / blocked). If runtime/UI validation matters, suggest
`e2e-test-review`; to apply the cleanups, suggest `simplify`/`refactor`.

## References
| Open when… | Read |
|---|---|
| format the report, set P0/P1/P2 & confidence, dedup rules | `references/output-format.md` |
