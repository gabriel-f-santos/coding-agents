---
name: fix-bug
description: >
  Fix a bug the disciplined way — reproduce, write a FAILING regression test, then fix until
  green. Use when the user reports a bug or asks to fix/debug something — "tem um bug", "corrige
  esse erro", "fix this bug", "isso deveria retornar X mas retorna Y", "debug isso", "não está
  funcionando", "reproduz e corrige". Enforces TDD red-green for bugs: reproduce deterministically,
  write a regression test that asserts the CORRECT behavior and fails on the current code (confirm
  Red), make the smallest root-cause fix, confirm the test passes (Green), then run the full suite
  so nothing regressed. Hard rule: never declare it fixed without a test that reproduced the bug
  now passing. Runs the tests when a runner exists, else writes the test + fix and flags it
  unverified. Do not use to add a new feature (use implement-phase) or for pure code review
  (use review-*).
allowed-tools: Read Grep Glob Edit Write Bash
license: MIT
metadata:
  author: skill-gen
  grounded: "2026-06-14"
---

# fix-bug — reproduce → red test → fix → green

Fix bugs with TDD's **Red-Green-Refactor**, not by vibes. The point is an **objective oracle**: a
test that *reproduced the bug* and now passes. Without that, "fixed" is just a claim.

## References
| Open when you need to… | Read |
|---|---|
| reproduce & isolate deterministically (scientific debugging) | `references/reproduce-and-isolate.md` |
| write a good failing regression test (per-ecosystem, confirm Red) | `references/regression-test.md` |

## The loop (follow in order — don't skip)

### 1. Understand & reproduce
Pin down the **expected vs actual** behavior and the exact inputs/conditions that trigger it. Build
a **deterministic, minimal reproduction** (a failing command, request, or input). → `reproduce-and-isolate.md`
- **You cannot fix what you cannot reproduce.** If it's flaky/unreproducible, stop and gather more
  (logs, the failing input, env) before touching code.

### 2. Locate (just enough)
Form a hypothesis about the **root cause** — bisect, add a probe/log, narrow to the smallest
suspect region. Don't over-investigate before the test; the test will confirm you found it.

### 3. Write a failing test (🔴 Red)
Write a **regression test** that asserts the **correct** behavior, at the right layer (unit if the
bug is in a function; integration/e2e if it's a flow). → `references/regression-test.md`
- **Run it and confirm it FAILS — for the right reason** (the bug, not a setup/import error).
- A test that passes before the fix doesn't test the bug. If it passes, it's wrong — fix the test.
- Reuse the project's testing guide/conventions if present (e.g. a `testing-guide-*` skill).

### 4. Fix (root cause, smallest change)
Make the **smallest change that fixes the root cause** — not a symptom patch. If the real cause is
upstream of where it surfaced, fix it there.

### 5. Green + regression
- Run the new test → it **passes** (🟢). If not, iterate on the fix (not the test).
- Run the **full test suite** (or at least the affected modules) → confirm **nothing regressed**.
- Reproduce the original symptom manually one more time → confirm it's gone.

### 6. Report
- **Root cause** (one line — what was actually wrong, not just where).
- **The test added** (path + what it asserts) — it stays forever as protection.
- **The fix** (the diff, scoped).
- **Verification**: test went Red→Green; full suite green; original repro gone.

## Hard rules (the discipline)
- **Never declare fixed without a previously-failing test now passing.** This is the whole skill.
- The regression test must **fail before** the fix (you saw the Red). If you didn't, you don't know
  it catches the bug.
- **Don't weaken, skip, or delete the test** to get green; **don't assert the buggy behavior**.
- **Fix the cause, not the symptom** — green on a symptom patch with the cause alive is a fail.
- **Run the full suite before done** — a fix that breaks three other tests isn't a fix.

## When you can't run tests
If there's no runner / you can't execute (sandbox, missing deps): still **write the failing test +
the fix**, explain how to run them, and **flag the result as UNVERIFIED** — say plainly you did not
observe Red→Green. Never claim a verified fix you didn't run.

## Pairs with
The regression test feeds CI (`github-actions`/`greenfield-monorepo`) so the bug can't return;
`review-functionality` checks the fix against the contract; `implement-phase` for new features.
