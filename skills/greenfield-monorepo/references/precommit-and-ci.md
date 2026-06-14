# Pre-commit hooks + baseline CI (polyglot)

Open when wiring the commit-time harness and CI. Drives JS/TS · Python · Go · Dart with one config.

> Versions current 2026-06. Refresh hook `rev:`s with `pre-commit autoupdate` before shipping.

## Decision
- **`pre-commit` framework** (`.pre-commit-config.yaml`) is the cross-language driver — it scopes each hook
  to changed files by language out of the box. Use **husky + lint-staged only for JS-only** repos (it can't
  cleanly drive Python/Go/Dart). Drive CI with **GitHub Actions + `dorny/paths-filter`** so each app's
  lint/test runs only when its paths changed, plus a `pre-commit run --all-files` backstop. Add **gitleaks**
  as a hook *and* a CI job.

## `.pre-commit-config.yaml`
Only include the language blocks for apps that exist. Scope every hook with `files: ^<app-root>/`.
```yaml
exclude: |
  (?x)^(.*/node_modules/.*|.*/\.dart_tool/.*|.*/build/.*|.*/dist/.*|.*/vendor/.*|.*\.lock$|.*\.g\.dart$|.*\.freezed\.dart$)$
default_install_hook_types: [pre-commit, commit-msg]
fail_fast: false
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - { id: trailing-whitespace, args: [--markdown-linebreak-ext=md] }
      - { id: end-of-file-fixer }
      - { id: check-merge-conflict }
      - { id: detect-private-key }
      - { id: check-added-large-files, args: [--maxkb=1024] }
      - { id: check-yaml }
      - { id: check-toml }
      - { id: mixed-line-ending, args: [--fix=lf] }

  # Python — ruff lint + format (replaces black+isort+flake8)
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.15.17
    hooks:
      - { id: ruff-check, args: [--fix], files: ^apps/backend-app/ }
      - { id: ruff-format, files: ^apps/backend-app/ }

  # Secret scanning (also a CI job)
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.2
    hooks: [{ id: gitleaks }]

  # Conventional Commits (OPTIONAL — most friction-prone hook; keep optional)
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: v9.22.0
    hooks:
      - { id: commitlint, stages: [commit-msg], additional_dependencies: ['@commitlint/config-conventional'] }

  # JS/TS — LOCAL node hooks. mirrors-prettier is ARCHIVED (2024-04-11); mirrors-eslint unmaintained.
  - repo: local
    hooks:
      - { id: eslint, name: eslint, entry: npx --no-install eslint --fix --max-warnings=0, language: node, types_or: [javascript, jsx, ts, tsx], files: ^apps/frontend-app/ }
      - { id: prettier, name: prettier, entry: npx --no-install prettier --write --ignore-unknown, language: node, types_or: [javascript, jsx, ts, tsx, json, css, scss, html, markdown, yaml], files: ^apps/frontend-app/ }

  # Go — system hooks (need go + golangci-lint v2 on PATH)
  - repo: local
    hooks:
      - { id: gofmt, name: gofmt, entry: gofmt -l -w, language: system, types: [go], files: ^services/ }
      - id: golangci-lint
        name: golangci-lint
        entry: bash -c 'cd services/worker-go && golangci-lint run --new-from-rev=HEAD --fix'
        language: system
        types: [go]
        pass_filenames: false        # package-scoped tool
        files: ^services/worker-go/

  # Dart/Flutter — system hooks (need the SDK on PATH)
  - repo: local
    hooks:
      - { id: dart-format, name: dart format, entry: dart format --set-exit-if-changed, language: system, types: [dart], files: ^apps/mobile/ }
      - id: dart-analyze
        name: dart analyze
        entry: bash -c 'cd apps/mobile && dart analyze'
        language: system
        types: [dart]
        pass_filenames: false
        files: ^apps/mobile/
```
Install: `pre-commit install && pre-commit install --hook-type commit-msg`, then
`pre-commit run --all-files` once. Ruff hook ids are `ruff-check` + `ruff-format` (current names).

