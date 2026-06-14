# Data Model, Storage & Integration

The data model outlives the code. Get the entities, ownership, and consistency right; choose
storage to fit the access patterns, not the hype.

## Data model

- **Entities & relationships** — list the core entities, their key attributes, and cardinality.
  A small ER sketch (mermaid `erDiagram`) beats prose.
- **Ownership** — which bounded context owns each entity (the source of truth). Other contexts
  reference by ID, not by copying the model.
- **Identity & keys** — natural vs surrogate keys; how IDs are generated (uuid/ulid/seq);
  tenant scoping for multi-tenant systems (every row carries the tenant key, enforced centrally).
- **Lifecycle** — soft-delete vs hard-delete (a common project-specific **gotcha** — document
  it), audit/history needs, retention/PII purging.

## Storage selection (fit access patterns)

| Pattern | Lean toward |
|---|---|
| Relational, transactional, joins, strong consistency | a SQL DB (default) |
| High-write append/log, time-series | append-optimized / time-series store |
| Large blobs (files, media) | object storage (S3/R2) + URLs in the DB |
| Cache / sessions / rate-limit counters | in-memory KV (Redis) |
| Full-text / semantic search | search index / vector store |

> Default to one SQL database until an access pattern *can't* be served well by it. Polyglot
> persistence multiplies ops, consistency, and backup burden — adopt per proven need.

Decide **consistency** explicitly: strong (single DB transaction) vs eventual (across contexts/
services). If eventual, name where, and how readers tolerate staleness.

## Integration with external systems & contexts

For each external dependency (payment, email, LLM, third-party API) and each cross-context call:
- **Contract** — what data in/out; sync (HTTP/RPC) vs async (events/queue).
- **Failure mode** — timeout, retry (idempotency!), circuit-breaker, fallback, rate limits.
  Assume it *will* fail; design the degraded path.
- **Coupling** — prefer an anti-corruption layer so an external model doesn't leak inward.
- **Auth** — how you authenticate to it; where the secret lives.

## Migrations & existing data

If this touches an existing system: how does current data migrate? Backfill plan, dual-write or
cutover, and rollback. Flag any irreversible data migration as a risk + spike.

## Output into the brief

- ER sketch + entity ownership by context.
- Storage choice per data class with the access pattern that justifies it.
- Integration map: each dependency with contract, failure mode, and auth.
- Consistency decisions and any migration/backfill plan.
