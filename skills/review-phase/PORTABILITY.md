# review-phase (+ reviewers) — Cross-Platform Setup

Set of 4 skills: `review-phase` (orchestrator) + `review-functionality`, `review-security`,
`review-quality` (reviewers). Targets Claude Code · Codex · opencode. Bodies are portable.

## Install
Copy all four into the runtime's skills dir (names must match folders):
- Claude Code / opencode: `.claude/skills/` (opencode scans it natively).
- Codex: `.codex/skills/` (or `config.toml` entries); deps declared in each `agents/openai.yaml`.

## Per-platform
- **Claude Code:** `allowed-tools` in frontmatter. `review-phase` needs `Task` (subagent fan-out)
  and `Write`; reviewers are read-only (`Read Grep Glob Bash(git diff *)`).
- **Codex:** `agents/openai.yaml` — the orchestrator declares the three reviewers as `skills`
  dependencies. Subagent fan-out uses Codex's own capability.
- **opencode:** discovered under `.claude/skills/`; `allowed-tools` inert. To gate, use
  `opencode.json` `permission.skill`.

## Degradation
If subagents (`Task`) aren't available, `review-phase` runs the three reviewers inline,
sequentially — same inputs, same report.

## Output footprint
The full report goes to `artifacts/reviews/` (gitignored) by default, or
`docs/phases/phase-NN-<slug>/review/` if that dir exists. Only the summary prints to screen.
