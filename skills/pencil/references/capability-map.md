# Pencil MCP — Capability Map & Runtime Discovery

What the Pencil MCP server is expected to expose, what is **verified** from public docs vs. what is
**unverified/assumed**, and how to discover the real tools at runtime so this skill never depends on
stale names.

> Sources (June 2026): Pencil docs `docs.pencil.dev/getting-started/ai-integration`; field reports
> (classmethod DevelopersIO Claude Code + Pencil MCP article; Better Stack / Banani reviews). Pencil
> is young and MCP-first; tool **names** are documented but exact **parameter schemas** are not fully
> published. Always confirm against the live schema (see §Runtime discovery).

## What Pencil is (grounding)

- An **AI-native, MCP-first** design tool — a "Figma-like" infinite canvas that lives in your IDE
  (VS Code / Cursor extension) and is driven by AI agents over MCP.
- Design files are **`.pen`** files (JSON-based, proprietary) stored **locally / in your repo**. The
  MCP server **runs locally — no cloud dependency** for design operations.
- It does **not** (per docs) mint a hosted shareable URL per screen. The artifact is the `.pen` file
  plus rendered screenshots. → treat any "shareable link" requirement as **unverified** (see below).

## Expected capability map (DOCUMENTED tool names)

These names appear in Pencil's official AI-integration docs. Treat them as the *expected* map;
confirm the precise arguments at runtime.

| Capability this skill needs | Documented Pencil MCP tool | Notes / confidence |
|---|---|---|
| **Create / modify design** (insert, update, replace, move, delete elements; generate images) | `batch_design` | VERIFIED name. Operation verbs + per-op argument shape **NOT fully published** → read live schema. |
| **Read the design** (search elements by pattern, inspect component hierarchy) | `batch_get` | VERIFIED name. Use to detect an existing screen before create-vs-update. |
| **Render a preview** (screenshot to verify output) | `get_screenshot` | VERIFIED name. The closest thing to a "deliverable artifact" besides the `.pen` file. |
| **Analyze layout** (positioning issues, overlaps) | `snapshot_layout` | VERIFIED name. Run after a write to catch broken layouts. |
| **Editor context** (active file, current selection) | `get_editor_state` | VERIFIED name. Read first to know which `.pen` file you're in. |
| **Design tokens / theming** (read/update theme, sync CSS) | `get_variables` / `set_variables` | VERIFIED names. Use only if the spec carries tokens/theme. |

### UNVERIFIED / assumed (do NOT invent calls for these)

- **Shareable / hosted screen URL** — *not documented*. The user's framing ("return a shareable
  link/URL") is **not** confirmed by Pencil's docs. **TODO: FILL WHEN PENCIL MCP CONNECTED** — if the
  live server exposes an export/share tool, map it here; until then the deliverable is the `.pen`
  reference + screenshot.
- **Exact `batch_design` operation schema** — the verbs (insert/copy/update/replace/move/delete) are
  documented but the *argument object* for, e.g., "insert a frame named X at region Y with children"
  is **not** published. **TODO: FILL WHEN PENCIL MCP CONNECTED** — capture the real schema from
  runtime discovery and record it here.
- **Tool namespacing** — under Claude Code/Codex, MCP tools are usually surfaced as
  `mcp__pencil__<tool>` (or similar). The exact prefix depends on how the server is registered; do
  not hardcode it — discover it.

## Runtime discovery (do this every run — Step 1 of the workflow)

The point is to **never depend on the names above being current**. Resolve the real tools live:

1. **Tool-search facility** (if the host has one, e.g. `ToolSearch`): query for `pencil`,
   `batch_design`, `get_editor_state`, `get_screenshot`. The result includes the **real schemas** —
   use those argument shapes, not the assumptions in this file.
2. **MCP tool listing**: inspect the MCP tools the host exposes this session. Look for a `pencil`
   server / `mcp__pencil__*` namespace. The user can run `/mcp` to confirm Pencil is connected and
   see its tool list.
3. **Match → map**: line up what you found against the table above. If a documented tool is missing
   but an equivalent exists under a different name, use the equivalent and note the substitution.
4. **Nothing found** → the Pencil MCP is **not connected**. Do not call anything. Degrade gracefully
   (SKILL.md Step 5 / `spec-to-screen.md` §Degradation).

## Connection (so you can tell the user how to fix "not connected")

Per docs, the Pencil MCP is **auto-registered** when the Pencil VS Code/Cursor extension is
installed and Pencil is running — there is typically **no manual `claude mcp add`** step. A reference
registration (from a field report) looks like:

```jsonc
// auto-populated in the host's MCP config (e.g. ~/.claude.json) by the extension
"mcpServers": {
  "pencil": {
    "command": "<…>/extensions/highagency.pencildev-<ver>/out/mcp-server-<platform>",
    "args": ["--app", "visual_studio_code"]
  }
}
```

So the fix for "not connected" is usually: **install the Pencil extension, open a `.pen` file, ensure
Pencil is running**, then re-check with `/mcp`. (Exact paths/versions vary — do not hardcode.)
