# Progressive Disclosure — what goes where

The framework loads skills in three tiers. Designing for it keeps idle cost near zero and
execution cost proportional to the task.

| Tier | Loaded | Cost | Holds |
|---|---|---|---|
| **1 — Discovery** | `name` + `description` only | ~100 tokens/skill, always | the trigger metadata |
| **2 — Activation** | full `SKILL.md` body | on semantic/explicit match | the workflow & routing |
| **3 — Execution** | a `references/` or `scripts/` file | only when a step asks for it | heavy domain detail |

## Rules of thumb

- **Keep `SKILL.md` under ~500 lines (~5,000 tokens).** Approaching it → add a hierarchy
  level: move detail into `references/` and leave a one-line "open when…" pointer.
- **`SKILL.md` is a router, not an encyclopedia.** It states the process and points to where
  the depth lives. The Code-Reviewer archetype's body is <40 lines; the SQL-injection / XSS /
  N+1 checklists live in `references/criteria.md`, read only during an active review.
- **One concern per reference file.** Flat under `references/`. Each must earn a routing entry
  in `SKILL.md` with a concrete "open when you need to…" reason. A reference with no pointer is
  dead weight.
- **For large references (>300 lines), add a table of contents** at the top.
- **Organize by variant when multi-domain:**
  ```
  cloud-deploy/
  ├── SKILL.md            (workflow + selection logic)
  └── references/
      ├── aws.md
      ├── gcp.md
      └── azure.md        (the agent reads only the relevant one)
  ```

## What belongs in each directory

| Put here | When |
|---|---|
| `SKILL.md` body | the procedure, decision points, routing table, short templates |
| `references/*.md` | dense docs, API schemas, rule checklists, style guides, per-variant detail |
| `scripts/*` | deterministic/repetitive work the agent would otherwise re-implement each run — bundle once, call it |
| `assets/*` | static output materials: templates, schemas, icons, fonts, lookup tables |

## Decide: inline vs split

```
Is the knowledge needed on EVERY run of the skill?
├── yes, and it's short        → inline in SKILL.md
├── yes, but it's large        → SKILL.md routes to references/ at the right step
└── no, only some runs need it → references/ (pulled on demand) — keeps Tier 2 lean
```

## Script-backed = read the output, not the code

A bundled script is executed, not internalized. The body says *"run
`scripts/parse_errors.sh` and read its output; if it reports code E_DB, read
`references/error_codes.md`"*. The agent never spends tokens reading the script's logic.
This is how a skill bundles effectively-unbounded capability at fixed idle cost.

> Portability note: reference bundled files by **relative path** (e.g. read
> `assets/templates/readme.tpl`), never via the Claude-only skill-dir variable unless the
> skill is Claude-only. See `portability.md`.
