---
name: pencil
description: >
  Turn a screen spec into a real pencil.dev design screen/frame via the Pencil MCP server, and
  return a reference to the produced design. Use when the user (or the `ux-design` skill) wants to
  "create a screen in Pencil", "generate this UI in pencil.dev", "build the login screen on the
  canvas", "mock this up in Pencil", "render the spec as a Pencil frame", or asks to push a screen
  spec to pencil.dev. It discovers the Pencil MCP at runtime (no hardcoded tool names), maps a
  screen spec (name, layout, components, states, content) onto Pencil design operations, and hands
  back the artifact (a `.pen` file / screen reference, plus a screenshot when available). If no
  Pencil MCP is connected it degrades gracefully and emits the textual spec instead of failing.
  Do NOT use for Figma — for Figma use the `figma` skill; not for other non-pencil design tools, not
  for writing the spec itself (that's `ux-design`), nor for turning a finished design into code.
allowed-tools: Read Write Edit Grep Glob
---

# pencil — pencil.dev integration layer

This skill is the **integration layer** between a *screen spec* and a *real pencil.dev screen*.
`ux-design` (or a user) hands it a spec; it drives the **Pencil MCP server** to create/update the
corresponding design on Pencil's infinite canvas, then hands back a reference to the artifact.

```
ux-design  →  [screen spec]  →  pencil (this skill)  →  Pencil MCP  →  .pen screen + screenshot ref
```

> **Honesty contract.** Pencil's MCP runs **locally** and its design files are `.pen` files in the
> workspace (verified from docs). A hosted **shareable URL** is **not documented** — do not promise
> one. Return whatever the MCP actually gives back (file path, screen/element id, screenshot). See
> `references/capability-map.md` for what is verified vs. unverified.

## Core rules

- **Discover, don't hardcode.** Find the Pencil MCP tools at runtime (Step 1). Tool names below are
  the *documented* set, but always confirm against what the host actually exposes — schemas drift.
- **Degrade gracefully — never fail hard.** No Pencil MCP connected → say so plainly and emit the
  textual spec as the deliverable. A partial canvas still beats a hard error.
- **Treat the spec as the source of truth.** Map every spec field to a design operation; report any
  field you could not realize on the canvas.
- **No secrets in chat.** Pencil auth is handled by the host/extension; never ask the user to paste
  tokens.

## References (load only what the step needs)

| Open when you need to… | Read |
|---|---|
| see the expected Pencil MCP tools, what's verified vs. unverified, and the runtime-discovery recipe | `references/capability-map.md` |
| map a screen-spec field (layout/components/states/content) onto Pencil design operations | `references/spec-to-screen.md` |
| know the exact graceful-degradation output when no MCP is connected | `references/spec-to-screen.md` (§Degradation) |

---

## Workflow (follow in order)

### Step 1 — Discover the Pencil MCP at runtime

Do **not** assume the tool names. Detect what's actually connected:

1. If a tool-search facility exists (e.g. `ToolSearch`), query for `pencil` / `batch_design` /
   `get_editor_state` to surface Pencil MCP tools and their **real** schemas.
2. Otherwise, inspect the available MCP tools the host exposes (in Claude Code/Codex, MCP tools are
   namespaced like `mcp__pencil__<tool>`; the user can run `/mcp` to confirm Pencil is listed).
3. Match what you find against the expected capability map in `references/capability-map.md`.

If **no** Pencil tool is found → jump to Step 5 (degrade gracefully). Do not invent calls.

### Step 2 — Ingest & normalize the screen spec

Accept the spec from `ux-design` or the user. Normalize it to: **screen name**, **layout**
(structure/regions/grid), **components** (with hierarchy), **states** (default/empty/loading/error/…),
and **content** (copy, sample data). If any of these is missing, fill sensible defaults and note the
assumption — don't block. Read `references/spec-to-screen.md` for the field→operation mapping.

### Step 3 — Read current canvas context (idempotent updates)

Before writing, read the editor/canvas state so you create-or-update instead of duplicating:
- Use the discovered **read** tool (documented: `get_editor_state` for active file/selection, and
  `batch_get` to search existing elements/components by name/pattern).
- If a screen with this name already exists, plan an **update**; otherwise plan a **create**.

### Step 4 — Generate / update the screen, then verify

- Apply the spec via the discovered **write** tool (documented: `batch_design` — insert/update/
  move/replace/delete operations; can also generate images). Build the layout, place components in
  hierarchy, set content, and represent each state (e.g. as separate frames/variants — see
  `references/spec-to-screen.md`).
- Verify visually with the discovered **screenshot** tool (documented: `get_screenshot`) and the
  layout checker (documented: `snapshot_layout`) to catch overlaps/positioning issues. Iterate once
  if the render diverges from the spec.
- Sync theme/tokens only if the spec demands it (documented: `get_variables` / `set_variables`).

> **TODO: FILL WHEN PENCIL MCP CONNECTED** — confirm the *exact* operation verbs and required
> parameters of `batch_design` (e.g. the shape of an "insert frame" / "insert component" op) against
> the live schema before relying on them. The names are documented; the precise argument objects are
> **not fully published** — read them from the runtime tool schema in Step 1.

### Step 5 — Return the artifact (or degrade)

**If the MCP ran:** return what Pencil actually produced —
- the **screen / frame reference** (the `.pen` file path and/or the element/screen id),
- the **screenshot** from `get_screenshot` when available,
- a short note of any spec field that couldn't be realized.

> **TODO: FILL WHEN PENCIL MCP CONNECTED** — if a future Pencil version exposes a hosted/shareable
> **URL** for a screen, surface it here as the primary deliverable. As of the documented version, no
> such URL exists; **do not fabricate a link** — return the `.pen` reference + screenshot instead.

**If no MCP was connected (graceful degradation):** state clearly *"No Pencil MCP server is connected,
so I did not create a real screen."* Then emit the **normalized textual spec** (the Step 2 output) as
the deliverable so `ux-design`/the user still gets value, plus one line on how to connect Pencil (see
`README.md` → "Connect the Pencil MCP"). Never throw a hard error.

## Output format

Return: **Status** (created / updated / degraded-textual) · **Artifact** (`.pen` path + screen id,
or the textual spec) · **Screenshot** (if any) · **Unrealized spec fields** (if any) · **Next step**.
