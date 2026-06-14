# Execution Shapes, Archetypes, and When to Split into Multiple Skills

## Pick the simplest adequate shape

| Shape | Use when | Layout |
|---|---|---|
| **knowledge** | the value is curated instructions/judgment; no automation | `SKILL.md` only |
| **reference-backed** | large domain knowledge that's only needed on some runs | `SKILL.md` (router) + `references/` |
| **script-backed** | a deterministic, repeatable step the agent would re-implement each time | `SKILL.md` + `scripts/` |
| **orchestrator** | drives an external system via MCP/API with strict sequencing & safety | `SKILL.md` + `references/<api>.md` (+ Codex `openai.yaml` dependency) |

Default to the simplest. If choosing a heavier shape, record why the simpler one was rejected.

## The four archetypes (reference patterns)

1. **Standardized Output Generator** (e.g. README writer) — gather ground truth first (`run
   ls -la`, read manifests), then **template-anchor** the output, write the file, verify.
   Eliminates framework hallucination by reading reality before generating.

2. **Contextual Synthesizer** (e.g. commit-message generator) — constrained
   summarization: extract input (`git diff --staged`), categorize against an enumerated list,
   enforce explicit style rules, **self-check via a final checklist** before output.

3. **Multi-File Reference Architecture** (e.g. code reviewer) — lean router body (<40 lines)
   that offloads deep criteria to `references/criteria.md`, read only during an active run.
   The canonical Tier-3 progressive-disclosure pattern.

4. **External Orchestrator** (e.g. Linear sprint planner) — rigid sequential steps; ground
   the API behavior in `references/<api>.md` (pagination, rate-limit backoff: "on 429 wait 1s,
   retry once"); **Plan → present → wait for explicit confirmation** before any destructive
   write. Declare the MCP dependency (Codex `openai.yaml`).

## Plan-Validate-Execute (for destructive / high-stakes skills)

Bake self-correction into the body:

1. **Analysis** — read state with read-only tools only.
2. **Planning** — output the intended changes in a strict format (JSON / Markdown table).
3. **Validation loop** — run a bundled `scripts/` validator against the plan; on non-zero
   exit, revise and retry from stderr.
4. **Execution** — only on a clean zero-exit may the agent mutate state.

## Single skill vs multiple skills

Split into separate skills when **any** of these holds:

- **Triggers diverge.** Two capabilities fire on clearly different user phrasings/contexts.
  One muddy description covering both causes mis-triggering ("skill pollution").
- **Audiences/altitudes differ.** e.g. "plan a phase" (planning) vs "implement a phase"
  (execution) — different mental modes, different moments.
- **Lifecycle differs.** Pieces are owned/updated independently.
- **One is destructive, the other read-only.** Different safety posture → separate skills so
  permissions and `disable-model-invocation` apply only where needed.

Keep as **one skill** when it's a single cohesive workflow with one trigger surface, even if
it has many internal steps — use `references/` to manage size, not extra skills.

### When you do split

- Give each a sharp, non-overlapping `description` (and an explicit "use the other skill for
  X" boundary).
- Let them **call each other** by name where a real handoff exists (a skill can invoke
  another, e.g. a setup skill chaining a sub-skill). Document the chain in each body.
- Emit them under a shared parent decision: `skill-gen` should produce the **set** plus a
  short index note explaining when each fires.

> Rule of thumb: if you cannot write a one-sentence description that triggers on exactly one
> recognizable situation, you have more than one skill.
