# Description Optimization — tuning the trigger

The `description` is the only thing the runtime sees at idle, and it's what decides whether the
skill fires. Optimize it after the skill works, or whenever it mis-triggers. (Merged from the
skill-writer methodology.)

## Trigger-quality loop

1. **Draft** a description with realistic user language and concrete trigger phrases — the way
   a real user actually types, not abstract ("Format this data" → bad; a messy real request →
   good).
2. **Build two query sets:**
   - **should-trigger** (8–10) — varied phrasings of the intent: formal, casual, with typos,
     cases where the user doesn't name the skill/filetype but clearly needs it, and cases where
     this skill competes with another but should win.
   - **should-not-trigger** (8–10) — the valuable ones are **near-misses**: queries that share
     keywords but need something else. Avoid obviously-irrelevant negatives — they test nothing.
3. **Check** the current description against both sets (would it fire?).
4. **Edit** wording to fix false positives and false negatives.
5. **Repeat** until both are at acceptable levels.

## Authoring rules

1. **Third person**, present tense ("Generates…", "Use when…").
2. State **what it does AND when to use it** — all "when to use" lives here, not in the body.
3. Be a little **pushy** to fight under-triggering: "…Use this whenever the user mentions X, Y,
   or Z, even if they don't explicitly ask for it."
4. Add a **negative boundary**: "Do not use for <near-miss> — use <other skill>."
5. Drop implementation detail that doesn't help triggering.

## Portability rule (skill-gen-specific)

For a **provider-agnostic** skill, do **not** name Claude / Codex / opencode in a way that
narrows portability expectations. Trigger language should be generic across runtimes unless the
skill is intentionally provider-specific. (A Claude-only skill *may* reference Claude — but then
say so.)

## Output

- Final description text
- The should-trigger and should-not-trigger query sets (so the next reviewer can re-check)
- Summary of the edits made and why
