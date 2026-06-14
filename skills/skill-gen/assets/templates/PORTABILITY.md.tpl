# {{SKILL_NAME}} — Cross-Platform Setup

This skill targets: {{TARGETS}}. The skill body is portable; per-platform controls differ.

## Where the files live

- **Canonical copy:** `{{CANONICAL_PATH}}` (e.g. `.claude/skills/{{SKILL_NAME}}/`)
- Read natively by **Claude Code** and **opencode** (opencode scans `.claude/skills/`).
- **Codex** needs its own copy at `.codex/skills/{{SKILL_NAME}}/` OR a `config.toml` entry
  pointing at the canonical `SKILL.md`. Keep copies in sync.

## Per-platform configuration

### Claude Code
Frontmatter already carries the controls (`allowed-tools`{{CLAUDE_EXTRAS}}). Nothing else to do.

### OpenAI Codex
Add to `~/.codex/config.toml` (restart Codex after):
```toml
[[skills.config]]
path = "{{CODEX_SKILL_PATH}}/SKILL.md"
enabled = true
```
Tool/dependency control is in `agents/openai.yaml` (already emitted).

### opencode
No action needed unless you want to restrict this skill. To gate it, add to `opencode.json`:
```json
{ "permission": { "skill": { "{{SKILL_NAME}}": "{{OPENCODE_PERMISSION}}" } } }
```

## Claude-only fields (inert elsewhere)
These frontmatter fields are honored ONLY by Claude Code; Codex and opencode ignore them:
`allowed-tools`, `disallowed-tools`, `disable-model-invocation`, `effort`, `model`.
