# fix-bug

Fix bugs with discipline — **reproduce → failing regression test (Red) → root-cause fix → Green →
full suite** — instead of "fix by vibes". The whole point: an **objective oracle** (a test that
reproduced the bug and now passes), so "fixed" is verified, not claimed.

## When to use
"tem um bug", "corrige esse erro", "fix this bug", "isso deveria retornar X mas dá Y", "debug
isso", "não está funcionando", "reproduz e corrige".

## The loop
1. **Reproduce** deterministically (minimal repro; expected vs actual).
2. **Locate** the root cause (hypothesis, bisect, probe).
3. **Failing test** that asserts the correct behavior → confirm **Red** (fails for the bug).
4. **Fix** the root cause (smallest change).
5. **Green** + run the **full suite** (no regressions) + original symptom gone.
6. **Report**: root cause · test added · fix · verification.

## Hard rule
Never declare it fixed without a previously-failing test now passing. Don't weaken the test to pass.
Fix the cause, not the symptom. If you can't run tests, the result is flagged **UNVERIFIED**.

## Pairs with
`github-actions`/`greenfield-monorepo` (the regression test runs in CI forever) · `review-functionality`
(fix vs contract) · `implement-phase` (new features, not bug fixes).

## Why this matters for agents
The failing test is what stops an agent from declaring victory on a fix that doesn't fix. It's TDD's
Red-Green-Refactor applied to bugs — the regression test is the guarantee.

## Install
`cp -r fix-bug ~/.claude/skills/` (Claude Code + opencode) or `.codex/skills/` (Codex). Portable; see PORTABILITY.md.
