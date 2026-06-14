# ux-design — Cross-Platform Setup

Targets Claude Code · Codex · opencode. Body is portable (no load-time exec, no Claude-only vars).

## Install
Copy `ux-design/` into the runtime's skills dir (and optionally the `pencil`/`figma` skills to
render frames):
- Claude Code / opencode: `.claude/skills/` (opencode scans it natively).
- Codex: `.codex/skills/` (or a `config.toml` entry).

## Per-platform
- **Claude Code:** `allowed-tools: Read Grep Glob Write Task WebSearch ToolSearch`. `ToolSearch`
  is how it discovers a design MCP at runtime; `Task` for optional per-screen render fan-out.
- **Codex:** `agents/openai.yaml` declares `pencil`/`figma` as optional skill deps; the design MCP
  is discovered at runtime.
- **opencode:** discovered under `.claude/skills/`; `allowed-tools` inert. Gate via
  `opencode.json` `permission.skill` if needed.

## Rendering tools (optional)
`ux-design` renders via the `pencil` or `figma` skill if installed, else a connected design MCP,
else degrades to textual wireframes. None is required to produce the screen inventory/flows/specs.

## Output
Writes `docs/design/<slug>/summary.md` (+ `screens/*.md`) — committed/durable (a reference for the
implementation plan), NOT gitignored.
