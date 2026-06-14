# fix-bug — Cross-Platform Setup

Targets Claude Code · Codex · opencode. Body is portable (no load-time exec, no Claude-only vars).

## Install
- Claude Code / opencode: `.claude/skills/` (opencode scans it natively).
- Codex: `.codex/skills/` (or a `config.toml` entry).

## Per-platform
- **Claude Code:** `allowed-tools: Read Grep Glob Edit Write Bash`. It **edits code and runs the
  test suite** (Bash) — that's the objective oracle (Red→Green). Scope bash to the project's test
  commands if you want tighter control.
- **Codex:** `agents/openai.yaml`.
- **opencode:** discovered under `.claude/skills/`; `allowed-tools` inert; gate via `opencode.json`.

## Note
If tests can't be run in the environment, the skill still writes the failing test + fix but flags
the result as **UNVERIFIED** — it never claims a verified fix it didn't observe.
