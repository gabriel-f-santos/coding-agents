---
name: review-quality
description: >
  Review changed code for "crap" reduction — reuse, simplification, efficiency, dead code,
  duplication, naming, and altitude. Use to clean up what was just built — "reduz a gambiarra",
  "revisa qualidade do código", "tem duplicação/dead code?", "dá pra simplificar essa feature?".
  Reports findings only (does not apply fixes — use simplify/refactor for that), confidence-based,
  never security or correctness (those are review-security / review-functionality). Runs
  standalone or as a subagent of review-phase.
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *)
---

# review-quality — reduce the crap

Review the changed code for maintainability and waste. **Reports** opportunities; it does not
apply them (the `simplify`/`refactor` skills do that). Quality findings are **never P0** and never
about behavior — only how the code reads and runs.

## Inputs
The change set (files/diff). Look for the patterns below **in the changed code**, and at how it
fits the surrounding codebase (is it reinventing something that already exists?).

## What to look for

- **Reuse over reinvention** — the change reimplements a helper/util/component that already
  exists in the repo. (Grep for the existing one; cite it.) The biggest win.
- **Duplication** — the same logic copy-pasted across the diff (or against existing code) that
  should be extracted once.
- **Dead code** — unreachable branches, unused vars/params/imports/exports, commented-out blocks,
  feature flags never read.
- **Over-complexity** — a function doing too much; deep nesting; a clever one-liner that hides
  intent; needless abstraction/indirection (over-engineering for a case that isn't there).
- **Altitude / wrong layer** — business logic in a controller, SQL in a component, a concern
  living in the wrong module/boundary.
- **Efficiency (non-hot-path)** — obvious waste: N+1 that isn't a security/perf P0, repeated
  recomputation, loading more than needed. (A hot-path perf bug is correctness → that's
  review-functionality's P1.)
- **Naming & clarity** — names that mislead or don't match the domain language; a comment
  explaining what a better name would.

## Confidence & output

Report findings worth acting on (skip nitpicks). **HIGH** = clear, with the concrete improvement;
**MEDIUM** = worth a look; **drop LOW** style-only noise. Return:
`{dimension: quality, severity, confidence, file:line, issue, evidence, fix (the concrete
simplification, and which existing thing to reuse if any)}`. Prefer **fewer, higher-value**
findings over a long list of style nits — the goal is less crap, not more bureaucracy.
