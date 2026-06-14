# NFRs, Scale & Cost

Non-functional requirements (quality attributes) drive most architecture decisions. Make them
**measurable**, then size and price the design against them. "Scalable/fast/secure" are not
requirements until they have numbers.

## Turn quality attributes into testable targets

For each relevant attribute, write a target as a scenario (stimulus → response → measure):

| Attribute | Bad | Good (target) |
|---|---|---|
| Performance | "fast" | p95 API latency < 300ms at expected load |
| Scalability | "scalable" | sustain 5k RPS; 50 GB/yr data growth for 3 yrs |
| Availability | "always up" | 99.9% monthly; graceful degradation if LLM is down |
| Reliability | "robust" | no data loss on crash; at-least-once job processing |
| Security | "secure" | see `security-threat-modeling.md` (STRIDE targets) |
| Cost | "cheap" | < $X/month at expected load; < $Y per 1k AI calls |
| Operability | — | structured logs, health checks, one-command deploy/rollback |
| Maintainability | — | bounded contexts; no cross-context DB access |

Pull the numbers from the product discovery brief / PRD; if absent, propose a figure and mark it
**(a confirmar)** — never leave it implicit.

## Back-of-envelope scale estimate

Do the arithmetic, roughly:
- **Load:** users × actions/user/day ÷ active seconds → avg RPS; ×(3–10) for peak.
- **Data:** rows/day × bytes/row × retention → storage; index/overhead ×2–3.
- **Throughput hot paths:** identify the read-heavy vs write-heavy paths; cache the reads,
  batch/queue the writes.
- State whether one modest instance covers it (usually yes early) or where the first real
  bottleneck appears. This decides how much architecture you actually need now.

## Cost estimate (include AI/LLM)

Name the cost drivers and a rough monthly figure at expected load:
- Compute/instances, managed DB, object storage + egress, cache/queue.
- **AI/LLM:** tokens per call × calls/day × price; this often dominates and is easy to
  under-budget. Note quota/rate limits and a fallback/cheaper-model path.
- Watch the **margin gap**: revenue/ACV (from the business model) vs per-tenant + per-call cost.

## Output into the brief

- A target per relevant quality attribute (with the number or a marked assumption).
- The scale estimate (load, data, the first bottleneck).
- The cost estimate with drivers, AI included, and the margin sanity-check.
