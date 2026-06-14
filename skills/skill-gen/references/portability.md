# Portability — what travels, what breaks, where to place files

The job of `skill-gen` is to keep the **portable core** clean and push every platform quirk
into a sidecar. This file is the rulebook.

---

## The three buckets

### ✅ Travels to all three (build everything here)

- The markdown **body** of `SKILL.md` (instructions, checklists, templates).
- `references/`, `scripts/`, `assets/` directories.
- Frontmatter limited to the **5 standard fields**: `name`, `description`, `license`,
  `compatibility`, `metadata`.
- Workflow steps that *instruct the agent to run a command* (e.g. "run `git diff --staged`
  and read the output") — these use whatever shell tool the host provides.

### ⚠️ Inert outside Claude Code (harmless to include)

- `allowed-tools`, `disallowed-tools`, `effort`, `model`, `disable-model-invocation`.
- Codex and opencode **ignore** these — no error, no effect. Safe to leave for Claude users,
  but never *rely* on them for portable safety.

### ❌ Breaks outside Claude Code (must avoid in portable skills)

- `` !`cmd` `` load-time shell preprocessing — does not expand in Codex/opencode; the literal
  backtick text leaks into context.
- `${CLAUDE_SKILL_DIR}` and other Claude template variables — won't resolve.
- Assuming the slash-command name format (`/name` vs Codex `$name`).

> **Rewrite rule.** Any `` !`cat ${CLAUDE_SKILL_DIR}/templates/x.tpl` `` becomes a workflow
> step: *"Read `assets/templates/x.tpl` (relative to this skill's directory) and use it as the
> skeleton."* The agent resolves the relative path itself in every runtime.

---

## Placement matrix

Pick install path(s) from the runtime targets:

| Targets | Where to write the skill | Extra emitted |
|---|---|---|
| Claude Code only | `.claude/skills/<name>/` | — |
| Claude Code + opencode | `.claude/skills/<name>/` (opencode reads it natively) | `PORTABILITY.md` if it needs tool restriction |
| Codex only | `.codex/skills/<name>/` + `config.toml` entry | `agents/openai.yaml` |
| All three | `.claude/skills/<name>/` **and** `.codex/skills/<name>/` (copy) | `agents/openai.yaml` + `PORTABILITY.md` |
| Broadest cross-client | `.agents/skills/<name>/` | per targets above |

Notes:
- **One copy covers Claude Code + opencode** because opencode scans `.claude/skills/`.
- Codex does **not** read `.claude/skills/`, so it needs its own copy or a `config.toml`
  `path` pointing at the canonical location.
- Keep the two copies in sync, or symlink if the user's OS/workflow allows it (note: symlinks
  are flagged by security scanners — prefer a real copy + a note).

---

## PORTABILITY.md (emit when >1 runtime)

Generate this alongside any multi-target skill so the user knows what to configure where.
Template: `assets/templates/PORTABILITY.md.tpl`. It must state, concretely:

- which file lives where (and which copies must stay in sync);
- the Codex `config.toml` `[[skills.config]]` entry to add;
- the opencode `opencode.json` `permission.skill` snippet (only if the skill needs
  restriction — otherwise opencode allows by default);
- which frontmatter fields are Claude-only and therefore inert elsewhere.

---

## Decision flow

```
Is the skill Claude-only?
├── yes → load-time exec + skill-dir variable OK; put control in frontmatter. Done.
└── no  → portable core only:
         ├── strip load-time exec & template vars (rewrite as steps)
         ├── frontmatter = 5 fields (+ allowed-tools for Claude users, inert elsewhere)
         ├── Codex target?    → emit agents/openai.yaml
         ├── opencode target? → note permission.skill in PORTABILITY.md (only if restricting)
         └── >1 runtime?      → emit PORTABILITY.md
```
