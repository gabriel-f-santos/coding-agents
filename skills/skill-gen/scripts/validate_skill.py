#!/usr/bin/env python3
"""Structural validator for generated Agent Skills.

Checks the portable contract + flags Claude-only constructs when a skill claims to be
cross-platform. Pure stdlib — no deps, no network, no writes.

Usage:
    python3 validate_skill.py <path-to-skill-dir> [--cross-platform]

Exit code 0 = clean, 1 = errors found. Warnings never fail the build.
"""
import sys
import re
import json
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
STANDARD_FIELDS = {"name", "description", "license", "compatibility", "metadata"}
CLAUDE_ONLY_FIELDS = {
    "allowed-tools", "disallowed-tools", "disable-model-invocation", "effort", "model",
}
CLAUDE_ONLY_CONSTRUCTS = [
    (re.compile(r"!`"), "load-time shell `!`cmd`` (does not expand in Codex/opencode)"),
    (re.compile(r"\$\{CLAUDE_SKILL_DIR\}"), "${CLAUDE_SKILL_DIR} (Claude-only variable)"),
]


def parse_frontmatter(text):
    """Return (frontmatter_dict, body, raw_frontmatter) or (None, text, '') if absent.

    Minimal YAML: only top-level `key: value` pairs are read (enough for validation).
    """
    if not text.startswith("---"):
        return None, text, ""
    parts = text.split("---", 2)
    if len(parts) < 3:
        return None, text, ""
    raw = parts[1]
    body = parts[2]
    fm = {}
    for line in raw.splitlines():
        m = re.match(r"^([A-Za-z0-9_-]+):(.*)$", line)
        if m:
            fm[m.group(1).strip()] = m.group(2).strip()
    return fm, body, raw


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    cross = "--cross-platform" in sys.argv
    if not args:
        print("usage: validate_skill.py <skill-dir> [--cross-platform]")
        return 2

    skill_dir = Path(args[0]).expanduser().resolve()
    errors, warnings = [], []

    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        # tolerate being given the SKILL.md directly
        if skill_dir.name == "SKILL.md" and skill_dir.is_file():
            skill_md = skill_dir
            skill_dir = skill_md.parent
        else:
            print(f"ERROR: no SKILL.md in {skill_dir}")
            return 1

    text = skill_md.read_text(encoding="utf-8", errors="replace")
    fm, body, raw = parse_frontmatter(text)

    # --- frontmatter presence & validity ---
    if fm is None:
        errors.append("missing or malformed YAML frontmatter (--- ... ---)")
        fm = {}

    name = fm.get("name", "").strip().strip('"\'')
    desc = fm.get("description", "").strip()

    if not name:
        errors.append("frontmatter missing required field: name")
    else:
        if len(name) > 64:
            errors.append(f"name too long ({len(name)} > 64)")
        if not NAME_RE.match(name):
            errors.append(f"name '{name}' must be lowercase alphanumeric with single hyphens")
        if name != skill_dir.name:
            errors.append(f"name '{name}' != directory name '{skill_dir.name}'")

    if not desc:
        errors.append("frontmatter missing required field: description")
    elif desc not in (">", "|"):  # block scalars are fine; only flag truly empty
        first = desc
        # block-scalar bodies live on following lines; treat '>' / '|' as non-empty
        if first in (">", "|"):
            pass

    # description length: re-read raw to capture block scalars
    desc_len = len(_full_description(raw))
    if desc_len == 0:
        errors.append("description is empty")
    elif desc_len > 1024:
        errors.append(f"description too long ({desc_len} > 1024)")

    # --- unknown / platform fields ---
    for k in fm:
        if k in CLAUDE_ONLY_FIELDS:
            if cross:
                warnings.append(f"'{k}' is Claude-only — inert in Codex/opencode (ok if intended)")
        elif k not in STANDARD_FIELDS:
            warnings.append(f"non-standard frontmatter field '{k}' (ignored by spec parsers)")

    # --- Claude-only constructs in a cross-platform skill ---
    # These are LEADS, not hard errors: a skill that *documents* the constructs (like a
    # meta-skill) trips the same regex as one that *uses* them. We strip inline code spans to
    # cut the obvious documentation false positives, then report what's left for human review.
    leads = []
    if cross:
        for f in sorted(skill_dir.rglob("*.md")):
            for i, line in enumerate(f.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                stripped = _strip_inline_code(line)
                for rx, label in CLAUDE_ONLY_CONSTRUCTS:
                    if rx.search(stripped):
                        leads.append(f"{f.relative_to(skill_dir)}:{i}: {label}")

    # --- routing hygiene: referenced files should exist ---
    for ref in re.findall(r"references/[\w./-]+\.md", text):
        if not (skill_dir / ref).exists():
            warnings.append(f"SKILL.md points to '{ref}' which does not exist")

    # --- body size ---
    body_lines = len(body.splitlines())
    if body_lines > 500:
        warnings.append(f"SKILL.md body is {body_lines} lines (>500 — consider splitting to references/)")

    # --- report ---
    result = {
        "skill": str(skill_dir),
        "name": name,
        "cross_platform_check": cross,
        "errors": errors,
        "warnings": warnings,
        # Claude-only constructs found in cross-platform mode. Advisory: review each —
        # documentation mentions are false positives; real load-time usage must be rewritten.
        "cross_platform_leads": leads,
        "ok": not errors,
    }
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0 if not errors else 1


def _strip_inline_code(line):
    """Remove inline code spans (``...`` and `...`) so documentation mentions of a construct
    don't get flagged as usage. Best-effort; fenced blocks are handled by line context."""
    line = re.sub(r"``[^`]*``", " ", line)
    line = re.sub(r"`[^`]*`", " ", line)
    return line


def _full_description(raw):
    """Extract the description value including block-scalar continuation lines."""
    lines = raw.splitlines()
    out = []
    capturing = False
    indent = None
    for line in lines:
        m = re.match(r"^description:\s*(.*)$", line)
        if m:
            val = m.group(1).strip()
            if val in (">", "|", ">-", "|-", ">+", "|+"):
                capturing = True
                continue
            return val.strip('"\'')
        if capturing:
            if line.strip() == "":
                out.append("")
                continue
            cur_indent = len(line) - len(line.lstrip())
            if indent is None:
                indent = cur_indent
            if cur_indent < indent or re.match(r"^[A-Za-z0-9_-]+:", line):
                break
            out.append(line.strip())
    return " ".join(x for x in out if x).strip()


if __name__ == "__main__":
    sys.exit(main())
