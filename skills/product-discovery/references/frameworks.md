# Discovery Frameworks — the canvases

Condensed, action-oriented. Use the one that fits the moment; don't fill them all out
ceremonially. Each is a one-page thinking tool, not a deliverable for its own sake.

## Opportunity Solution Tree (Teresa Torres — Continuous Discovery)

Connects work to a business outcome so you don't ship features for their own sake.
```
            [Desired business OUTCOME]            ← the metric you want to move
               /        |        \
       [Opportunity] [Opportunity] [Opportunity]  ← user pains/needs you DISCOVERED (not guessed)
          /    \
   [Solution] [Solution]                          ← candidate features
        |
   [Experiment]                                   ← how you'll test the solution
```
Rule: opportunities come from real discovery (interviews), and you only add solutions under a
validated opportunity. Solutions without an opportunity above them are red flags.

## Customer Development (Steve Blank)

"Get out of the building." Form **hypotheses** about the problem, then validate by talking to
potential customers — **without selling**. Loop: Customer Discovery → Customer Validation →
(only then) Customer Creation / Company Building. Pairs with The Mom Test for the *how*.

## Value Proposition Canvas (Osterwalder)

Fit between customer and product:
- **Customer profile:** Jobs (functional/social/emotional tasks they must do) · Pains
  (frustrations, risks, obstacles) · Gains (desired outcomes).
- **Value map:** Products/services · Pain relievers · Gain creators.
- **Fit** = your pain relievers and gain creators map onto their *top-ranked* pains and gains —
  not all of them, the ones that matter most.

## Business Model Canvas (Osterwalder) — 9 blocks

Customer Segments · Value Propositions · Channels · Customer Relationships · **Revenue Streams**
(how the SaaS subscription works) · Key Resources · Key Activities · Key Partnerships · **Cost
Structure** (cloud infra, AI/LLM APIs, support). For a SaaS, scrutinize Revenue Streams (pricing
model, ACV) against Cost Structure (per-tenant infra + per-call AI costs) early — margin dies in
the gap.

## Lean Startup (Eric Ries)

- **Build–Measure–Learn:** minimize total time through the loop; each turn tests one hypothesis.
- **MVP** = the *smallest* version that tests your hypothesis with real customers — **not** a
  low-quality product. Forms:
  - **Concierge MVP** — you do the work manually behind the scenes for the first users.
  - **Wizard of Oz** — looks automated; a human runs it behind the curtain.
  - **Landing page / fake door** — measure interest before building (see market-research.md).
- Goal at this stage: deliver value and get the **first paying customers**, not scale. Defer
  complex architecture and extreme scalability.

## Practical sequence for a SaaS

1. **Hypothesis:** "Acredito que [público] tem dificuldade em [dor]."
2. **Discovery:** interview 10–20 of that audience (Mom Test). Confirm the pain is real and that
   they already spend time/money on it.
3. **Offer:** Value Proposition Canvas — how you solve it better/faster/cheaper.
4. **Demand test (pre-MVP):** landing page + waitlist/CTA; measure CTR & opt-in.
5. **MVP:** build only the core; chase the first paying customers.
