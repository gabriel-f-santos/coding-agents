# Screen Spec → Pencil Screen — Mapping & Degradation

How to turn a **screen spec** into Pencil design operations, and exactly what to emit when no Pencil
MCP is connected. Read alongside `capability-map.md` (which tools exist) — this file is *how to use
them*.

## The screen spec (normalized shape)

`ux-design` should pass (and this skill should normalize to) these fields. Fill defaults + note the
assumption when a field is absent — never block.

```yaml
screen:
  name: "Login"                 # unique screen identifier on the canvas
  layout:                       # structure: regions, grid, responsive intent
    type: "single-column"       # e.g. single-column | sidebar+content | grid-12 | dashboard
    regions: [header, body, footer]
  components:                   # ordered, hierarchical
    - { type: "AppBar", children: [logo, nav] }
    - { type: "Form", children: [EmailField, PasswordField, SubmitButton] }
  states: [default, loading, error, empty]   # which states to realize as frames/variants
  content:                      # real copy + sample data (not lorem when avoidable)
    title: "Welcome back"
    submit_label: "Sign in"
    error_text: "Invalid credentials"
```

## Field → operation mapping

| Spec field | Pencil operation (via discovered tools) |
|---|---|
| `screen.name` | `batch_get` to check if it exists → decide **create** vs **update**; name the top-level frame. |
| `layout` | A top-level **frame** per screen; child frames/auto-layout groups per region. Use `batch_design` insert ops; respect the grid/region structure. |
| `components` (hierarchy) | One insert op per component, parented to its region frame; preserve nesting order. Reuse Pencil/library components by name where the spec references a design system. |
| `states` | Realize each state as a **separate frame or variant** of the screen (e.g. `Login / default`, `Login / error`), so a reviewer sees all states on the canvas. |
| `content` | Set text/props on the inserted elements; use `batch_design` image generation only for placeholder imagery, not real product data. |
| theme/tokens (optional) | `set_variables` only if the spec carries tokens; otherwise inherit the file's existing theme. |

> **TODO: FILL WHEN PENCIL MCP CONNECTED** — replace the prose above with the **exact `batch_design`
> op objects** once the live schema is read in Step 1 (e.g. the JSON for an insert-frame op, an
> insert-component op, and a set-text op). The verbs are documented; the argument shapes are not — do
> not invent them, capture them.

## Create-vs-update (idempotency)

1. `get_editor_state` → which `.pen` file is active.
2. `batch_get` by `screen.name` → exists?
   - **No** → insert a new top-level frame and build from scratch.
   - **Yes** → diff the spec against what's there; update/move/replace changed elements, delete
     removed ones. Prefer minimal ops over wiping and re-creating, so manual canvas tweaks survive.

## Verify before returning

- `get_screenshot` → render the screen; eyeball it against the spec.
- `snapshot_layout` → catch overlaps / off-canvas / broken positioning. If it flags issues, fix with
  one corrective `batch_design` pass, then re-screenshot.

## Return artifact

Hand back to `ux-design`/the user:
- **Screen reference** — the `.pen` file path + the screen/frame id(s) (and per-state frame ids).
- **Screenshot** — from `get_screenshot`, if the host can surface it.
- **Unrealized fields** — anything in the spec you couldn't place on the canvas, so the caller knows.
- **Shareable URL** — only if the live MCP actually exposes one (see `capability-map.md` UNVERIFIED).
  Otherwise omit it; do **not** fabricate a link.

## §Degradation — no Pencil MCP connected

When Step 1 finds **no** Pencil tools, do not error. Produce this instead:

```
⚠️ No Pencil MCP server is connected — I did not create a real pencil.dev screen.
Here is the normalized screen spec so you still have a usable deliverable:

Screen: <name>
Layout: <type> — regions: <…>
Components (hierarchy):
  - <component> > <child> > …
States: <default | loading | error | …>
Content:
  <key>: <value>

To create this for real: install the Pencil extension, open a .pen file, ensure Pencil is
running, then re-run me (verify with /mcp). See README.md → "Connect the Pencil MCP".
```

The degraded output is the **normalized spec from Step 2**, rendered as readable text — same content
that *would* have driven the canvas. This keeps the integration useful even with Pencil absent, and
lets `ux-design` proceed or fall back to its own textual artifact.
