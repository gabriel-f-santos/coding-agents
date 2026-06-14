# Frontmatter Reference

Every field, its constraints, and which runtime honors it. Build the portable core from the
**Standard** rows; add others only as platform sidecars.

## Standard fields (all three runtimes)

| Field | Required | Constraints | Purpose |
|---|---|---|---|
| `name` | ✅ | ≤64 chars, lowercase alphanumeric + single hyphens, no leading/trailing hyphen, **must match the directory name** | Unique identifier; used for `/name` (CC/opencode) or `$name` (Codex). |
| `description` | ✅ | 1–1024 chars, non-empty | **The semantic trigger.** State what it does AND exactly when to use it, with real trigger phrases. This is the single most important field — see "Writing the description" below. |
| `license` | ➖ | License name or file ref | IP terms for shared/proprietary skills. |
| `compatibility` | ➖ | ≤500 chars | Environmental prerequisites: binaries (`docker`, `jq`), runtimes (`Requires Python 3.14+`), network access. |
| `metadata` | ➖ | string→string map | Arbitrary properties (author, version, MCP requirement notes). Unknown to the spec but preserved. |

## Claude Code-only fields (inert in Codex/opencode)

| Field | Constraints | Purpose |
|---|---|---|
| `allowed-tools` | space/comma list or YAML list; scoped `Bash(git add *)` | Pre-approved tools without per-call auth. **Primary least-privilege control in Claude Code.** |
| `disallowed-tools` | list | Removes capabilities while active. |
| `disable-model-invocation` | boolean | `true` = explicit `/name` only. For destructive/expensive skills. (Test on target build.) |
| `effort` | `low\|medium\|high\|xhigh\|max` | Overrides reasoning-token budget for this skill. |
| `model` | model id | Forces a specific model for the skill. |

## Codex sidecar (`agents/openai.yaml`, NOT frontmatter)

```yaml
dependencies:
  mcp_servers: [linear]        # required MCP servers
  skills: [other-skill]        # companion skills
allow_implicit_invocation: false   # explicit $name only
# plus optional UI metadata
```

## opencode (NOT in the skill at all → user's `opencode.json`)

```json
{ "permission": { "skill": { "<name>": "allow|deny|ask" } } }
```

---

## Writing the description (highest-leverage step)

The description is matched against user intent — it is **not** for humans. Rules:

- State **what it does + when to trigger**, with concrete phrases a real user would type
  (formal and casual, including cases where they don't name the skill/filetype explicitly).
- Be a little **"pushy"** to fight under-triggering: *"…Use this whenever the user mentions
  X, Y, or Z, even if they don't explicitly ask for it."*
- Add a **negative boundary** to prevent over-triggering: *"Do not use for <near-miss>."*
- Avoid vague ("Helps with PDFs"). Prefer event-listener style: *"Extracts text from PDF
  files. Use when the user mentions PDFs, forms, or document extraction."*

**Example (strong):**

```yaml
description: >
  Generate Conventional Commits messages from staged changes. Use when the user asks to
  "write a commit message", "commit this", or "gera a mensagem de commit", or after staging
  changes with git add. Reads the staged diff, categorizes it (feat/fix/docs/refactor/...),
  and enforces a <72-char imperative subject. Do not use for writing PR descriptions or
  changelogs — those are separate skills.
```

## Common load failures

- **Invalid YAML** (unclosed quote, bad indent) → skill silently not registered. Validate.
- **`name` ≠ directory name** → resolution fails.
- **Empty/oversized `description`** → rejected or under-triggers.
