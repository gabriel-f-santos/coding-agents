# Advanced Engineering of Agent Skills and Prompt Architectures

> Deep-research reference on designing, structuring, and securing Agent Skills across
> Claude Code, OpenAI Codex, and emerging agentic runtimes. Companion to
> `best-practices-skill.md` and `SECURITY_ANTIPATTERNS.md`.

---

## The Paradigm Shift in Context Orchestration

AI interaction architecture has moved from static, monolithic system prompts to dynamic,
modular agentic workflows. Early approaches packed exhaustive instructions, domain
knowledge, and operational constraints into a single massive context window. This worked
for narrow tasks but failed at scale: as the context window grew, models suffered
**attention dilution** — ignoring constraints, hallucinating procedures, and failing
multi-step tool calls.

The **Agent Skills open standard** is a structural departure. Instead of front-loading an
agent with instructions for every conceivable task, skills package procedural knowledge,
organizational context, and executable tools into discrete, version-controlled directories
that an agent loads **only when required**. Success no longer depends on drafting the
perfect universal prompt, but on designing **interoperable, context-efficient modules** an
agent can discover, activate, and execute across environments.

Prompts are no longer text strings — they are **executable architectures** that govern how
an agent interacts with filesystems, external APIs, and codebases. Effective skill design
requires fluency in cognitive load management, semantic zoning, progressive disclosure, and
strict access controls.

---

## The Agent Skills Open Standard: Anatomy and Mechanics

The standard establishes a universal directory/file architecture, treating skills as
portable, executable packages — analogous to NPM modules for language models.
Standardizing the format (agentskills.io) gives the industry a shared language so a skill
built for Claude Code can also run in OpenAI Codex or Cloudflare Agents.

### Directory Architecture and Semantic Segregation

A skill is an isolated directory that enforces separation of concerns between metadata,
natural-language instructions, and machine-executable resources. This prevents the model
from parsing raw executable code as prose, preserving reasoning capacity.

| Directory/File | Requirement | Architectural purpose |
|---|---|---|
| `SKILL.md`   | **Mandatory** | Entry point: YAML frontmatter + core natural-language instructions. The agent's primary cognitive framework — procedural workflow and execution logic. |
| `scripts/`   | Optional | Executable code (Bash, Python, Node) triggered via terminal tools. Keeps raw code out of the context window unless execution is explicitly required. |
| `references/`| Optional | Dense documentation, API schemas, design patterns, style guides. Parsed only when conditionally triggered, keeping primary instructions lean. |
| `assets/`    | Optional | Static resources: templates, graphics, lookup tables, rigid formatting structures. |

The boundary is between what the agent **reads to understand** the workflow and what it
**uses to complete** it. Rather than pasting a 500-line JSON schema into the prompt,
instruct the agent to read it from `references/` when validating a payload — preserving the
window for high-level reasoning.

### YAML Frontmatter and Metadata Configuration

`SKILL.md` is dual-layered: a machine-readable YAML frontmatter block (routing and
governance) followed by the human/agent-readable instruction body. Frontmatter precision
directly determines autonomous reliability.

| Field | Requirement | Constraints | Function |
|---|---|---|---|
| `name` | **Mandatory** | ≤64 chars, lowercase alphanumeric + hyphens, no leading/trailing hyphen | Unique identifier for invocation (e.g. `/code-review`). Must match the parent directory name. |
| `description` | **Mandatory** | ≤1024 chars, non-empty | The primary semantic trigger. States **what** the skill does and **when** to activate it, matched against user intent. |
| `allowed-tools` | Optional | Space/comma-separated string or YAML list | Pre-approved tool access (e.g. `Read`, `Grep`, `Glob`) without per-call authorization. Key for autonomy + sandboxing. |
| `disallowed-tools` | Optional | List of tools | Actively removes capabilities (e.g. write) while the skill is active; reverts afterward. |
| `disable-model-invocation` | Optional | Boolean | When `true`, forbids autonomous triggering — manual slash command only. For destructive/high-cost ops. |
| `compatibility` | Optional | ≤500 chars | Environmental prerequisites: network access, binaries (`docker`, `jq`), runtimes (`Requires Python 3.14+`). |
| `license` | Optional | License name/ref | IP restrictions — relevant for shared proprietary modules. |
| `metadata` | Optional | Arbitrary key-value | Extra properties (MCP server requirements, author) outside the spec. |
| `effort` | Optional | `low \| medium \| high \| xhigh \| max` | Overrides default cognitive-load allocation, forcing more reasoning tokens for complex steps. |

