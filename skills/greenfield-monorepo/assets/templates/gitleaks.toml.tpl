# .gitleaks.toml — our secret-scan ruleset (write to the repo root).
# Keeps gitleaks' battle-tested default rules and ADDS our project-specific ones.
# Never hand-roll a regex scanner from scratch — extend the proven engine.

[extend]
useDefault = true            # keep gitleaks' built-in rules; we only ADD on top

# --- our extra rules (tune to the real formats) ---
[[rules]]
id = "our-internal-url"
description = "Internal/private hostname leaked in source"
regex = '''https?://[a-z0-9.-]+\.(internal|local|corp)\b'''
tags = ["internal"]

[[rules]]
id = "our-service-token"
description = "Our service token format (TODO: adjust prefix/length to the real token)"
regex = '''\bsk_(live|prod)_[A-Za-z0-9]{24,}\b'''
tags = ["token"]

# --- stop false positives on placeholders/examples ---
[allowlist]
description = "Known-safe placeholders"
paths = [
  '''(^|/)\.env\.example$''',
  '''(^|/)README\.md$''',
]
regexes = [
  '''EXAMPLE|CHANGEME|your-.*-here|xxxx+''',
]
