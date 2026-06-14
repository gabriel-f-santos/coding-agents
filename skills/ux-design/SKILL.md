---
name: ux-design
description: >
  Turn a product vision into screens and user flows. Use when someone wants to design the UI
  from a validated product overview — "gera as telas", "desenha as telas dessa feature", "screen
  design", "user flows", "wireframes", "como vai ser a tela de X", "monta o protótipo de telas".
  Reads the product discovery brief / PRD (vision, personas, journeys, features), derives the
  information architecture, maps user flows, writes a screen spec per screen (layout, components,
  states, actions), and RENDERS them via a connected design tool — using the `pencil` or `figma`
  skill / a design MCP if available, else degrading to textual wireframes. Writes a findable
  summary to docs/design/<slug>/summary.md that the implementation plan references. Do not use to
  validate the problem (product-discovery) or to talk to a specific design tool directly (use the
  pencil/figma skill) — this orchestrates the design, the tool skills render it.
allowed-tools: Read Grep Glob Write Task WebSearch ToolSearch
---

# ux-design — from product vision to screens

Take a **validated** product vision and produce the screens, flows, and a findable design
summary. Standalone (not a pipeline gate), but its input is the discovery brief and its output
feeds the PRD and the implementation plan.

```
product-discovery ──► ux-design ──(renders via)──► pencil | figma skill / design MCP → degrade to wireframes
 (visão validada)     telas + flows                                ↓
                      docs/design/<slug>/summary.md  ──referenciado por──►  prd-creator / plan-phase / implement
```

> **It does not regenerate the vision.** Personas, jobs, journeys and features already come from
> `product-discovery`'s brief. ux-design reads them and turns them into UI.

## References (load only what the step needs)
| Open when… | Read |
|---|---|
| run the design process — IA, flows, screen-spec anatomy, states, responsive | `references/design-process.md` |
| pick the rendering path — look for a design skill, then a design MCP, then degrade | `references/design-tooling.md` |
| see the output summary skeleton | `assets/templates/design-summary.md` |

## Workflow

### Step 1 — Read the vision (don't regenerate it)
Read `docs/discovery/<slug>-discovery.md` (and/or `docs/prd-<slug>.md`) for: the value
proposition, **personas**, **jobs-to-be-done**, **core journeys**, and the **features (P0/P1/P2)**.
If none exists, accept an ad-hoc vision the user gives and note it's ungrounded. Fix the **slug**
(reuse the feature slug so the design carries through the pipeline).

### Step 2 — Information architecture
From the features + journeys, derive the **screen inventory**: the set of screens/areas and how
they're organized (nav structure). Each screen maps to the feature(s)/requirement(s) it serves —
keep that mapping; it's what the implementation plan references. → `references/design-process.md`

### Step 3 — User flows
Map each **core journey** to a sequence of screens (a flow). Draw flows as mermaid. Cover the
primary path plus the key alternate/error branches — the flow reveals missing screens (empty
states, confirmations, errors).

### Step 4 — Screen specs
For each screen write a spec: purpose, layout regions, **components**, content, **states**
(empty / loading / error / success / permission-denied), and the actions/transitions out. This
is the durable contract a developer builds from. → `references/design-process.md`

### Step 5 — Render (progressive disclosure of design tooling)
Pick the rendering path in this order (→ `references/design-tooling.md`):
1. A **design skill** is installed (`pencil` or `figma`) → hand it each screen spec; collect the
   returned frame/screen link.
2. Else a **design MCP** is connected (discover via `ToolSearch`) → use it directly.
3. Else **degrade** → emit textual wireframes (ASCII/mermaid) + the specs; note no tool was used.
Ask the user which tool to target if more than one is available. Never fail because no tool is
connected — the specs + wireframes are still the deliverable.

### Step 6 — Write the design summary (the findable reference)
Write `docs/design/<slug>/summary.md` from `assets/templates/design-summary.md`, and one
`docs/design/<slug>/screens/<screen>.md` per screen. The **summary is the index**: screen
inventory (each mapped to its feature/requirement + status), the flows, links to rendered
frames (if any), and open questions. This file is **committed** (durable) so `prd-creator` and
`plan-phase`/`implement-phase` can reference exactly which screens implement what.

### Step 7 — Report
Screen count, the flows, the rendering path used (skill/MCP/degraded) + links, the summary path,
and what's still open. Point the implementation planner at `docs/design/<slug>/summary.md`.

## Output format
Return **Summary** (what was designed) · **Screens** (inventory → feature mapping) · **Flows** ·
**Rendered?** (tool + links, or "degraded — wireframes only") · **File** (`docs/design/<slug>/summary.md`) · **Open questions**.
