# ux-design

Turns a **validated product vision into screens and user flows**, and renders them via a
connected design tool (the `pencil` or `figma` skill, or a design MCP) — degrading to textual
wireframes when nothing is connected.

## When to use
After `product-discovery` (you have a discovery brief / PRD with personas, journeys, features)
and you want the UI: screen inventory, user flows, and a screen spec per screen. Standalone —
it's not a required pipeline gate, but its output feeds the PRD and the implementation plan.

## What it does
1. Reads the vision (`docs/discovery/<slug>-discovery.md` / `docs/prd-<slug>.md`) — it does **not**
   regenerate personas/journeys/features.
2. Derives the information architecture (screen inventory), mapping each screen to the
   feature/requirement it serves.
3. Maps user flows (mermaid), surfacing missing screens (empty/error/confirmation).
4. Writes a screen spec per screen (layout, components, **all states**, actions).
5. Renders via the best available tool (`pencil`/`figma` skill → design MCP → wireframes).
6. Writes **`docs/design/<slug>/summary.md`** — the findable index the implementation plan
   references.

## Output (findable, committed)
- `docs/design/<slug>/summary.md` — the index: screen→feature mapping, flows, frame links, open
  questions. **This is the file `plan-phase`/`implement-phase` reads to know what screens to build.**
- `docs/design/<slug>/screens/<screen>.md` — one spec per screen.

(Unlike review reports, design output is durable and committed — it's a reference, not ephemeral.)

## Rendering tools
Install the `pencil` and/or `figma` skill (see their READMEs) and connect their MCP, and
ux-design will push each screen spec to it and collect the frame links. With no tool connected it
still delivers the inventory + flows + specs as textual wireframes.

## Invoke
- Claude Code / opencode: `/ux-design`
- Codex: `$ux-design`
- Or implicitly: "gera as telas dessa feature", "desenha o protótipo de telas".

## Portability
Portable across Claude Code / Codex / opencode. See `PORTABILITY.md`. `allowed-tools` is honored
only by Claude Code.
