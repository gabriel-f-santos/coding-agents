# product-discovery — Cross-Platform Setup

Targets: **Claude Code · OpenAI Codex · opencode**. The skill body is portable (no load-time
exec, no Claude-only variables). Per-platform controls differ.

## Where the files live

- **Canonical copy:** `.claude/skills/product-discovery/`
- Read natively by **Claude Code** and **opencode** (opencode scans `.claude/skills/`).
- **Codex** needs its own copy at `.codex/skills/product-discovery/` OR a `config.toml` entry
  pointing at the canonical `SKILL.md`. Keep copies in sync.

## Per-platform configuration

### Claude Code
Frontmatter carries `allowed-tools: Read Write WebSearch WebFetch Task Bash(ls *)`. Nothing else
to do. (`Task` = subagent fan-out for market research; `WebSearch`/`WebFetch` = research loops.)

### OpenAI Codex
Copy the folder to `~/.codex/skills/product-discovery/`, then add to `~/.codex/config.toml`
(restart Codex):
```toml
[[skills.config]]
path = "~/.codex/skills/product-discovery/SKILL.md"
enabled = true
```
Web research + subagents use Codex's own capabilities; `agents/openai.yaml` declares no external
deps.

### opencode
Discovered under `.claude/skills/`; allowed by default. `allowed-tools` is ignored (inert). To
restrict, add to `opencode.json`:
```json
{ "permission": { "skill": { "product-discovery": "allow" } } }
```

## Portability note on tools

The skill asks for `WebSearch`/`WebFetch`/`Task`. These exist under different names per runtime.
The body always phrases research as "spawn a subagent **if available**, otherwise use web search
inline" — so it degrades gracefully where a given tool isn't present.

## Claude-only fields (inert elsewhere)
`allowed-tools` is honored only by Claude Code; Codex and opencode ignore it.
