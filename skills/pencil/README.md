# pencil

The **integration layer** between a *screen spec* and a *real pencil.dev design screen*. It takes a
structured screen spec (name, layout, components, states, content) and drives the **Pencil MCP
server** to create or update the matching screen on pencil.dev's infinite canvas, then hands back a
reference to the produced artifact.

[pencil.dev](https://docs.pencil.dev/) is an AI-native, MCP-first design tool — a Figma-like canvas
that lives in your IDE (VS Code / Cursor extension). Its design files are local **`.pen`** files and
its MCP server runs **locally**.

## What it is / what it isn't

- **Is:** a thin, portable orchestrator that discovers the Pencil MCP at runtime, maps a screen spec
  onto Pencil design operations (`batch_design`, `batch_get`, `get_screenshot`, `snapshot_layout`,
  `get_editor_state`, `get_variables`/`set_variables`), and returns the `.pen` screen reference plus a
  screenshot.
- **Isn't:** a spec author (that's `ux-design`), a Figma client (use a `figma` skill), or a
  design-to-code generator (that's a separate code-gen step driven off the canvas).

## When to use it

When you want a screen spec turned into a real Pencil screen: "create the login screen in Pencil",
"generate this UI in pencil.dev", "mock this up on the canvas", "render the spec as a Pencil frame",
or whenever `ux-design` chains into it to materialize its specs.

## How to connect the pencil.dev MCP

Per Pencil's docs, the MCP server is **auto-registered** by the Pencil IDE extension — there is no
manual `claude mcp add` step in the documented flow:

1. Install the **Pencil extension** in VS Code or Cursor.
2. Open a **`.pen`** file and make sure **Pencil is running**.
3. The extension auto-populates the host's MCP config with a local `pencil` server (a local binary,
   e.g. `mcp-server-darwin-arm64 --app visual_studio_code`).
4. Confirm it's connected by running **`/mcp`** (Claude Code / Codex) — `pencil` should be listed.

If it isn't listed, this skill will tell you and degrade gracefully (below). Exact paths/versions
vary by install — the skill **discovers** the tools at runtime rather than hardcoding them.

## How `ux-design` calls it

`ux-design` passes a **screen spec** and expects a **screen/frame reference back**:

```
ux-design  →  [screen spec: name, layout, components, states, content]  →  pencil
pencil     →  Pencil MCP  →  [.pen screen + frame ids per state + screenshot]  →  ux-design
```

The spec shape and the field→operation mapping are documented in
`references/spec-to-screen.md`. The Pencil tool capability map (verified vs. unverified) is in
`references/capability-map.md`.

## Graceful degradation (never fails hard)

If **no Pencil MCP server is connected**, the skill does **not** error. It states clearly that no
real screen was created and emits the **normalized textual spec** as the deliverable, plus a one-line
reminder of how to connect Pencil. So `ux-design` (or you) always get a usable result.

## Honest limitations

- The Pencil MCP **tool names** are documented, but the exact **parameter schemas** of `batch_design`
  are not fully published — the skill reads them from the live tool schema at runtime. Spots that
  need the live schema are marked `TODO: FILL WHEN PENCIL MCP CONNECTED` in the references.
- Pencil's docs describe **local `.pen` files**, not a hosted **shareable URL** per screen. The skill
  therefore returns the `.pen` reference + screenshot and will surface a share URL **only if** a
  future Pencil version actually exposes one. It will not fabricate a link.

## Portability

Targets Claude Code, Codex, and opencode. See `PORTABILITY.md` for per-platform install and the
Pencil MCP connection notes.
