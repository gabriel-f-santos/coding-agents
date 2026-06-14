# Portability — greenfield-monorepo

This skill is written as a **portable core** (Markdown body + `references/` + `assets/` + `scripts/`),
so it runs on Claude Code, Codex, and opencode. Per-platform control lives in sidecars, not the body.

## Where the skill lives
| Runtime | Location | Notes |
|---|---|---|
| **Claude Code** | `~/.claude/skills/greenfield-monorepo/` (this dir) | canonical copy; reads `allowed-tools` from SKILL.md |
| **opencode** | same `~/.claude/skills/` dir | opencode scans `.claude/skills/` natively — no second copy |
| **Codex** | `~/.codex/skills/greenfield-monorepo/` | needs its own copy (Codex does NOT read `.claude/skills/`) |

### Make the Codex copy (real copy — keep in sync)
```bash
mkdir -p ~/.codex/skills
cp -r ~/.claude/skills/greenfield-monorepo ~/.codex/skills/
```
Or point Codex at the canonical dir via `~/.codex/config.toml`:
```toml
[[skills.config]]
path = "~/.claude/skills/greenfield-monorepo"
```
The Codex tool/dependency control is in `agents/openai.yaml` (travels with the copy).

## Per-platform control
- **Claude Code** — `allowed-tools: Read Write Edit Bash Glob Grep Task AskUserQuestion` in SKILL.md
  frontmatter (Claude-only; ignored elsewhere). This skill writes files and runs shell, so it intentionally
  has `Write`/`Edit`/`Bash`. If you want it explicit-only, add `disable-model-invocation: true`.
- **Codex** — `agents/openai.yaml`: declares the `context7` MCP dependency and optional skill chains;
  `allow_implicit_invocation: true`. Edit there, not in frontmatter.
- **opencode** — ignores `allowed-tools`. Because this skill mutates the filesystem and runs commands,
  set a guard in your `opencode.json` so it asks first:
  ```json
  { "permission": { "skill": { "greenfield-monorepo": "ask" } } }
  ```

## Portable-core rules honored
- No load-time shell preprocessing; the body instructs the agent to *run* commands as workflow steps.
- No Claude skill-dir template variable; bundled files are referenced by **relative path** (`references/…`, `assets/…`).
- Frontmatter limited to the 5 standard fields + `allowed-tools` (inert in Codex/opencode).

## Prerequisites for the GENERATED repo (not the skill)
- `docker` + `docker compose` v2 for the dev loop (`task up` / `dev_up.sh`).
- Per-app toolchains to run each app: node (frontend), uv/python (backend), go, flutter — pinned in the
  generated `.tool-versions`. The skill flags missing toolchains in its plan instead of failing mid-build.
