// renovate.json5 — dependency updates with a cooldown (supply-chain defense).
// Renovate opens update PRs but ONLY after a version is `minimumReleaseAge` old.
// Note: this gates Renovate's PRs; for install-time enforcement also set pnpm's
// minimumReleaseAge (pnpm-workspace.yaml / .npmrc) — see precommit-and-ci.md.
{
  $schema: "https://docs.renovatebot.com/renovate-schema.json",
  extends: [
    "config:best-practices",   // pins, lockfile maintenance, sane defaults (npm cooldown 3d baseline)
  ],
  // Our cooldown: don't propose a version until it's been public for 10 days.
  minimumReleaseAge: "10 days",
  // Optional: let trusted, low-risk updates through faster, or hold majors longer.
  packageRules: [
    // { matchUpdateTypes: ["pin", "digest"], minimumReleaseAge: "0 days" },
    // { matchUpdateTypes: ["major"], minimumReleaseAge: "21 days" },
  ],
  // Security fixes (OSV/GHSA) bypass the cooldown — patch known vulns fast.
  vulnerabilityAlerts: { minimumReleaseAge: "0 days" },
  lockFileMaintenance: { enabled: true },
}
