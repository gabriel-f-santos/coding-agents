# tech-discovery — Cross-Platform Setup

Targets: **Claude Code · OpenAI Codex · opencode**. The body is portable (no load-time exec, no
Claude-only variables). Per-platform controls differ.

## Where the files live
- **Canonical copy:** `.claude/skills/tech-discovery/` — read natively by Claude Code and
  opencode (opencode scans `.claude/skills/`).
- **Codex** needs a copy at `.codex/skills/tech-discovery/` OR a `config.toml` entry pointing at
  the canonical `SKILL.md`. Keep copies in sync.

## Per-platform configuration
### Claude Code
Frontmatter carries `allowed-tools: Read Grep Glob WebSearch WebFetch Task Write Bash(ls *)
Bash(cat *)`. Nothing else to do. (`Task` = subagent fan-out for option research.)

### OpenAI Codex
Copy to `~/.codex/skills/tech-discovery/`, then add to `~/.codex/config.toml` (restart Codex):
```toml
[[skills.config]]
path = "~/.codex/skills/tech-discovery/SKILL.md"
enabled = true
```
Web research + subagents use Codex's own capabilities; `agents/openai.yaml` declares no external
deps.

### opencode
Discovered under `.claude/skills/`; allowed by default. `allowed-tools` is ignored (inert). To
restrict, add to `opencode.json`:
```json
{ "permission": { "skill": { "tech-discovery": "allow" } } }
```

## Tool portability
The skill phrases research as "fan out with subagents **if available**, otherwise inline; use
context7 **if available**, otherwise web/official docs" — it degrades gracefully per runtime.

## Optional companions (load if present)
`ddd` (bounded contexts) and `grill-with-docs` (CONTEXT.md/ADR) enrich Steps 1/4/ADR but are not
required — the skill works standalone.

## Claude-only fields (inert elsewhere)
`allowed-tools` is honored only by Claude Code; Codex and opencode ignore it.
