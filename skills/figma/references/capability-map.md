# Figma MCP Capability Map

How to discover the connected Figma MCP server and map a screen-spec need to the right MCP tool.

> **Read this when:** you need to know which MCP tool does what, or to bind a spec field to a
> concrete create/update operation. **Always confirm the live tool exists this session** via
> `ToolSearch` before calling it — names, availability, and parameters vary by Figma plan
> (Starter vs Dev/Full seat), client, and server version.

## Runtime discovery (do this first — do not hardcode)

1. Run `ToolSearch` with the keyword `figma` to surface any connected Figma MCP tools, then
   `ToolSearch` with `select:<name>,<name>` to load the exact schemas you intend to call.
2. If the host can list MCP servers/resources, use it to confirm a Figma server is connected.
3. Match what you found against the **expected tool table** below. Bind to the tools actually
   present. If none are present → graceful degradation (SKILL.md Step 5).

## Expected tools (official Figma Dev Mode MCP server)

Verified from the official Figma MCP docs (developers.figma.com/docs/figma-mcp-server/) as of the
2026 research date. Treat as **expected, not guaranteed** — confirm live. Tools marked *(remote)*
require the remote/SSE server and a paid Dev/Full seat for full write access; the local server and
Starter/View seats expose a reduced set with monthly call caps.

### Read tools (gather context before writing)

| Tool | Use it to… | Spec relevance |
|---|---|---|
| `get_metadata` | get sparse XML of layer IDs/names/types/positions/sizes | locate the frame to update; check what exists |
| `get_screenshot` | screenshot the selection for layout fidelity | verify result; show before/after |
| `get_design_context` | pull design styling info for a node | understand existing styling before editing |
| `get_variable_defs` | list variables/styles (color, spacing, type) in use | reuse design tokens instead of raw values |
| `search_design_system` *(remote)* | search subscribed libraries for components/variables/styles | reuse design-system components for spec components |
| `get_libraries` *(remote)* | list subscribed/available libraries | find the right library to draw components from |
| `whoami` *(remote)* | authenticated user + plan/seat | detect whether write tools are even available |

### Write tools (create / update the frame)

| Tool | Use it to… | Spec relevance |
|---|---|---|
| `use_figma` *(remote)* | general-purpose create/edit/delete of objects in Design/FigJam/Slides | the primary tool to build/update the frame, regions, components, states |
| `create_new_file` *(remote)* | create a blank Design/FigJam/Slides file | when the spec targets a brand-new file |
| `generate_figma_design` *(remote, select clients)* | convert UI code → design layers | alternative path if you already have UI code, not a textual spec |
| `upload_assets` *(remote)* | upload PNG/JPG/GIF/WebP into a file | place spec content that includes imagery |
| `generate_diagram` *(remote)* | build a FigJam diagram from Mermaid/description | flow diagrams, not screen frames |

(Code Connect tools — `get_code_connect_map`, `add_code_connect_map`,
`send_code_connect_mappings`, `get_context_for_code_connect`, `get_code_connect_suggestions` —
map Figma nodes to code components. Not needed for spec→frame authoring; ignore unless asked.)

## Spec field → operation mapping

| Spec field | How to realize it in Figma |
|---|---|
| **Screen name** | Frame name; create or locate the frame by this name |
| **Layout / regions** | Auto-layout frame structure (header/body/footer, columns, spacing from tokens) |
| **Components** | Prefer design-system instances found via `search_design_system`; else build the component |
| **States** | Separate frames or variants per state (empty / loading / error / filled) |
| **Content** | Text nodes + sample data; `upload_assets` for any imagery |
| **Return: share link** | Read the node URL / share link from the write-tool result; return it |

## TODO: FILL WHEN FIGMA MCP CONNECTED

The exact request/response **parameters** of the write tools (especially `use_figma` and
`create_new_file`) are not pinned here because they vary by server version and are best read
live. When a real Figma MCP is connected:

- [ ] **TODO:** Run `ToolSearch select:use_figma` (and `create_new_file`, `search_design_system`,
  `get_variable_defs`) and record the exact parameter schemas here.
- [ ] **TODO:** Confirm how the create/update result returns the **shareable link / node URL**
  (field name in the tool result) so Step 4 can extract it deterministically.
- [ ] **TODO:** Confirm whether your connected server is **local** (reduced toolset, no remote
  write tools) or **remote/SSE** (full write), and note the seat/plan requirement.
- [ ] **TODO:** If using a **community server** (e.g. Framelink, Figma Console MCP), its tool
  names differ — re-derive this whole table from that server's `ToolSearch` output.

Until these are filled, **discover and confirm each tool's schema at call time** rather than
guessing parameters. Never invoke a tool whose schema you have not loaded this session.
