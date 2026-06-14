# pencil — Cross-Platform Setup

Targets: **Claude Code · OpenAI Codex · opencode**. The skill body is portable — no load-time exec
(`` !`cmd` ``), no `${CLAUDE_SKILL_DIR}`; all bundled files are referenced by relative path. Per-
platform controls differ.

## Where the files live

- **Canonical copy:** `.claude/skills/pencil/` — read natively by **Claude Code** and **opencode**
  (opencode scans `.claude/skills/`).
- **Codex** needs its own copy at `.codex/skills/pencil/` OR a `config.toml` entry pointing at the
  canonical `SKILL.md`. Keep copies in sync.

## The real dependency: the Pencil MCP server

This skill is an **MCP integration layer**. It does not bundle Pencil — it **discovers the Pencil MCP
at runtime** and degrades gracefully when it's absent. Connection is the same regardless of runtime:
install the **Pencil VS Code / Cursor extension**, open a `.pen` file, ensure Pencil is running; the
extension **auto-registers** the MCP server (no manual `claude mcp add` in the documented flow).
Verify with `/mcp`. See `references/capability-map.md` → "Connection".

## Per-platform configuration

### Claude Code
Frontmatter carries `allowed-tools: Read Write Edit Grep Glob`. The Pencil **MCP tools are not listed
in `allowed-tools`** on purpose — MCP tools are granted via the host's MCP permission flow, and the
skill discovers them at runtime. Nothing else to do besides connecting Pencil (above).

### OpenAI Codex
Copy to `~/.codex/skills/pencil/`, then add to `~/.codex/config.toml` (restart Codex after):
```toml
[[skills.config]]
path = "~/.codex/skills/pencil/SKILL.md"
enabled = true
```
Dependency control is in `agents/openai.yaml`. The Pencil MCP is listed as **optional** (not a hard
`mcp_servers` dep) to preserve graceful degradation — Codex won't fail when Pencil is missing. If you
want Codex to hard-require Pencil, move `pencil` into `dependencies.mcp_servers`.

### opencode
Discovered under `.claude/skills/`; allowed by default. `allowed-tools` is ignored (inert). To
restrict, add to `opencode.json`:
```json
{ "permission": { "skill": { "pencil": "allow" } } }
```

## Claude-only fields (inert elsewhere)
`allowed-tools` is honored only by Claude Code; Codex and opencode ignore it.
