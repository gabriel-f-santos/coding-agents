# Codex sidecar — place at  <skill>/agents/openai.yaml
# Tool/dependency control for Codex lives HERE, not in SKILL.md frontmatter.

# Required external systems — Codex fails fast if a listed MCP server / skill is missing.
dependencies:
  mcp_servers: []        # e.g. [linear, github]
  skills: []             # companion skills this one chains to

# Set to false so Codex won't auto-invoke on prompt match — explicit  $skill-name  still works.
# Use for destructive or expensive skills.
allow_implicit_invocation: true

# Optional UI metadata
# display_name: "{{SKILL_TITLE}}"
# category: "{{CATEGORY}}"
