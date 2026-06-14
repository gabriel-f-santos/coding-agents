---
name: skill-gen
description: >
  Generate AND iteratively improve production-grade Agent Skills through a guided interview.
  Use whenever the user wants to create, scaffold, author, or design a new skill or set of
  skills — "create a skill", "gera uma skill", "skill para X", "turn this workflow into a
  skill" — OR to improve/fix an existing one ("this skill mis-fired", "it didn't trigger",
  "improve this skill", "optimize the trigger"). Interviews to decide target runtimes (Claude
  Code, Codex, opencode), single vs multiple skills, execution shape, and tools, then writes a
  portable SKILL.md plus references/scripts and per-platform sidecars (Codex openai.yaml),
  tunes the description, and validates. Do not use to run, install, or security-review an
  existing skill (that's skill-scanner), or to tweak non-skill prose — only to author or
  improve a skill.
allowed-tools: Read Write Edit Grep Glob WebSearch WebFetch Task Bash(python3 *) Bash(ls *) Bash(cat *) Bash(mkdir *)
---

# skill-gen — the skill that generates skills

A guided generator for **portable Agent Skills**. It conducts a short interview, picks the
minimum viable shape, and writes a skill that runs across **Claude Code, OpenAI Codex, and
opencode** — isolating each platform's quirks instead of hard-coding one.

> **Core principle.** The base spec recognizes only five frontmatter fields (`name`,
> `description`, `license`, `compatibility`, `metadata`). Everything else
> (`allowed-tools`, `disable-model-invocation`, Codex `openai.yaml`, opencode
> `permission.skill`) is **platform-specific and lives in a different place per runtime**.
> A portable skill keeps its logic in the body + `references/` + `scripts/`, and treats
> per-platform control as a sidecar — never a dependency.

This `SKILL.md` is a **router**. Load only the reference you need for the current step.

| Open when you need to… | Read |
|---|---|
| know exactly what each runtime supports (dirs, frontmatter, tools, invocation) | `references/platforms.md` |
| decide the portable layout and what breaks where | `references/portability.md` |
| look up every frontmatter field and which platform honors it | `references/frontmatter.md` |
| decide what goes in `SKILL.md` vs `references/`/`scripts/`/`assets/` | `references/progressive-disclosure.md` |
| pick an execution shape and decide single vs multiple skills | `references/archetypes-and-splitting.md` |
| (only if the skill must involve the user) elicit well — recommended defaults, calibrate to experience; otherwise default to autonomy | `references/interaction-and-elicitation.md` |
| **find & ground the content** — local code, context7, web, subagent fan-out, then synthesize | `references/research-grounding.md` |
| set least-privilege tools and avoid injection/exfil risks | `references/security.md` |
| **improve/fix an existing skill** from outcomes & examples | `references/iteration.md` |
| **tune the trigger** — reduce false positives/negatives in the description | `references/description-optimization.md` |
| copy a starting skeleton | `assets/templates/` |

---

## Workflow (follow in order)

### Step 0 — Capture intent: create or improve?

First decide the operation:
- **Create** (new skill) → continue with Steps 1–6 below.
- **Improve** (an existing skill mis-fired, didn't trigger, or produced weak output) → switch
  to the iteration loop in `references/iteration.md`: capture the examples, split working vs
  holdout, make the smallest delta, replay, and confirm no regression. Then run Step 5
  (validate) + the description tuning in Step 4b before reporting. Skip the create-only steps.

If the conversation already contains the workflow to capture ("turn this into a skill"),
extract answers from history before asking: the steps taken, tools used, corrections the user
made, input/output formats observed. Only ask what you cannot infer.

### Step 1 — Interview

Ask **one question at a time**, each with your recommended answer, and explore the codebase
instead of asking when the answer is discoverable. Use the `AskUserQuestion` tool when it
fits. Cover these decision axes (full rationale in the linked references):

1. **Purpose & trigger** — What should the skill let the agent do? What user phrases/contexts
   should activate it? What is the expected output? *(The `description` is the trigger — get
   real phrases the user would actually type.)*
2. **Single vs multiple skills** — Is this one cohesive capability, or several with distinct
   triggers/audiences? If triggers diverge, split. → `references/archetypes-and-splitting.md`
3. **Target runtimes** — Claude Code only? + Codex? + opencode? all three? This decides
   install location(s) and which sidecars to emit. → `references/platforms.md`
4. **Execution shape** — pick the simplest adequate one → `references/archetypes-and-splitting.md`:
   - **knowledge** (instructions only)
   - **reference-backed** (heavy domain docs in `references/`)
   - **script-backed** (deterministic automation in `scripts/`)
   - **orchestrator** (drives an external MCP server / API)
5. **Tools & safety** — Read-only, or does it write/run/network? Destructive? Should it be
   barred from auto-invocation? → `references/security.md` + `references/frontmatter.md`
6. **Knowledge volume** — Will the body exceed ~500 lines? If so, plan the
   `references/` split now. → `references/progressive-disclosure.md`

Record the chosen answers as a short spec before writing anything. If the user says "just
vibe with me / skip the interview", collapse to questions 1, 3, and 5 only.

**Prefer autonomy.** A generated skill should act on its own and involve the user only for a
decision genuinely theirs to make, or a real branch the agent can't resolve from context and
sensible defaults. Most skills should lean autonomous. **Only when** the skill must elicit a
choice (or the user is explicitly driving the decision) give it the thinking-partner style — a
recommended default marked "(Recomendado)" with a one-line why, calibrated to the user's
experience. → `references/interaction-and-elicitation.md`. (E.g. `tech-discovery` is
intentionally interactive; a formatter or one-shot generator should just run.)

### Step 1b — Research & ground the content (skip for trivial wrappers)

A skill is only as good as the knowledge curated into it — structure isn't enough. When the
skill encodes domain knowledge that must be correct and current (a library/framework/API, a
security/compliance domain, a methodology, anything with per-language/per-platform detail),
**go find the content** → `references/research-grounding.md`:

- Ground locally first: `Grep`/`Glob` the target repo for real conventions and **gotchas**;
  **check installed versions** and pin research to them; read sibling skills for house style.
- Pull current docs from **context7** (version-specific) for any named library/API; prefer
  primary sources (official docs, RFCs) over blogs; use `WebSearch`/`WebFetch` for recent
  practice.
- Work in **three stages — plan → capture → consolidate** — don't research straight into the
  final references:
  1. **Plan** the questions/dimensions and which source each needs.
  2. **Capture** each result in its **own file** in a scratch workspace **outside the skill**
     (`<workspace>/<slug>/raw/NN-*.md`), one per dimension — **fan out with subagents (`Task`)**,
     one per item, each writing its own file with provenance + confidence.
  3. **Consolidate** the workspace into one reference file per domain (the Sentry pattern),
     verifying non-obvious claims against a second source first. The raw workspace doesn't ship.
- Degrade gracefully if subagents/web/context7 aren't available (run inline; flag confidence).

Skip this step for a thin procedural wrapper with no external knowledge. Output: a short
research log (findings + sources + gaps) that feeds the authoring step.

### Step 2 — Decide layout

From the interview, fix:
- the **directory name** (= `name`, 1–64 chars, lowercase, single-hyphen separators);
- the **install path(s)** per target runtime (see `references/portability.md` §placement);
- the **bundled resources** (`references/`, `scripts/`, `assets/`) the shape requires.

Default to `.claude/skills/<name>/` when targeting Claude Code **and** opencode — opencode
reads `.claude/skills/` natively, so one copy covers both. Add a `.codex/skills/<name>/` copy
(or a `config.toml` entry) only when Codex is a target. Use `.agents/skills/<name>/` when the
user wants the broadest cross-client convention.

### Step 3 — Write the portable core

Start from `assets/templates/SKILL.md.tpl`. Rules:
- Frontmatter carries the **five standard fields** + (only if Claude is a target)
  `allowed-tools`. Unknown fields are harmless in opencode/Codex (ignored) but keep them
  minimal. → `references/frontmatter.md`
- Body in **imperative voice**, trigger-rich, explaining the *why* — not heavy-handed MUSTs.
- **No `!`cmd`` load-time execution and no `${CLAUDE_SKILL_DIR}`** unless the skill is
  Claude-only — those don't expand in Codex/opencode. Instead, instruct the agent to *run*
  the command as a workflow step ("run `ls -la` and read the output").
- Keep `SKILL.md` under ~500 lines; route heavy material into `references/` with explicit
  "open when…" pointers. → `references/progressive-disclosure.md`
- Use checklists, tables, and **template anchoring** (embed exact output skeletons) over
  prose.

### Step 4 — Emit per-platform sidecars (only for chosen targets)

- **Claude Code** — `allowed-tools` (and optionally `disable-model-invocation: true`) in the
  frontmatter. Use the scoped syntax `Bash(git add *)` for least privilege.
- **Codex** — write `agents/openai.yaml` from `assets/templates/openai.yaml.tpl`
  (`dependencies`, `allow_implicit_invocation`). Tool/dep control lives **here**, not in
  frontmatter.
- **opencode** — it ignores `allowed-tools`; permission is set in the user's `opencode.json`
  under `permission.skill`. Don't write to their config — instead, if the skill needs
  restriction, emit a short `PORTABILITY.md` telling them the exact `opencode.json` snippet.
- When more than one runtime is targeted, always emit `PORTABILITY.md` listing what to
  configure where (template in `assets/templates/`). → `references/portability.md`

### Step 4b — Optimize the trigger description

The `description` is what decides whether the skill fires. Tune it before validating →
`references/description-optimization.md`: draft realistic trigger phrasing, build
should-trigger / should-not-trigger query sets (the near-misses matter most), check the
description against both, and edit until false positives/negatives are acceptable. Keep it
generic across runtimes unless the skill is intentionally provider-specific.

### Step 5 — Validate

Run the bundled checker, then a security pass:

```bash
python3 scripts/validate_skill.py <path-to-generated-skill>
```

It checks: `SKILL.md` exists, valid YAML, `name`/`description` present and within limits,
`name` matches the directory, and flags Claude-only constructs (`!`cmd``,
`${CLAUDE_SKILL_DIR}`) when the skill is declared cross-platform. Then apply
`references/security.md` (least privilege, no secret-prompting, review any `scripts/`). If a
`skill-scanner` skill is available, run it too.

### Step 6 — Report

Return:
1. **Summary** — what was generated and for which runtimes.
2. **Files** — tree of created paths.
3. **Per-platform setup** — the exact steps the user must do in each target (e.g. Codex
   `config.toml` entry, opencode permission snippet).
4. **Validation results** — checker output + any open gaps.

---

## Quick decision shortcuts

- **One runtime, Claude Code, read-only knowledge skill** → single `SKILL.md`, 5 fields +
  `allowed-tools: Read Grep Glob`, no references. Done in one file.
- **All three runtimes** → portable body, no load-time exec, `allowed-tools` for Claude,
  `openai.yaml` for Codex, `PORTABILITY.md` for opencode permissions.
- **Heavy domain knowledge** → lean router `SKILL.md` + `references/<topic>.md`, each with an
  "open when…" entry.
- **Repetitive deterministic step** → bundle a `scripts/` helper so every future run reuses
  it instead of reinventing.