The `description` is **not for humans** — it is the semantic mapping the agent uses to score
relevance. "Helps with PDFs" triggers unreliably; an optimized description acts like an
event listener:

> *"Extracts text from PDF files. Use when the user mentions PDFs, forms, or document
> extraction."*

Precision prevents **skill pollution** — overlapping ambiguous descriptions that load the
wrong workflow and derail intent.

### Discovery and Cross-Platform Resolution

At session startup the engine scans predefined directories to catalog skills. A standard
convention uses `.agents/skills/` for cross-client interoperability.

- **User-level scopes** (`~/.agents/skills/`, `~/.claude/skills/`, `~/.codex/skills/`) —
  global capabilities that follow the developer across projects.
- **Project-level scopes** (`<project>/.agents/skills/`, `<project>/.claude/skills/`) —
  proprietary workflows checked into version control, shared across a team without manual
  installation.

On a **namespace collision** (same name at both scopes), the **project-level location wins**
— universal defaults can be surgically overridden per repository.

---

## The Mechanics of Progressive Disclosure

The standard's central innovation: agents **never** load the entire skill set at once.
Holding fifty skills' instructions, scripts, and schemas concurrently would degrade
reasoning and make inference financially untenable. Loading happens in three tiers.

### Tier 1 — Discovery (Metadata Baseline)

On session init, the agent extracts only `name` + `description` from each skill's
frontmatter — roughly **~100 tokens per skill**. This lightweight ingestion lets the agent
maintain ambient awareness of hundreds of skills without congesting the window. It builds a
continuous semantic index, comparing incoming prompts and terminal state against all loaded
descriptions.

### Tier 2 — Activation (Instruction Ingestion)

When a high-confidence semantic match is detected, the agent reads the **full `SKILL.md`
body** into active context. The spec recommends keeping this **under ~5,000 tokens (~500
lines)**, forcing workflows to be distilled into tight, actionable steps — a concentrated
dose of procedural logic delivered exactly when the task begins.

### Tier 3 — Execution (On-Demand Resources)

Complex edge cases, large schemas, and shell scripts stay in `references/` and `scripts/`,
pulled in **only** when the workflow reaches the step that requests them.

Example: a server-error triage skill instructs the agent to run `scripts/parse_errors.sh`.
The agent executes it via bash tools and reads the output **without ever internalizing the
script's logic**. If the output shows a specific error code, `SKILL.md` then directs it to
read `references/error_codes.md` for the resolution protocol.

> **Idle cost** is limited to Tier 1 metadata; **execution cost** scales precisely with the
> active operation. Bundled domain data is effectively unbounded. This mirrors optimal human
> cognition — broad awareness of tools, manual consulted only when a task starts, precise
> tables looked up only at the moment of calculation.

---

## Platform-Specific Implementations

The standard guarantees interoperable directory structures and metadata parsing, but
discovery scopes, invocation modes, and tooling syntax vary per environment.

### Claude Code — Access Governance

Strong emphasis on granular access control, local terminal integration, and slash-command
invocation. Skills appear natively in the slash menu for **explicit** invocation
(`/readme-writer`) while also supporting **implicit** semantic triggering.

A defining feature is the `allowed-tools` syntax for regex-like command control. Instead of
blanket bash access:

```yaml
allowed-tools: Bash(git add *) Bash(git commit *)
```

This grants staging and committing but **mathematically prevents** `git push` or `rm -rf`,
mitigating the security risks of autonomous terminal agents.

> **State-management caveat.** `disable-model-invocation: true` is designed to reserve a
> skill for explicit slash commands (critical for expensive deploys/migrations). In some
> builds (e.g. 2.1.92) the flag inadvertently **hid the skill entirely**, neutralizing both
> agent- and user-driven invocation. Rigorously test the interaction between user-invocable
> settings and invocation flags on your target build before relying on it in production.

### OpenAI Codex — Multi-Agent CI

Codex loads skills from `~/.codex/skills/` and project `.codex/skills/`, enabling persistent
cross-session behaviors aligned to team coding standards. Its focus is parallel processing
and external integration via the **Model Context Protocol (MCP)**.

A well-engineered Codex skill acts as the **orchestration layer** between code generation and
external MCP servers. A skill managing the Box Content API, for instance, encodes exact
pagination limits, auth handshakes, and data schemas — loaded via progressive disclosure so
the agent classifies hundreds of files from one prompt without hallucinating endpoints or
violating rate limits.

