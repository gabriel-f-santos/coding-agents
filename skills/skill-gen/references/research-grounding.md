# Research & Grounding — finding the content the skill will contain

A skill is only as good as the domain knowledge curated into it. Structure (progressive
disclosure, frontmatter) is necessary but not sufficient — the reason `sentry-security-review`
is good is its **content**: per-language vulnerability patterns, OWASP checklists, organized so
the agent loads only what it needs. That content came from research, not pre-training. This step
makes skill-gen go find it.

## When to run (gate it)

Run research when the skill encodes **domain knowledge that must be correct and current**:
a library/framework/API/CLI, a security or compliance domain, a methodology with established
best practice, anything with per-variant (language/platform/framework) detail. **Skip** it for
a thin procedural wrapper with no external knowledge (e.g. "stage and format a commit"). If
unsure, do a quick source scan and decide.

## Source types, in priority order

Highest signal first. Ground in reality before reaching for the open web.

1. **Local codebase (the target repo)** — the real conventions, naming, and **gotchas** the
   skill must respect. `Grep`/`Glob` for actual patterns; read existing docs/PRDs; read sibling
   skills for house style. This is what makes the skill fit *this* project, not a generic one.
   - **Check installed versions first** (`package.json`, lockfiles, `pyproject.toml`…). Pin all
     downstream research to versions actually in use — don't research an API the repo can't run.
2. **context7 (MCP)** — current, version-specific docs for any named library/framework/API/CLI.
   Prefer this over pre-training; your knowledge may be stale. (Resolve the library id, then
   query the exact topic + version.) If context7 isn't available, fall back to official docs via
   web.
3. **Primary sources** — official docs, RFCs/specs, the library's own repo/changelog. These win
   over blogs. Avoid generic blog posts as a primary source.
4. **Recent web (`WebSearch`/`WebFetch`)** — current best practices, benchmarks, deprecations,
   "X vs Y in <year>". Date-bias your queries; libraries and advice go stale.
5. **History & failure modes** — issues, PRs, incident/postmortem notes, regressions. The
   non-obvious "this looks right but breaks because…" facts are the highest-value gotchas.

## Work in three stages: Plan → Capture → Consolidate

Do **not** research straight into the final `references/`. With many sources and parallel
subagents, a direct dump is unreadable and loses provenance. Separate raw capture from the
shipped skill, exactly like a plan-then-execute workflow:

### Stage 1 — Plan (decompose what to research)

Before searching, write a **research plan**: list the questions/dimensions, and for each, which
source type to hit (local / context7 / primary doc / web / history). This is the unit of
fan-out — one planned item ≈ one subagent ≈ one raw capture file. Cap to the dimensions that
matter and note what you're deliberately not covering.

### Stage 2 — Capture (one file per result, in a scratch workspace)

Save **each** research result as its **own file** in a workspace **outside the skill** (it's
scratch — it must not ship). Subagents write here independently; nothing is consolidated yet.

```
<workspace>/<slug>/                 ← e.g. ./.skill-research/<name>/ or /tmp/skill-research/<name>/
├── research-plan.md                ← Stage 1: the questions per dimension + chosen source
├── raw/
│   ├── 01-<dimension>.md           ← one file per planned item / subagent / source
│   ├── 02-<dimension>.md
│   └── …
└── findings-log.md                 ← Stage 3 input: deduped, verified claims + confidence
```

Each `raw/NN-*.md` carries its own provenance — a record per claim:
`claim · source(url/doc/file) · date · confidence(verified | single-source | pre-training)`.
**Fan out with subagents (`Task`)** — one per planned dimension — each writing its own raw file.
**Graceful degradation:** no subagents → run the items inline, sequentially, same files;
no web/context7 → rely on local sources + flagged pre-training (lower confidence), and say so.

### Stage 3 — Consolidate (workspace → shipped references)

Only now turn the workspace into the skill's `references/`, the Sentry way:
- **Verify first (adversarial pass):** for any non-obvious or load-bearing claim, confirm it
  against a second independent source. If sources conflict, keep both and mark it unresolved —
  don't pick silently. Promote only `verified` (or clearly-tagged) claims.
- **One file per domain/variant** (`references/<language>.md`, `references/<topic>.md`), each a
  tight **checklist of what to look for / patterns**, not prose.
- Route every file from `SKILL.md` with an "open when…" reason (see
  `progressive-disclosure.md`). A reference with no router entry is dead weight.
- **Carry provenance forward:** end each reference (or a `SOURCES.md`) with the sources + date,
  so the skill can be re-grounded later. The raw workspace itself does **not** ship — discard it
  or keep it gitignored in the authoring repo for the next re-grounding.
- Put only what the agent **doesn't already know** — omit generic concepts, keep the
  project/domain-specific nuance (the gotchas).

Why the separation pays off: subagents return independent units (one file each, no merge
races); raw provenance survives; and you can **re-consolidate without re-researching** when the
structure changes.

## Honest synthesis (from the research skill)

- Recommend, don't force. If two options are equivalent for this stack/scope, say so.
- Justify by **project context**, not generic preference.
  - ❌ "JWT é mais moderno." / "Todo mundo usa bcrypt."
  - ✅ "JWT + refresh no DB permite rotação (RFC 9700) sem adicionar Redis, já que Postgres já
    está no stack."

## Coverage / gap check

Before authoring, state: which dimensions were researched, which sources were primary, and
**what's still a gap** (a variant not covered, a claim unverified, a doc not found). Gaps go
into the skill as explicit "(a confirmar)" notes — never silently omitted.

## Output of this step

- A short **research log**: dimensions covered, key findings (with sources + confidence), and
  gaps.
- The drafted `references/` content (grounded, cited) ready for the authoring step.
