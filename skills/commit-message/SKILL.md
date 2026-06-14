---
name: commit-message
description: >
  Generate a Conventional Commits message from staged changes. Use when the user asks to
  "write a commit message", "commit message", "gera a mensagem de commit", "commita isso",
  or right after staging with git add. Reads the staged diff, classifies it
  (feat/fix/docs/refactor/test/chore/...), and writes a <72-char imperative subject plus an
  optional body — it presents the message, it does not run the commit. Do not use for PR
  descriptions or changelogs — those are separate concerns.
allowed-tools: Read Bash(git diff *) Bash(git status *) Bash(git log *)
---

# commit-message — Conventional Commits from staged changes

Turn the staged diff into a clean Conventional Commits message. The skill **reads and drafts**
— it never commits. The user reviews and commits themselves.

## Process

1. **Read the staged changes.** Run `git diff --staged --stat` for the shape and
   `git diff --staged` for the content. If nothing is staged, run `git status` and tell the
   user to `git add` first — don't invent a diff.
2. **Match the repo's style.** Run `git log -5 --pretty=%s` and follow the existing convention
   (scope usage, language, capitalization) when it doesn't conflict with the rules below.
3. **Classify the change** against the type table. One commit = one logical change; if the diff
   mixes unrelated changes, say so and suggest splitting.
4. **Draft** subject + optional body using the output template.
5. **Self-check** against the checklist, fix violations, then present the message in a fenced
   block for the user to copy. Do not execute the commit.

## Conventional Commits types

| Type | Use for |
|---|---|
| `feat` | a new user-facing feature |
| `fix` | a bug fix |
| `docs` | documentation only |
| `refactor` | behavior-preserving code change |
| `perf` | performance improvement |
| `test` | adding/adjusting tests |
| `build` | build system or dependencies |
| `ci` | CI configuration |
| `chore` | maintenance, no src/test change |
| `style` | formatting only (whitespace, semicolons) |

Add a scope in parentheses when it sharpens meaning: `feat(auth): …`. Append `!` (or a
`BREAKING CHANGE:` footer) for breaking changes: `feat(api)!: …`.

## Output template

```
<type>(<scope>): <imperative subject, ≤72 chars, no trailing period>

<optional body: what & why, wrapped at ~72 cols. Blank line above.>

<optional footer: BREAKING CHANGE: …  /  Refs: #123>
```

**Example**
Input (staged): added JWT verification middleware + a test
Output:
```
feat(auth): verify JWT on protected routes

Add middleware that validates the bearer token and rejects expired or
malformed tokens with 401 before the handler runs.
```

## Self-check (run before presenting)

- [ ] Subject ≤ 72 characters
- [ ] Imperative mood ("add", not "added"/"adds")
- [ ] No trailing period on the subject
- [ ] Type is from the table and matches the actual change
- [ ] Subject describes the change, not the file ("add retry to fetch", not "edit fetch.ts")
- [ ] Body present when the *why* isn't obvious from the subject; omitted when trivial
- [ ] One logical change — flagged the user if the diff mixes concerns