Codex uses a `config.toml` for durable preferences, feature flags, and multi-agent topology.
Clean boundary: **`SKILL.md` holds portable procedural logic; `config.toml` holds local
environmental bindings and API-key mappings.** At OpenAI, Codex autonomously reviews every PR
by loading repo-specific review skills in isolated background agents.

---

## Advanced Prompt Engineering for Tool-Calling Agents

As frontier models (GPT-5.5, Claude Fable 5, Claude Opus 4.8) reason more autonomously, the
discipline of instructing **how and when** to use tools has shifted away from legacy
techniques.

### Semantic Zoning and Structural Delineation

Continuous prose creates ambiguity — the attention mechanism conflates tool descriptions
with behavioral rules. Delineate cognitive domains with strict Markdown headers or XML tags:
`<instructions>`, `<background_information>`, `<output_constraints>`, `<error_handling>`.
Isolating tool schemas keeps parameter descriptions from bleeding into the agent's persona.
A rule inside an `<error_handling>` block carries far more weight than the same rule buried
in a paragraph.

### Eradicate Coercive Tool Phrasing

Aggressive language ("You MUST ALWAYS use the database search tool before answering") is now
an **anti-pattern**. It skews the probability distribution toward execution, causing
**over-triggering and infinite tool-calling loops** even when context already holds the
answer.

Use **calm, conditional** language: *"Use tools when appropriate and helpful"*, *"Evaluate
the necessity of external data before triggering a query."* Treat the agent as an autonomous
reasoning engine capable of judgment, not a deterministic script runner.

### Induce Cognitive Emulation (Explicit Planning)

Force "think out loud" behavior by demanding a step-by-step plan inside a `<scratchpad>` or
`<planning>` block **before** any tool call. This makes the model process logical
dependencies sequentially; subsequent calls are more precise and accurately parameterized.
In SWE-bench testing, inducing explicit planning before execution raised the absolute pass
rate by a statistically significant **~4%**.

For long multi-step workflows, mandate **intermediary updates** — a one-to-two-sentence
natural-language acknowledgement of the request plus the first planned step. This anchors
intent into the context window and prevents the tool chain from drifting off-target.

### Effort Calibration (Cognitive Budgeting)

The explicit **Effort** parameter (`low`, `medium`, `high`, `xhigh`, `max`) replaces fragile
prompt-stacking to force depth. It is a direct multiplier on token allocation for internal
logic and tool iteration.

- `effort: max` for massive refactors or multi-variable architecture — lets the model loop
  through failures and self-correct before answering.
- `effort: low` for boilerplate/formatting — optimizes latency and cost.

Modulating effort **per skill** balances cost, speed, and intelligence precisely.

### Programmatic Tool Discovery

With thousands of enterprise tools, injecting every schema into the prompt is impossible.
Equip the system prompt with a single `tool_search_tool` that runs regex/BM25 queries against
an external tool-definition repository. The agent searches autonomously and pulls only the
needed schemas into context for that operation — mirroring progressive disclosure, keeping
the core prompt lean and cacheable while accessing an effectively infinite toolset.

---

## Methodologies for Constructing High-Fidelity Skills

### Ground in Domain Constraints and "Gotchas"

A common failure is generating skill instructions from a model's generalized pre-training.
Asking a model to "write a skill for reviewing Python PRs" yields generic advice (PEP8,
naming) — wasting context teaching what the agent already knows while ignoring the real
codebase.

Synthesize high-fidelity skills from **real proprietary artifacts**: code reviews, incident
reports, API specs, internal style guides. Document only the ecosystem's quirks. If the
project uses a custom **soft-delete** pattern instead of row deletion, the skill must say so.

Implement this via a dedicated **"Gotchas"** section logging environment-specific facts that
defy industry assumptions — e.g. varying user-ID keys across legacy microservices, or health
endpoints that return `200 OK` even when the DB connection is severed. Guiding principle:
**omit what the agent knows natively; meticulously document the non-obvious.**

### Structural Prompting and the Plan-Validate-Execute Protocol

Use Markdown checklists (`- [ ] Verify environment variables exist`) — models process
structural formatting natively, and a physical checklist forces critical evaluation of each
dependency as externalized memory.

For destructive/high-stakes/batch operations, mandate **Plan-Validate-Execute**:

1. **Analysis** — extract data, read schemas, evaluate state with **read-only** tools.
2. **Planning** — output an intermediate plan in a strict format (JSON payload or Markdown
   table) detailing exactly what will be modified.