## `.github/workflows/ci.yml`
A `changes` job computes which app changed; per-language jobs gate on it; a `pre-commit` job is the
backstop. Action pins (2026-06): `dorny/paths-filter@v4`, `actions/checkout@v5`, `setup-python@v5`,
`setup-node@v4`, `setup-go@v5`, `golangci/golangci-lint-action@v8`, `subosito/flutter-action@v2`,
`astral-sh/setup-uv@v6`.
```yaml
name: CI
on: { pull_request: {}, push: { branches: [main] } }
permissions: { contents: read }
concurrency: { group: "ci-${{ github.ref }}", cancel-in-progress: true }
jobs:
  changes:
    runs-on: ubuntu-latest
    outputs: { py: "${{ steps.f.outputs.py }}", web: "${{ steps.f.outputs.web }}", go: "${{ steps.f.outputs.go }}", mobile: "${{ steps.f.outputs.mobile }}" }
    steps:
      - uses: actions/checkout@v5
      - uses: dorny/paths-filter@v4
        id: f
        with:
          filters: |
            py:     ['apps/backend-app/**']
            web:    ['apps/frontend-app/**']
            go:     ['services/worker-go/**']
            mobile: ['apps/mobile/**']

  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-python@v5
        with: { python-version: '3.13' }
      - uses: actions/setup-node@v4
        with: { node-version: '22' }
      # add setup-go / flutter-action here if those apps exist (the local hooks need the toolchains)
      - run: npm ci --prefix apps/frontend-app
      - uses: pre-commit/action@v3.0.1

  python:
    needs: changes
    if: ${{ needs.changes.outputs.py == 'true' }}
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: apps/backend-app } }
    steps:
      - uses: actions/checkout@v5
      - uses: astral-sh/setup-uv@v6
        with: { enable-cache: true }
      - run: uv sync --dev
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run pytest

  web:
    needs: changes
    if: ${{ needs.changes.outputs.web == 'true' }}
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: apps/frontend-app } }
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-node@v4
        with: { node-version: '22', cache: 'npm', cache-dependency-path: apps/frontend-app/package-lock.json }
      - run: npm ci
      - run: npm run lint
      - run: npm test
  # add `go` and `mobile` jobs analogously when those apps exist (see SOURCES file for the full matrix)

  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with: { fetch-depth: 0 }
      - uses: gitleaks/gitleaks-action@v2
        env: { GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}" }
```

## Gotchas
- **System/local hooks need the toolchain installed** locally AND in the CI `pre-commit` job (go,
  golangci-lint, Dart/Flutter SDK, the repo's `node_modules`). `language: python|node` hooks (ruff,
  eslint-as-node) get an isolated env; `language: system` does not. #1 onboarding failure.
- **Path-scope every hook** (`files: ^<app>/`) and mirror those roots in the CI `paths-filter`.
- **`pass_filenames: false`** for golangci-lint and `dart analyze` (package-scoped, not per-file).
- **`--new-from-rev` hides whole-program issues** in pre-commit — the CI go job must run full
  `golangci-lint run`.
- **`commit-msg` stage isn't installed by default** — needs `--hook-type commit-msg` (covered by
  `default_install_hook_types`).
- **Don't use `mirrors-prettier`/`mirrors-eslint`** (dead) — use `repo: local` node hooks.
- **Pin + autoupdate**: every `rev:` is a pinned tag; schedule `pre-commit autoupdate`.

## SOURCES
pre-commit.com (config schema, language/files/pass_filenames, stages); pre-commit-hooks v6.0.0;
astral-sh/ruff-pre-commit v0.15.17; gitleaks v8.24.2; golangci-lint v2.12.2 + action@v8 (needs v2 schema);
dorny/paths-filter@v4; prettier.io/docs/precommit (mirrors archived → lint-staged). 2026-06.
