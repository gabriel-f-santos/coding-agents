---
name: {{SKILL_NAME}}
description: >
  {{WHAT_IT_DOES}}. Use when {{TRIGGER_PHRASES}}. {{OUTPUT_SUMMARY}}.
  Do not use for {{NEGATIVE_BOUNDARY}}.
# --- Claude Code-only (inert in Codex/opencode) — keep only if Claude is a target ---
# allowed-tools: Read Grep Glob
# disable-model-invocation: true   # uncomment for destructive/explicit-only skills
# --- standard optional fields ---
# license: MIT
# compatibility: Requires {{PREREQS}}
# metadata: { author: "{{AUTHOR}}", version: "1.0.0" }
---

# {{SKILL_TITLE}}

{{ONE_SENTENCE_WHAT_AND_OUTPUT}}

## When to use
- {{CASE_A}}
- {{CASE_B}}

## When NOT to use
- {{CASE_C}} → use `{{OTHER_SKILL}}`
- {{CASE_D}} → no skill needed

## Process
1. {{STEP_1}}   <!-- gather ground truth first: instruct the agent to RUN a command and read output -->
2. {{STEP_2}}
3. {{STEP_3}}

<!-- For heavy domain detail, route instead of inlining:
## Reference
| Open when… | Read |
|---|---|
| {{WHEN}} | references/{{TOPIC}}.md |
-->

<!-- Output contract (template anchoring) — adapt or delete:
## Output format
ALWAYS use this structure:
{{OUTPUT_SKELETON}}
-->

<!-- PORTABILITY RULES (delete if Claude-only):
  - no  `!`cmd``  load-time execution
  - no  ${CLAUDE_SKILL_DIR}  — reference bundled files by relative path
  - frontmatter limited to the 5 standard fields (+ allowed-tools for Claude users)
-->
