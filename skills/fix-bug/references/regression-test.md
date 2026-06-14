# Writing the Failing Regression Test (🔴 Red)

The test is the contract: it asserts the **correct** behavior, **fails** on the buggy code, and
stays forever so the bug can't return. Get this right and the fix is almost mechanical.

## What makes a good repro test
- **Asserts the correct behavior**, not the current (buggy) one. The expected value comes from
  step 1's "expected vs actual".
- **Fails now, for the right reason.** Run it against the unfixed code and confirm it goes Red
  because of the bug — not an import error, missing fixture, or typo. A test that errors on setup
  isn't a Red on the bug.
- **Minimal & deterministic** — the smallest case that triggers it; no sleeps, no real network/
  clock/random (inject/fake them). Flaky tests are worse than none.
- **At the right layer:**
  - bug in a pure function / branch → **unit** test.
  - bug in a request/DB/flow → **integration**; bug across the UI → **e2e**.
  - Prefer the lowest layer that actually reproduces it (faster, more precise).
- **Names the bug** — `test_invoice_total_with_zero_items_returns_0` or reference the issue
  (`regression: #1234`), so a future reader knows what it protects.

## Confirm Red
Run **only the new test** and read the failure:
```
<runner> <path-to-the-new-test>     # pytest path::test / npm test -- -t name / go test -run / etc.
```
- Red **for the bug** → good, proceed to the fix.
- **Green already** → the test doesn't capture the bug; fix the test (wrong assertion/case).
- **Errors (not fails)** → fix the test setup first; you haven't tested anything yet.

## Match the project's conventions
Use the repo's runner, structure, and helpers — if a `testing-guide-*` skill or a `tests/`
convention exists, follow it. Put the test where similar tests live; reuse fixtures/factories.

## Per-ecosystem quick pointers
- **pytest:** `def test_...():` + `assert`; run `pytest path::test -q`. Use `freezegun`/`monkeypatch`
  for time/IO.
- **Jest/Vitest:** `test('...', () => expect(...).toBe(...))`; `vi.useFakeTimers()` / mock modules.
- **Go:** `func TestXxx(t *testing.T)`; `go test ./pkg -run TestXxx`; table tests for cases.
- **JUnit/others:** the same shape — arrange the buggy input, assert the correct output.

## Anti-patterns (don't)
- Don't assert the buggy output "to make it pass".
- Don't write the test **after** the fix without confirming it would have failed (you lose the
  guarantee it catches the bug). If you already fixed, temporarily revert the fix to see Red.
- Don't test implementation details that'll break on any refactor — assert **behavior**.

After Red, go fix the root cause, then run this test again for Green and the full suite for
regressions (SKILL.md steps 4–5).
