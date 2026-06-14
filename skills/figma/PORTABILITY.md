# figma — Cross-Platform Setup

Targets: **Claude Code · OpenAI Codex · opencode**. The body is portable (no load-time exec, no
Claude-only variables). Per-platform controls differ. The one shared prerequisite is a connected
**Figma MCP server** (see `README.md` → "Connect the Figma MCP").

## Where the files live
- **Canonical copy:** `.claude/skills/figma/` — read natively by Claude Code and opencode
  (opencode scans `.claude/skills/`).
- **Codex** needs a copy at `.codex/skills/figma/` OR a `config.toml` entry pointing at the
  canonical `SKILL.md`. Keep copies in sync.

## Per-platform configuration

### Claude Code
Frontmatter carries `allowed-tools: Read Grep Glob ToolSearch Write`. `ToolSearch` is how the
skill discovers the Figma MCP tools at runtime; the actual Figma MCP tools become available once
the Figma MCP server is added to your Claude Code MCP config. Nothing else to do.

### OpenAI Codex
Copy to `~/.codex/skills/figma/`, then add to `~/.codex/config.toml` (restart Codex):
```toml
[[skills.config]]
path = "~/.codex/skills/figma/SKILL.md"
enabled = true
```
The Figma MCP dependency is declared in `agents/openai.yaml` (`dependencies.mcp_servers: [figma]`).
Codex warns/fails fast if that MCP server is not configured — register your Figma MCP server under
the same id, or rename the dependency to match your registered server id.

### opencode
Discovered under `.claude/skills/`; allowed by default. `allowed-tools` is ignored (inert). To
restrict, add to `opencode.json`:
```json
{ "permission": { "skill": { "figma": "allow" } } }
```
opencode discovers MCP tools from its own MCP configuration; ensure the Figma MCP server is
registered there so the skill's runtime discovery (Step 2) can find it.

## Tool portability
The skill **discovers** the Figma MCP at runtime rather than hardcoding tool names, so it works
across runtimes regardless of how each host names the connected tools. If no Figma MCP is found it
degrades gracefully and emits the textual spec — it never fails hard.

## Claude-only fields (inert elsewhere)
`allowed-tools` is honored only by Claude Code; Codex and opencode ignore it.
