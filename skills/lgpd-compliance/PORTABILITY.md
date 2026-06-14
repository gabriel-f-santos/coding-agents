# lgpd-compliance — Cross-Platform Setup

Targets Claude Code · Codex · opencode. Body is portable (no load-time exec, no Claude-only vars).

## Install
Copy `lgpd-compliance/` into the runtime's skills dir:
- Claude Code / opencode: `.claude/skills/` (opencode scans it natively).
- Codex: `.codex/skills/` (or a `config.toml` entry).

## Per-platform
- **Claude Code:** `allowed-tools: Read Grep Glob Write WebSearch Task`. Read-only audit by default;
  `Write` only to scaffold docs (privacy policy / DPA) or apply a fix the user asks for.
- **Codex:** `agents/openai.yaml` (chains review-security / tech-discovery optionally).
- **opencode:** discovered under `.claude/skills/`; `allowed-tools` inert. Gate via `opencode.json`
  `permission.skill` if needed.

## Note
This skill gives **technical** guidance, not legal advice — keep a DPO/lawyer in the loop for legal
bases, retention periods and DPA terms.
