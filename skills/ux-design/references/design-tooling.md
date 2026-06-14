# Design Tooling — progressive disclosure of rendering capability

Don't hardcode a design tool. **Discover** the available rendering capability at runtime and use
the best one present; always degrade gracefully so the design is delivered even with nothing
connected.

## Order of preference

1. **A design skill is installed** — `pencil` or `figma` (authored with skill-gen; they
   encapsulate how to talk to their MCP). This is the preferred path: hand the skill a screen
   spec, get back a frame/screen link.
   - Check the available-skills list / invoke the skill. If both `pencil` and `figma` are
     present, **ask the user which to target** (or honor an explicit request).
2. **A design MCP is connected (no wrapper skill)** — discover it via `ToolSearch` (e.g. search
   `figma`, `pencil`, `design`, `frame`). Load the relevant tool schema on demand and call it
   directly. If you do this often, consider authoring the wrapper skill with skill-gen.
3. **Nothing connected → degrade** — emit textual wireframes (ASCII + mermaid) plus the full
   screen specs, and state clearly that no design tool was used and the frames are text-only.

Never fail because no tool is connected. The screen inventory + flows + specs are the real
deliverable; rendered frames are an enhancement.

## Handing a spec to a design skill

Pass the screen spec in the shape those skills expect (name, layout, components, states,
content). They return a link/reference (Figma node URL, or a pencil `.pen` reference + screenshot
— pencil may not expose a hosted URL; record whatever it returns). Collect the links into the
design summary. Render screens **independently** — if one fails, keep the others and note the gap.

## Subagents

When rendering many screens and subagents are available, you may fan out (`Task`) — one render
per screen — for speed; otherwise render sequentially. The `ui-ux-designer` agent can also be
delegated to for visual/layout judgment on a tricky screen.

## Honesty

- Don't claim a frame was created if the tool wasn't actually connected — say "degraded".
- Carry forward whatever reference the tool returns; if it's only a local file or screenshot
  (not a shareable URL), record that, don't pretend there's a link.
