# Platform Reference — Claude Code · OpenAI Codex · opencode

What each runtime actually supports. Verified June 2026. When in doubt, the official docs
(linked at the bottom) override this file.

---

## The shared base (agentskills.io)

All three converge on the **Agent Skills open standard**:

- A skill is a directory `<name>/` containing **`SKILL.md`** (required).
- `SKILL.md` = YAML frontmatter + markdown body.
- Optional bundled resources: `scripts/`, `references/`, `assets/`.
- **Only five frontmatter fields are part of the spec:** `name` (req), `description` (req),
  `license`, `compatibility`, `metadata` (string→string map). **Unknown fields are ignored.**
- Progressive disclosure: metadata always loaded (~100 tokens), body on activation,
  bundled resources on demand.

Everything below the base is per-platform.

---

## Claude Code

| Aspect | Detail |
|---|---|
| **Skill dirs** | `~/.claude/skills/<name>/` (user), `<project>/.claude/skills/<name>/` (project). Project overrides user on name collision. |
| **Extra frontmatter** | `allowed-tools`, `disallowed-tools`, `disable-model-invocation`, `effort` (`low`…`max`), `model` |
| **Tool restriction** | In frontmatter. Scoped syntax: `allowed-tools: Read Grep Glob` or `Bash(git add *) Bash(git commit *)` — the glob mathematically blocks `git push`/`rm -rf`. |
| **Block auto-invoke** | `disable-model-invocation: true` (reserves the skill for explicit `/name`). ⚠️ Historically buggy on some builds (2.1.92 hid the skill entirely) — test on target build. |
| **Dynamic context** | Supports `` !`cmd` `` (runs at load) and `${CLAUDE_SKILL_DIR}`. **Claude-only — does not expand elsewhere.** |
| **Invocation** | Slash menu `/name` (explicit) + semantic (implicit). |
| **Validation** | `name` must match the directory name. |

Tool names are Claude's: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `Task`, `WebFetch`…

---

## OpenAI Codex

| Aspect | Detail |
|---|---|
| **Skill dirs** | `~/.codex/skills/<name>/` (user), `<project>/.codex/skills/<name>/` (project). |
| **Enable/disable** | Per-project in `~/.codex/config.toml` under `[[skills.config]]` with `path` + `enabled`. **Restart Codex** after editing. |
| **Extra frontmatter** | None honored beyond the 5 standard fields — extras ignored. |
| **Sidecar metadata** | Optional `agents/openai.yaml` for UI metadata, `dependencies` (required MCP servers / companion skills), and `allow_implicit_invocation`. |
| **Tool/dep control** | Declare needs in `openai.yaml` `dependencies` — prevents failure when an MCP server is missing. **Not in SKILL.md frontmatter.** |
| **Block auto-invoke** | `allow_implicit_invocation: false` in `openai.yaml` (explicit `$name` still works). |
| **Invocation** | `$name` (explicit) + implicit. |
| **Strength** | MCP orchestration, multi-agent CI (autonomous PR review in background agents). |

`config.toml` holds local environmental bindings / API keys; `SKILL.md` holds portable
procedural logic. Keep them separate.

Example `config.toml` entry:

```toml
[[skills.config]]
path = "~/.codex/skills/my-skill/SKILL.md"
enabled = true
```

---

## opencode

| Aspect | Detail |
|---|---|
| **Skill dirs (scan order)** | `.opencode/skills/<name>/`, `~/.config/opencode/skills/<name>/`, **`.claude/skills/<name>/`**, **`~/.claude/skills/<name>/`**, `.agents/skills/<name>/`, `~/.agents/skills/<name>/`. Walks up to the git worktree root for project paths. |
| **Claude compatibility** | **Reads `.claude/skills/` natively** — a skill placed there is discovered by Claude Code *and* opencode with zero changes. |
| **Frontmatter** | Strictly the 5 standard fields. *"Unknown frontmatter fields are ignored."* `allowed-tools`/`effort`/`disable-model-invocation` are **inert** here. |
| **Tool restriction** | In the user's `opencode.json` under `permission.skill` patterns: `"allow" \| "deny" \| "ask"`. **Outside the skill.** |
| **Block auto-invoke** | Set the skill's pattern to `"deny"` or `"ask"` in `opencode.json`. |
| **Invocation** | `/name` + semantic. |
| **Validation** | `SKILL.md` in all caps; `name` 1–64 lowercase-alphanumeric, single hyphens, matches dir; `description` 1–1024 chars; names unique across all scanned locations. |

Example `opencode.json` permission block:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "my-destructive-skill": "ask"
    }
  }
}
```

---

## Cross-platform cheat: "where does X live?"

| Need | Claude Code | Codex | opencode |
|---|---|---|---|
| Restrict tools | `allowed-tools` (frontmatter) | `dependencies` (`openai.yaml`) | `permission.skill` (`opencode.json`) |
| Don't auto-invoke | `disable-model-invocation: true` | `allow_implicit_invocation: false` (`openai.yaml`) | `"deny"`/`"ask"` (`opencode.json`) |
| Inject file at load | `` !`cat file` `` | run as a step | run as a step |
| Skill's own dir path | `${CLAUDE_SKILL_DIR}` | relative paths from skill root | relative paths from skill root |
| Explicit call | `/name` | `$name` | `/name` |

---

## Subagent frontmatter (`color`) — not a skill field, but a cross-platform trap

Subagents (`.claude/agents/<name>.md`, mirrored to `.opencode/agents/`) carry a `color` accent
in frontmatter. The runtimes disagree on what's valid:

| Runtime | Accepts | On a bad value |
|---|---|---|
| Claude Code | CSS color names (`blue`, `purple`, …) **and** hex | lenient — unknown value falls back to a default, no load error |
| opencode | **6-digit hex `#RRGGBB`** or enum `primary\|secondary\|accent\|success\|warning\|error\|info` | **hard config error** — the agent fails to load |
| Codex | n/a (no subagent color) | — |

**Cross-platform-safe value: a quoted hex** — `color: "#3b82f6"`. It validates in opencode and
Claude Code renders it. **Quote it** — an unquoted `color: #3b82f6` makes YAML read `#…` as a
comment and nulls the field. CSS names like `blue` work only in Claude Code and break opencode
with `Expected a string matching ^#[0-9a-fA-F]{6}$ … got "blue"`. `validate_skill.py` flags an
invalid `color` when one is present.

---

## Sources

- https://agentskills.io/specification
- https://code.claude.com/docs/en/skills
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/config-reference
- https://opencode.ai/docs/skills/
