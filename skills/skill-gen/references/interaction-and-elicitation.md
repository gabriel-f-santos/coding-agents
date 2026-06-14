# Interaction & Elicitation — for skills that talk to the user

> **Autonomy is the default; interaction is the exception.** A well-built skill acts on its own
> and only stops to involve the human for a decision genuinely theirs to make, or a real branch
> it can't resolve from context + sensible defaults. Reach for this reference **only** for those
> moments — a deliberately interactive skill (discovery, architecture, a setup wizard), or a
> specific `if`/decision point inside an otherwise autonomous skill. A formatter or one-shot
> generator should just run; don't bolt an interview onto it.

When the skill **does** need to elicit a choice from a human, give that moment this style: a
sharp thinking partner that **recommends a default and adapts to a less-experienced user**
instead of dumping choices on them.

## Be a thinking partner, not a form

(From the product-brainstorming pattern.)
- **Be opinionated.** "I'd go with B because…" beats a neutral pros/cons list. Always have a take.
- **One question at a time.** Conversation, not a questionnaire dumped at once. Ask, listen, then ask the next — building on the answer.
- **Challenge constructively.** "That assumes X — are we sure?" not "that won't work."
- **Match energy & name the pattern.** If they're excited, explore before poking holes; if you
  spot a known trap (solutioning too early, scope creep), name it directly.
- Don't dump frameworks or hand over a list — use frameworks as thinking tools when they help.

## Always offer a Recommended default

Whenever a decision needs the user, **present a recommendation** — especially if they may lack
the expertise to choose blind:
- Mark the recommended option clearly, e.g. label it **"(Recomendado)"** and list it **first**.
- Give the **why in one line**, tied to *their* context/constraints — and what they'd give up by
  choosing otherwise.
- Never force it. It's a default they can override; leave the decision theirs.
- With `AskUserQuestion`: put the recommended option first with "(Recommended)" in its label,
  and include an option that acknowledges uncertainty ("Não sei — me explica" / "Pesquisa isso").

## Calibrate to the user's experience

Read the signals and adapt depth — don't make a novice decide uninformed, don't lecture an expert.

| Signal | Likely level | Do |
|---|---|---|
| precise jargon, names trade-offs | expert | skip basics; focus on trade-offs; still recommend |
| "o que for padrão", "tanto faz", hesitation | less experienced | **educate briefly** (one analogy), **fewer options**, mark the **(Recomendado)** default, explain the why |
| "acho que…", "talvez…" | unsure | probe gently; offer to research; recommend |
| buzzword with no context | unclear | ask what they mean by it before proceeding |
| terse / long pauses | overwhelmed | simplify; reduce to 2 options + a recommendation |

For a non-technical user: use analogies ("uma API é como um garçom…"), avoid flooding with
options, offer to research. For an expert: don't explain the basics, go straight to the fork.

## Educate when needed (don't let them choose blind)

If a choice has real consequences and the user seems unsure, **explain the trade-off in plain
language first**, then ask — with your recommendation. The goal is an *informed* decision, not a
rubber-stamp. A two-line explanation + a recommended default beats a bare question every time.

## Question phrasing

- Ask about **their world**, not your jargon. ❌ "Qual banco de dados?" → ✅ "Que tipo de dado
  você guarda, e lê muito mais do que escreve?"
- Make options concrete and distinct; describe the implication of each.
- Use multi-select when choices aren't mutually exclusive.

## What to put in the generated skill

In the interview step of the generated skill, add a short **"Interaction"** line such as:
> Ask one question at a time, each with a **recommended default** ("(Recomendado)") and a
> one-line why. Calibrate depth to the user's expertise — educate a less-experienced user with a
> brief analogy and fewer options; go straight to trade-offs with an expert. Never make them
> decide blind.
