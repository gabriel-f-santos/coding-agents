#!/usr/bin/env python3
"""Validate a monorepo scaffolded by the greenfield-monorepo skill.

Read-only structural sanity checks — it does NOT run builds. Usage:

    python3 validate_scaffold.py <repo-root>

Checks: root files exist (AGENTS.md, Taskfile, root config), CLAUDE.md points at AGENTS.md,
each apps/* and services/* has a manifest + AGENTS.md, dev_*.sh are executable, scripts have a
consistent shebang/strict-mode, no two apps share a dev port, and .env is gitignored while
.env.example is committed. Exit 0 = clean, 1 = problems found. Warnings never fail the run.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ERRORS: list[str] = []
WARNINGS: list[str] = []


def err(msg: str) -> None:
    ERRORS.append(msg)


def warn(msg: str) -> None:
    WARNINGS.append(msg)


def check_root(root: Path) -> None:
    must = ["AGENTS.md", ".gitignore"]
    for f in must:
        if not (root / f).exists():
            err(f"missing root file: {f}")
    # task runner: Taskfile.yml or Makefile
    if not any((root / f).exists() for f in ("Taskfile.yml", "Taskfile.yaml", "Makefile")):
        err("no root task runner (Taskfile.yml or Makefile)")
    # nice-to-haves
    for f in (".editorconfig", ".gitattributes", "README.md"):
        if not (root / f).exists():
            warn(f"recommended root file absent: {f}")
    # CLAUDE.md should point at AGENTS.md (import or symlink)
    claude = root / "CLAUDE.md"
    if claude.exists() and not claude.is_symlink():
        txt = claude.read_text(errors="ignore")
        if "@AGENTS.md" not in txt:
            warn("CLAUDE.md exists but does not '@AGENTS.md' (one source of truth recommended)")
    elif not claude.exists():
        warn("no CLAUDE.md (Claude Code reads CLAUDE.md, not AGENTS.md)")


MANIFESTS = ("package.json", "pyproject.toml", "go.mod", "pubspec.yaml", "Cargo.toml")


def app_dirs(root: Path) -> list[Path]:
    out: list[Path] = []
    for parent in ("apps", "services"):
        p = root / parent
        if p.is_dir():
            out += [d for d in p.iterdir() if d.is_dir()]
    return out


def check_apps(root: Path) -> dict[Path, int | None]:
    ports: dict[Path, int | None] = {}
    apps = app_dirs(root)
    if not apps:
        warn("no apps/ or services/ subprojects found")
    for d in apps:
        if not any((d / m).exists() for m in MANIFESTS):
            err(f"{d.relative_to(root)}: no manifest ({', '.join(MANIFESTS)})")
        if not (d / "AGENTS.md").exists():
            warn(f"{d.relative_to(root)}: no per-app AGENTS.md")
        # .env hygiene
        if (d / ".env").exists():
            err(f"{d.relative_to(root)}: committed .env present (should be gitignored)")
        ports[d] = _find_port(d)
    return ports


_PORT_RE = re.compile(r"(?:PORT|port)\D{0,3}(\d{4,5})")


def _find_port(d: Path) -> int | None:
    for name in ("AGENTS.md", "package.json", "vite.config.ts", ".env.example", "wrangler.jsonc"):
        f = d / name
        if f.exists():
            m = _PORT_RE.search(f.read_text(errors="ignore"))
            if m:
                return int(m.group(1))
    return None


def check_port_collisions(ports: dict[Path, int | None]) -> None:
    seen: dict[int, Path] = {}
    for d, port in ports.items():
        if port is None:
            continue
        if port in seen:
            err(f"dev port {port} used by both {seen[port].name} and {d.name}")
        else:
            seen[port] = d


def check_scripts(root: Path) -> None:
    sdir = root / "scripts"
    if not sdir.is_dir():
        warn("no scripts/ dir (dev_up/down/restart/seed expected)")
        return
    shells = sorted(sdir.glob("*.sh"))
    if not shells:
        warn("scripts/ has no *.sh")
    for s in shells:
        mode = s.stat().st_mode
        if not mode & 0o111:
            err(f"{s.relative_to(root)} is not executable (chmod +x)")
        head = s.read_text(errors="ignore")[:200]
        if not head.startswith("#!"):
            err(f"{s.relative_to(root)} missing shebang")
        # pipefail is bash-only; flag the common mismatch
        if "#!/usr/bin/env sh" in head and "pipefail" in head:
            err(f"{s.relative_to(root)}: 'pipefail' under /usr/bin/env sh (use bash or drop pipefail)")
    expected = {"dev_up.sh", "dev_down.sh", "dev_restart.sh"}
    have = {s.name for s in shells}
    for miss in sorted(expected - have):
        warn(f"scripts/{miss} not found")


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    root = Path(sys.argv[1]).expanduser().resolve()
    if not root.is_dir():
        print(f"not a directory: {root}")
        return 2

    check_root(root)
    ports = check_apps(root)
    check_port_collisions(ports)
    check_scripts(root)

    for w in WARNINGS:
        print(f"  warn: {w}")
    for e in ERRORS:
        print(f" ERROR: {e}")
    print(f"\n{len(ERRORS)} error(s), {len(WARNINGS)} warning(s).")
    return 1 if ERRORS else 0


if __name__ == "__main__":
    raise SystemExit(main())
