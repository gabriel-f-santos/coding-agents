# figma skill

The **integration layer** that turns a *screen spec* into a real **Figma frame** and returns its
shareable link. It is what the `ux-design` skill (and users) call to make designs real.

## What it is

`ux-design` decides *what* a screen should be (layout, components, states, content) and writes a
**screen spec**. The `figma` skill takes that spec, talks to a connected **Figma MCP server**, and
**creates or updates the matching frame**, then hands back the **Figma URL**. It is deliberately
*not* a designer — it faithfully translates a finished spec into Figma nodes.

```
ux-design ──(screen spec)──▶ figma ──(Figma MCP)──▶ Figma file ──(share link)──▶ back to caller
```

## When to use it

- A screen spec exists and you want it as a Figma frame (or want an existing frame updated).
- Someone asks for a "Figma mockup / link" for a described screen.

**Not for:** pencil.dev (use the `pencil` skill), non-Figma tools (Sketch/Penpot/XD), writing the
spec itself (that's `ux-design`), or turning an existing Figma design into code (design-to-code).

## Connect the Figma MCP

This skill needs a Figma MCP server connected to your agent host. Options:

1. **Official Figma Dev Mode MCP server** (recommended). Per Figma's docs, enable the Dev Mode MCP
   server in the Figma desktop app (Preferences → Dev Mode MCP server) for the **local** server,
   or configure the **remote/SSE** server endpoint. Full **write** access (create/update frames,
   components, variables) requires a **Dev or Full seat**; Starter/View seats get a reduced,
   rate-capped read set. Add the server to your host's MCP config:
   - **Claude Code:** add the Figma MCP server to your Claude Code MCP configuration.
   - **Codex:** register it; `agents/openai.yaml` already declares `mcp_servers: [figma]`.
   - **opencode:** add it to your opencode MCP configuration.
2. **Community servers** (e.g. Framelink MCP for Figma, Figma Console MCP) — these expose
   different tool names; the skill discovers them at runtime, but you may need to refresh the
   capability map (see below).

Authentication is handled by the MCP server's own config (OAuth / token). **Never paste a Figma
token into the chat** — the skill will not ask for one.

## How `ux-design` calls it

`ux-design` invokes `figma` and passes a **screen spec** (screen name, layout, components, states,
content — canonical shape in `references/spec-to-frame.md`). It expects **a Figma frame link back**.
- **Success:** the skill returns `Frame / Link / Created-updated / Gaps`.
- **No Figma MCP connected:** the skill returns the **textual spec block** (no link). `ux-design`
  treats the absence of a link as the "Figma not connected" signal and can surface the spec to the
  user instead.

## Graceful degradation

If no Figma MCP is discoverable at runtime, the skill **does not fail**. It says so plainly, points
to this README's "Connect the Figma MCP" section, and emits the full textual screen spec so the
work is preserved and ready to push once a server is connected.

## Runtime discovery & the capability map

The skill **discovers** the Figma MCP tools at runtime (via `ToolSearch`) instead of hardcoding
unverifiable names. `references/capability-map.md` documents the *expected* official Dev Mode MCP
tools (e.g. `get_metadata`, `get_design_context`, `get_variable_defs`, `search_design_system`,
`use_figma`, `create_new_file`, `upload_assets`) and contains **"TODO: FILL WHEN FIGMA MCP
CONNECTED"** markers for the exact parameter schemas and share-link field — fill those in once a
real server is connected, since they vary by server version and plan.

## Files

```
figma/
├── SKILL.md                      # router + workflow (discover → read → create/update → link)
├── README.md                     # this file
├── PORTABILITY.md                # Claude Code / Codex / opencode setup
├── agents/openai.yaml            # Codex sidecar — declares the figma MCP dependency
└── references/
    ├── capability-map.md         # runtime discovery + expected Figma MCP tool map + TODOs
    └── spec-to-frame.md          # screen-spec contract + spec→frame translation plan
```

## Cross-platform

Targets Claude Code, OpenAI Codex, and opencode. See `PORTABILITY.md` for per-runtime setup.
