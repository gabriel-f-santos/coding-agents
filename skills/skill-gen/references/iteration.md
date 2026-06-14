# Iterating a Skill from Outcomes & Examples

Use this when **improving an existing skill** based on how it actually behaved — positive
examples (worked), negative examples (mis-triggered, skipped a reference, weak output), review
feedback, or validation results. (Merged from the skill-writer methodology.)

## When to run

Operation is `improve` / `iterate`: the user says "this skill mis-fired", "it didn't trigger
when it should", "the output was wrong", or pastes a transcript of a bad run. Don't rewrite
blind — drive the edit from evidence.

## Step 1 — Capture examples

For each example, record:
- **Label:** `positive` (must keep working) | `negative` (must fix)
- **Kind:** `true-positive` | `false-positive` | `false-negative` | `fix` | `regression` |
  `edge-case`
- **Origin:** `human-verified` | `mixed` | `synthetic`
- **Source:** where it came from (issue/PR/transcript/user note)
- **Expected vs Observed behavior:** one line each
- **Anonymization:** redact secrets, customer data, private URLs

Negative findings should name the **smallest failing decision**, not "it was bad":
- wrong trigger behavior (fired / didn't fire)
- missing source type or skipped reference file
- overloaded or hidden instruction
- weak output contract
- missing validation step
- unsafe or **non-portable path assumption** (e.g. used `${CLAUDE_SKILL_DIR}` in a
  cross-platform skill — see `portability.md`)

## Step 2 — Split working vs holdout

Keep some examples **reserved for validation** (holdout). Don't tune directly against holdout —
that's how you overfit. Edit against the working set; confirm against the holdout set.

For a one-off small fix, keep this in your head / the PR description. For a skill you'll revise
repeatedly, persist evidence under `references/evidence/`:
```
references/evidence/
├── findings-log.md   # patterns, root causes, the skill delta made, unresolved risks
├── working-set.md    # examples used while editing
└── holdout-set.md    # examples reserved for validation
```
Don't turn `evidence/` into a changelog — record decisions in the skill's own history/commit.

## Step 3 — Make the smallest delta

Map each negative finding to a concrete change, and **protect positives** (don't regress what
works):
1. Prioritize fixes for **repeated** negative patterns over one-offs.
2. Universal behavioral rules → `SKILL.md`. Domain detail → a focused `references/` file.
   Trigger wording → the `description` (run `description-optimization.md`).
3. Prefer tightening/removing an existing instruction over adding a new one (precision pass —
   what existing rule should be narrowed or deleted?).
4. If the fix is a portability bug, re-run `validate_skill.py --cross-platform`.

## Step 4 — Replay & confirm

1. Re-check behavior against the **working set** — did the negatives flip to correct?
2. Re-check against the **holdout set** — did anything regress?
3. Record outcomes as improved / unchanged / regressed. Confirm **both** positive and negative
   behavior moved in the expected direction before declaring done.

## Output

- Example intake summary (counts by label/kind)
- Behavior deltas (what changed and why)
- Updated artifacts (files touched)
- Replay summary (working + holdout results)
