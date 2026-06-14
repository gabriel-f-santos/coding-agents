# Supply-Chain Dependency Review

In 2026 a dependency installed **without an effective version lock** is a real vulnerability:
the next install can pull a freshly-published **malicious** version (npm/PyPI worms, typosquats,
account takeovers). Flag the gaps below — report on manifests/lockfiles/CI, even if they're only
touched by the diff.

## The nuanced model (don't cry wolf on `^`)
A caret range (`^1.2.3`) is fine **if** there's a committed lockfile and CI installs from it.
The real risks are missing locks, install commands that ignore the lock, unbounded ranges, and
**no cooldown** (which bites on the *next update*, when a just-published bad version gets pulled).

| Risk | Flag when… | Severity |
|---|---|---|
| **No reproducibility** | lockfile missing or **not committed** (`package-lock.json`/`pnpm-lock.yaml`/`yarn.lock`/`poetry.lock`/`uv.lock`/`Cargo.lock`/`go.sum`); or install uses `npm install`/`pip install <pkg>` instead of `npm ci`/`--frozen-lockfile`/hashes | **HIGH (P1)** |
| **Unbounded range, no lock** | `*`, `latest`, `>=x` with no upper bound, `x` (any) — **and** no lockfile | **HIGH (P1)** |
| **No cooldown / minimum release age** | no `minimumReleaseAge`(Renovate/pnpm) / `cooldown`(Dependabot) — updates can install a version published minutes ago | **HIGH (P1)** |
| **Pinned-but-unverified** | a dep added in the diff without provenance/scan; new transitive deps not reviewed | **MEDIUM** |
| **No dependency scanning** | no `osv-scanner`/`npm audit`/`pip-audit`/socket in CI | **MEDIUM (P2)** |
| **Unpinned CI actions** | GitHub Actions referenced by tag (`@v5`) not commit SHA | **MEDIUM** |

## What to grep
- Manifests: `package.json`, `pyproject.toml`/`requirements.txt`, `go.mod`, `Cargo.toml`, `Gemfile`.
  Look for `*`, `latest`, `>=` without a ceiling, missing pins.
- Lockfiles present **and** committed? (`git ls-files | grep lock`). `.gitignore` shouldn't ignore them.
- CI/scripts: `npm install` vs `npm ci`; `pip install pkg` vs `pip install -r --require-hashes` /
  `uv sync --frozen`; `pnpm install` vs `--frozen-lockfile`.
- Cooldown config: `minimumReleaseAge` (renovate.json / `pnpm-workspace.yaml` / `.npmrc`
  `minimum-release-age`), Dependabot `cooldown`.
- A diff that **adds/bumps a dependency** → check the added version isn't `latest`/unbounded and
  (if recent) respects the cooldown.

## The cooldown (the user's "10 days")
A minimum-release-age delay is a cheap, high-leverage defense — most malicious versions are
detected and yanked within hours/days, so a delay filters the smash-and-grab attacks. Current
support (verify the project's tool): **Renovate** `minimumReleaseAge: "10 days"` (formerly
`stabilityDays`; `config:best-practices` defaults npm to 3 days); **pnpm 10.16+**
`minimumReleaseAge` in **minutes** (10 days = `14400`); **Dependabot** `cooldown`. Enforce it on
the update tool **and** at install (pnpm enforces at install; Renovate/Dependabot only gate PRs).

## Output
Per finding: the manifest/lockfile/CI location, what's unlocked, the concrete fix (commit the
lockfile / pin / switch to `npm ci` / add `minimumReleaseAge` / add osv-scanner), and severity.
For prevention on new repos, point to `greenfield-monorepo` (scaffolds this by default).

## Sources
Renovate `minimumReleaseAge` docs; pnpm 10.16 release (minimumReleaseAge); Dependabot cooldown;
OpenSSF "Detecting Malicious Packages Using the OSV API"; google/osv-scanner Action. 2026-06.
