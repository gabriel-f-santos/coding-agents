# github-actions — Cross-Platform Setup

Targets Claude Code · Codex · opencode. Body is portable (no load-time exec, no Claude-only vars).

## Install
- Claude Code / opencode: `.claude/skills/` (opencode scans it natively).
- Codex: `.codex/skills/` (or a `config.toml` entry).

## Per-platform
- **Claude Code:** `allowed-tools: Read Grep Glob Write WebSearch Task`. Writes under
  `.github/workflows/`; `WebSearch` to resolve current action SHAs; `Task` for per-workflow review fan-out.
- **Codex:** `agents/openai.yaml` (optionally chains greenfield-monorepo / review-security).
- **opencode:** discovered under `.claude/skills/`; `allowed-tools` inert; gate via `opencode.json`.

## Note
GENERATE writes secure-by-default workflows; REVIEW is read-only audit. Resolve `<sha>` pins to real
commit SHAs when emitting (Renovate/Dependabot keep them current).
