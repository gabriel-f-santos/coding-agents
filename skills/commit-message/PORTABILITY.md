# commit-message — Cross-Platform Setup

Targets: **Claude Code · OpenAI Codex · opencode**. The skill body is portable (no load-time
exec, no Claude-only variables); per-platform controls differ.

## Where the files live

- **Canonical copy:** `.claude/skills/commit-message/`
- Read natively by **Claude Code** and **opencode** (opencode scans `.claude/skills/`).
- **Codex** needs its own copy at `.codex/skills/commit-message/` OR a `config.toml` entry
  pointing at the canonical `SKILL.md`. Keep copies in sync.

## Per-platform configuration

### Claude Code
Frontmatter already carries `allowed-tools: Read Bash(git diff *) Bash(git status *)
Bash(git log *)` — read-only git, least privilege. Nothing else to do.

### OpenAI Codex
Copy the folder to `~/.codex/skills/commit-message/` (or project `.codex/skills/`), then add
to `~/.codex/config.toml` and restart Codex:
```toml
[[skills.config]]
path = "~/.codex/skills/commit-message/SKILL.md"
enabled = true
```
Tool/dependency control is in `agents/openai.yaml` (already included).

### opencode
No action needed — opencode discovers it under `.claude/skills/` and allows skills by default.
The `allowed-tools` frontmatter is ignored here (inert). To restrict it, add to `opencode.json`:
```json
{ "permission": { "skill": { "commit-message": "allow" } } }
```

## Claude-only fields (inert elsewhere)
`allowed-tools` is honored only by Claude Code; Codex and opencode ignore it. The skill stays
read-only on those runtimes via their own mechanisms (Codex `openai.yaml`, opencode
`opencode.json`).
