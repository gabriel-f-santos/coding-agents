# Portability — celery-rabbitmq

This skill is portable across Claude Code, OpenAI Codex, and opencode. The logic lives in
`SKILL.md` + `references/` + `assets/templates/`; per-platform control is configured below.

| Runtime | Install location | Tool/permission control |
|---|---|---|
| **Claude Code** | `~/.claude/skills/celery-rabbitmq/` | `allowed-tools` in `SKILL.md` frontmatter |
| **opencode** | reads `~/.claude/skills/` natively | set in your `opencode.json` (see below) |
| **OpenAI Codex** | `~/.codex/skills/celery-rabbitmq/` (copy) or a `config.toml` entry | `agents/openai.yaml` |

## opencode

opencode ignores `allowed-tools`. If you want to restrict this skill, add to your
`opencode.json`:

```json
{
  "permission": {
    "skill": {
      "celery-rabbitmq": "allow"
    }
  }
}
```

Don't need restriction? No action — opencode picks it up from `~/.claude/skills/`.

## Codex

Copy the skill folder to `~/.codex/skills/` (or point to it via `config.toml`). Tool
permissions and dependencies come from `agents/openai.yaml`, not the frontmatter.

## Notes

- No load-time execution (`!` backtick commands) or `@`-path embeds are used — those are
  Claude-only and would not expand in Codex/opencode. Commands in the body are written as
  steps for the agent to run.
- The five standard frontmatter fields plus `allowed-tools` are all that is relied on; unknown
  fields are ignored by opencode/Codex.
