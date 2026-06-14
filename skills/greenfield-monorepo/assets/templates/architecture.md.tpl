# Architecture — {{PROJECT_NAME}}

> Living doc. Keep it short and real. The per-app AGENTS.md files point back here.

## Overview
{{ONE_PARAGRAPH_WHAT_THE_SYSTEM_IS}}

- **Style:** {{ARCH_STYLE}}  (modular monolith / frontend+backend / microservices / event-driven)
- **Why this style:** {{ONE_LINE_RATIONALE}}

## Context / containers (sketch)
```
{{TEXT_OR_C4_SKETCH}}
```

## Apps & services
| Name | Path | Stack (pinned versions) | Responsibility | Dev port |
|---|---|---|---|---|
{{#APPS}}
| {{APP_NAME}} | {{PATH}} | {{STACK}} {{VERSIONS}} | {{RESPONSIBILITY}} | {{PORT}} |
{{/APPS}}

## Data stores
{{DATA_STORES}}   <!-- e.g. Postgres 17 (primary), Redis (cache/queue) -->

## Cross-app contracts
- `packages/proto` — {{CONTRACT_FORMAT}} (protobuf / OpenAPI). The single sanctioned coupling point;
  editing it regenerates clients (a task, not manual).

## Non-functional requirements
- Performance / latency: {{PERF}}
- Scale / concurrency: {{SCALE}}
- Availability: {{AVAILABILITY}}

## Security
- Secrets: {{SECRETS_HANDLING}} (never in chat, `vars`, or committed files; `.env.example` documents them).
- AuthN/Z boundary: {{AUTH_BOUNDARY}}

## Open decisions
- {{OPEN_DECISION_1}}
- {{OPEN_DECISION_2}}
