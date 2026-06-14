# Reproduce & Isolate (scientific debugging)

You cannot fix what you cannot reproduce. Before writing a test or a fix, make the bug happen
**on demand** and narrow it to a root cause. This is the scientific method applied to debugging:
observe → hypothesize → test → repeat.

## 1. Make it deterministic
- Capture the **exact trigger**: the input, request, sequence, or state that produces the bug.
- Reduce to a **minimal reproduction** — the smallest input/steps that still fail. Strip
  everything irrelevant; the smaller the repro, the smaller the eventual test and fix.
- Nail down **expected vs actual** precisely ("should return `0.00`, returns `NaN`") — that
  becomes the test's assertion.

## 2. If it's flaky / not reproducible
Don't guess-fix. Gather first:
- The **failing input/data** (the actual values, not a description).
- **Logs / stack trace / error** at the moment of failure.
- The **environment** (versions, OS, timezone, locale, seed) — flakiness often hides here:
  time/timezone, randomness/ordering, concurrency/race, network, uninitialized state, test
  pollution (shared state between tests).
- Try to force determinism (fix the seed, the clock, the order) until it fails every time.

## 3. Hypothesize the root cause
Form **one falsifiable hypothesis** at a time ("the date is parsed as UTC, not local"). Then test
it cheaply before committing to a fix.

## 4. Narrow it (cheap probes)
- **Bisect**: `git bisect` to find the commit that introduced it; or binary-search the code path by
  disabling halves.
- **Probe**: a temporary log/print/assert at suspect points to confirm the actual values vs
  expected. Remove probes after.
- **Trace the data**: follow the bad value backwards to where it first goes wrong — the surface
  symptom is often far from the cause.

## 5. Distinguish symptom from cause
The line that throws is where it *surfaced*, not always where it's *wrong*. Ask "why is the value
wrong here?" until you reach the decision that produced it. Fix there.

## Output of this step
- A reliable repro (command/input that fails every time).
- Expected vs actual (→ the test assertion).
- A root-cause hypothesis + the suspect location.
Then go write the failing test (`regression-test.md`).
