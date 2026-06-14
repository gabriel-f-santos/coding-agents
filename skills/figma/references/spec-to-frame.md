# Screen Spec → Figma Frame

The canonical screen-spec shape this skill consumes, and how to translate it into a Figma frame.

> **Read this when:** validating an incoming spec (Step 1) or building the create/update plan
> (Step 4). For which MCP tool performs each operation, see `capability-map.md`.

## The screen spec (input contract)

`ux-design` produces — and a user may hand over — a spec with these fields. Treat missing fields
as **gaps to report**, not values to invent.

```
# Screen: <screen name>            # e.g. "Checkout — Payment"
Layout:                            # structural regions, top→bottom / grid
  - <region>: <what it holds, alignment, spacing intent>
Components:                        # each with variant/props it should show
  - <Component> (<variant/state>): <purpose>
States:                            # the screen-level states to render
  - <empty | loading | error | filled | success | …>: <what changes>
Content:                           # real-ish copy + sample data, not lorem
  - <key>: <text / value>
Tokens (optional):                 # design-system tokens to honor
  - color/space/type references
```

A minimal valid spec needs at least **screen name** + **layout** + **components**. States and
content strongly improve the result but you can proceed and flag them as gaps.

## Translation plan (build before calling the write tool)

1. **Resolve target.** New file or existing frame? If existing, run a read tool
   (`get_metadata`) to find the frame by name and read current structure so you *update* it.
2. **Reuse the design system.** Run `search_design_system` / `get_variable_defs` to find
   existing components and tokens; map each spec component to a library instance and each
   color/spacing/type to a variable. Only build from scratch what the library lacks.
3. **Lay out regions.** Express the layout as auto-layout: direction, gap (from spacing tokens),
   padding, alignment. One auto-layout container per region.
4. **Place components.** Instance the resolved components into their regions with the spec'd
   variants/props.
5. **Render states.** Each screen-level state → its own frame (named `<Screen> — <state>`) or a
   component variant set, so empty/loading/error/filled are all visible.
6. **Fill content.** Put the spec's copy and sample data into text nodes; `upload_assets` for any
   imagery referenced.
7. **Get the link.** Read the shareable node URL from the write result and return it.

## Frame naming

- Frame: the screen name verbatim (`Checkout — Payment`).
- Per-state frames: `<Screen> — <State>` (`Checkout — Payment — Error`).
- Keep names stable across runs so updates target the same frame instead of duplicating.

## Output contract (what this skill returns to the caller)

On success:

```
Frame: <screen name>
Link:  <figma node/share URL>
Created/updated: <regions, components, states realized>
Gaps:  <missing spec fields, if any>
```

On no-MCP (degradation): the textual spec block from SKILL.md Step 5 (no link). The absence of a
link is the caller's signal that Figma was not connected.

## TODO: FILL WHEN FIGMA MCP CONNECTED

- [ ] **TODO:** Once the live `use_figma` / `create_new_file` schemas are known (see
  `capability-map.md`), record the exact node/auto-layout payload shape used in steps 3–5 so the
  translation is deterministic rather than per-session improvised.
