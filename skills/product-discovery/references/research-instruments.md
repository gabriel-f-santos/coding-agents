# Generating User-Research Instruments

The "talk to potential users" kit. Generate the instruments the user picks (default: all four),
**grounded** in the hypotheses, target persona, and riskiest assumptions surfaced in Steps 1–3 —
never generic. All instruments obey the anti-bias rules from `talking-to-users.md`: ask about
**past behavior**, not future opinions; no compliment-fishing; no leading questions.

Write outputs to `docs/discovery/<slug>/` (e.g. `interview-guide.md`, `survey.md`,
`screener.md`, `landing-fake-door.md`).

---

## 1. Interview guide (qualitative, Mom Test + JTBD)

Purpose: 1:1 conversations that reconstruct real past behavior and the switching forces.

Skeleton:
```markdown
# Roteiro de Entrevista — <segmento> (≈30–40 min)

## Objetivo & hipótese a testar
<a dor que você acredita existir — NÃO revelar ao entrevistado>

## Aquecimento (contexto, sem mencionar sua ideia)
- Me conta sobre seu dia a dia com <área>.
- Qual a parte mais chata/demorada disso?

## A última vez (reconstroi a timeline JTBD)
- Me conta da última vez que <situação do problema> aconteceu. Quando foi?
- O que você fez? Passo a passo.   (struggling moment)
- O que te fez procurar uma solução naquele momento?  (push)

## Soluções atuais & custo (currency)
- Como você resolve isso hoje? Que ferramentas/planilhas/pessoas?
- Quanto isso te custa — tempo e dinheiro? Já pagou por algo nessa categoria? Quanto?
- O que te irrita na solução atual?  (push)  O que te segura nela?  (habit)

## As forças (não perguntar diretamente — inferir)
Push / Pull / Anxiety / Habit — anotar evidências citáveis.

## Fechamento
- Quem mais vive esse problema e poderia conversar comigo? (intro = currency)
- Posso te avisar quando tiver algo pra testar? (compromisso = sinal)

## ❌ Não perguntar: "você usaria…?", "você pagaria…?", "acha útil?"
```

## 2. Quantitative survey

Purpose: validate patterns at scale. **<10–12 perguntas**, easy→hard, scales + a few
open-ended, neutral phrasing.

Skeleton:
```markdown
# Survey — <segmento>

1. (screener inline) Com que frequência você lida com <problema>?  [diária/semanal/mensal/nunca]
2. Como você resolve isso hoje?  [lista de opções reais + "outro"]
3. Na última vez, quanto tempo levou?  [faixas]
4. Você já pagou por alguma ferramenta pra isso?  [sim/não → quanto: faixas]
5. Quão frustrante é a solução atual?  [escala 1–5, rotulada]
6. (aberta) Descreva a última vez que isso te causou problema.
7. (aberta) Se pudesse mudar uma coisa em como resolve isso hoje, o que seria?
...
- Demografia/firmográfico no FIM (cargo, tamanho da empresa, segmento).
```
Rules: no "quão incrível foi…"; use "quão satisfeito você ficou com…". Avoid double-barreled
questions. Keep ≤10–12 to protect completion. Aim past-behavior over hypotheticals.

## 3. Recruitment screener

Purpose: get the **right** people before spending interview time. 4–6 questions.

Skeleton:
```markdown
# Screener — recrutamento

1. Seu cargo / papel?  [qualifica perfil-alvo; desqualifica fora do ICP]
2. Você faz <atividade-chave>?  [sim → segue / não → encerra educadamente]
3. Com que frequência?  [exige frequência mínima]
4. Você decide ou influencia a compra de <tipo de ferramenta>?  [B2B: poder de decisão]
5. Disponibilidade pra 30 min nas próximas 2 semanas?  [agenda]
- Incentivo (se houver) + consentimento de gravação.
```

## 4. Landing / fake-door copy (pre-MVP demand test)

Purpose: measure real demand before building. Output copy + the metrics plan.

Skeleton:
```markdown
# Landing / Fake-door — <produto>

## Hero
- Headline: <promessa de progresso, na linguagem do usuário — não jargão>
- Subhead: <pra quem + a dor que resolve>
- CTA primário: "Entrar na lista de espera" / "Quero acesso antecipado"

## Como funciona (3 passos)  ·  Prova (citações reais das entrevistas)  ·  Preço (âncora, opcional)

## Instrumentação (o que medir)
- CTR = cliques no CTA ÷ visitantes únicos
- Opt-in rate = % que deixou email / agendou call
- Fonte de tráfego por canal (pra ler intenção)
- Meta de sinal: definir ANTES (ex.: >X% opt-in de tráfego qualificado em N visitantes)
- Nutrir a lista a cada ~2 semanas (silêncio derruba conversão pra ~8–12%)
```

---

## After generating

Tell the user the **riskiest assumption** each instrument is designed to test, the **target n**
(≈10–15 interviews for JTBD patterns; enough survey responses for signal), and how to read the
results back into the discovery brief (Step 6).