3. **Validation Loop** — run a bundled `scripts/` validation script against the plan. On
   error, the agent enters an autonomous revision cycle driven by stderr.
4. **Execution** — only on a clean **zero-exit code** may the agent run the state-altering
   commands.

Embedding self-correction loops turns a fragile linear executor into an iterative, robust,
self-healing system.

### Template Anchoring

For rigid output formats (Git commit messages, README docs, proprietary JSON schemas),
natural-language descriptions degrade over long contexts. Instead, embed concrete skeletal
templates in code blocks or store them in `assets/`. An exact skeleton (where the title goes,
where the payload rests, how tags close) reduces formatting hallucination to near zero.

---

## Four Core Skill Archetypes

### Archetype 1 — Standardized Output Generator (README Writer)

Analyzes unstructured local data → produces a standardized document. Frontmatter optimizes
semantic triggers (*"Use when user asks to 'write a README', 'create a readme', or 'document
this project'"*). The key first step is **proactive context gathering** before asking
anything:

```bash
ls -la
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || echo "No manifest found"
```

Reading manifests injects ground-truth, eliminating framework hallucination. Then **Template
Anchoring** supplies a strict Markdown skeleton, and the skill writes the file and confirms
with a line-count verification — an end-to-end autonomous workflow.

### Archetype 2 — Contextual Synthesizer (Git Commit Message Generator)

Constrained summarization + formatting, a scaled-down Plan-Validate-Execute. Extracts staged
diffs (`git diff --staged`), categorizes changes against an enumerated allowed list (`feat`,
`fix`, `docs`, `refactor` per Conventional Commits), and enforces stylistic boundaries
models routinely violate:

- Subject line under 72 characters
- Imperative mood ("add feature", not "added feature")
- No trailing period on the subject line

A mandatory checklist verifies output against these constraints before presenting.

### Archetype 3 — Multi-File Reference Architecture (Code Reviewer)

Optimal Tier-3 progressive disclosure. The `SKILL.md` body is **under ~40 lines** — it just
sets the process (understand context → run review → structure output into Summary, Blocking
Issues, Suggestions, Positive Notes). Deep expertise lives in `references/criteria.md`
(SQL-injection vectors, XSS escaping, N+1 patterns, edge cases). The body simply commands:
*"For detailed review criteria by category, see `references/criteria.md`. Work through each
category in order."* The agent gains massive analytical capability but pays the criteria
token cost only during an active review.

### Archetype 4 — External Orchestrator (Linear Sprint Planner)

Highest structural governance, coordinating external platforms via MCP. Frontmatter declares
the dependency (`mcp-server: linear`). Rigid sequential architecture:

1. Gather current state.
2. Analyze team capacity — reference `references/linear-api.md` for pagination cursors and
   rate-limit backoff (*"On 429: wait 1 second, retry once"*) — domain grounding so the agent
   doesn't guess API behavior.
3. Prioritize by defined hierarchy (P0 blockers first, then user-flagged items, …).
4. **Hard pause:** present a structured proposed plan and **wait for explicit confirmation**
   before creating cycles or assigning issues — balancing AI speed with human accountability
   right before a destructive write.

---

## Security, Governance, and Risk Mitigation

Autonomous agents that run bash, route network traffic, and modify filesystems introduce
profound vulnerabilities. Skills bundle executable code and system instructions — a malicious
`SKILL.md` can cause anything from file corruption to silent data exfiltration.

**Primary attack vector: prompt injection via external data.** Summarizing an untrusted
source or reviewing a compromised PR can feed hidden directives that override the system
prompt and weaponize available tools. Audits of community skills have found a meaningful
fraction with critical vulnerabilities — obfuscated `scripts/` designed to harvest `.env`
files or siphon API keys to remote servers.

**Mitigation — principle of least privilege.** `allowed-tools` is the primary defense. Bind
observational skills to read-only utilities:

```yaml
allowed-tools: Read, Grep, Glob
```

Even under a successful injection during log analysis, the agent is **physically incapable**
of using `Write`, `Bash`, or networking tools to cause damage or exfiltrate data.

**Governance rules:**
- Never install a skill that asks users to paste secrets into the chat.
- Manually review the entire `scripts/` directory before installation.
- Pair community repos with automated vulnerability scanning (e.g. VirusTotal integrations)
  and strict execution sandboxes.

---

## Debugging and Optimization

**Tier 1 (Discovery) failures — most common.** If a relevant query doesn't trigger the
skill, the cause is almost always the `description`. Analyze the semantic gap between the
user's phrasing and the description's keywords; inject more varied, specific, real-world
trigger phrases.

**Skill fails to load at all — invalid YAML.** Parsers are indentation/format sensitive; an
unclosed quote or missing hyphen silently prevents registration. Use validators (e.g.
`skills-ref validate`) before deployment.

**Session state.** Skills are snapshotted at session start. Editing `SKILL.md` mid-session
does **not** propagate until the session restarts — a frequent source of wasted debugging.

**Isolation technique.** Use explicit invocation (`/readme-writer`) to bypass semantic
matching and determine whether the failure is in the **trigger condition** or the
**procedural logic** of the prompt body.

---

## Conclusion

Prompt engineering has transcended drafting natural-language instructions. The frontier
demands a systems-level approach to context orchestration, treating the model as a bounded
computational reasoning engine rather than a magic text box. The Agent Skills standard
provides the structural framework — using progressive disclosure to solve context-window
exhaustion and attention dilution.

By configuring YAML frontmatter for access control, isolating schemas and scripts into
segregated directories, and applying structural zoning, cognitive-emulation planning, and
dynamic effort modulation, developers synthesize reliable autonomous workflows. The shift
from monolithic system prompts to modular, constrained, iteratively validated skill
ecosystems is a fundamental maturation of the field — enabling agents to navigate
filesystems, orchestrate APIs, and execute complex engineering tasks with unprecedented
precision, security, and scalability.

---

## Sources (Referências citadas)

> Acessadas em junho 14, 2026.

1. [Agent Skills Overview — Agent Skills](https://agentskills.io/home)
2. [Agent Skills — Claude API Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
3. [9 Must-Have Skills for Codex in 2026 — unicodeveloper, Medium](https://medium.com/@unicodeveloper/9-must-have-skills-for-codex-in-2026-b5124b375eec)
4. [Codex | AI Coding Partner from OpenAI](https://openai.com/codex/)
5. [Can anyone summarize the "skills" + Claude Code trends — r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/comments/1qg1rbh/can_anyone_summarize_the_skills_claude_code_or/)
6. [Support for Agent Skills Specification (agentskills.io) · Issue #1565 — cloudflare/agents](https://github.com/cloudflare/agents/issues/1565)
7. [Specification — Agent Skills](https://agentskills.io/specification)
8. [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills)
9. [[DOCS] Syntax for allowed-tools in skills · Issue #17499 — anthropics/claude-code](https://github.com/anthropics/claude-code/issues/17499)
10. [How to add skills support to your agent — Agent Skills](https://agentskills.io/client-implementation/adding-skills-support)
11. [Equipping agents for the real world with Agent Skills — Anthropic](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
12. [Tools reference — Claude Code Docs](https://code.claude.com/docs/en/tools-reference)
13. [Skill with disable-model-invocation: true cannot be invoked by user via slash command · Issue #26251 — anthropics/claude-code](https://github.com/anthropics/claude-code/issues/26251)
14. [disable-model-invocation: true hides skill from session entirely · Issue #43875 — anthropics/claude-code](https://github.com/anthropics/claude-code/issues/43875)
15. [Claude Code has severely degraded since February — r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/comments/1se7ak4/claude_code_has_severely_degraded_since_february/)
16. [Best practices – Codex — OpenAI Developers](https://developers.openai.com/codex/learn/best-practices)
17. [Teaching AI Agents to Work With Your Content: Building a Box Skill for OpenAI Codex — Box](https://blog.box.com/teaching-ai-agents-work-your-content-building-box-skill-openai-codex)
18. [Prompt guidance | OpenAI API](https://developers.openai.com/api/docs/guides/prompt-guidance)
19. [Prompting best practices — Claude API Docs](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
20. [Effective context engineering for AI agents — Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
21. [prompt-blueprint/guides/anthropic-best-practices — thibaultyou/prompt-blueprint](https://github.com/thibaultyou/prompt-blueprint/blob/main/guides/anthropic-best-practices__chatgpt-4_5.md)
22. [Anthropic's Battle-Tested Prompting Guide for Claude Opus 4.5 — r/vibecodingcommunity](https://www.reddit.com/r/vibecodingcommunity/comments/1p80bvw/anthropics_battletested_prompting_guide_for/)
23. [GPT-4.1 Prompting Guide — OpenAI Developers](https://developers.openai.com/cookbook/examples/gpt4-1_prompting_guide)
24. [Introducing advanced tool use on the Claude Developer Platform — Anthropic](https://www.anthropic.com/engineering/advanced-tool-use)
