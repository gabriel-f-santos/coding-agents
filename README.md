# coding-agents — Agent Skills catalog

A curated catalog of portable [Agent Skills](https://agentskills.io) — reusable, version-
controlled capabilities for Claude Code, OpenAI Codex, and opencode. This repo is the central
place we author, store, and distribute skills; copy what you need into a project.

Skills live under **`skills/`** (one folder per skill, each with a `SKILL.md`). Install them into
a project's `.claude/skills/` (the discovery path) with `install-skills.sh`.

---

## The flow — product → build

The skills compose into a discovery-to-delivery pipeline. Each stage produces an artifact the
next consumes (the feature **slug** carries through every step):

```
product-brainstorming ─┐
                       ├─► product-discovery ─► tech-discovery ─► prd-creator ─► research ─► (plan → implement)
ideia / problema       │   discovery brief     tech brief        prd-<slug>.md  decisions
                       │   (problema validado)  (arquitetura)
                       └─ pura ideação
```

- **product-brainstorming** — sparring partner pra explorar o espaço do problema (pura ideação).
- **product-discovery** — entrevista o founder (Mom Test/JTBD), faz pesquisa de mercado, gera
  instrumentos de pesquisa com usuários, e escreve o discovery brief (problema validado).
- **tech-discovery** — arquiteto técnico sênior: arquitetura, boundaries, dados, NFRs, STRIDE,
  riscos/spikes → Tech Discovery Brief.
- **prd-creator** — PRD que define *o quê* construir, no formato da casa.
- **research** — decisões técnicas granulares (lib/pattern) por fase, com trade-offs.
- **plan-phase → implement-phase** — decompõem e executam (vivem no projeto cota8; opcional aqui).

## Fluxos possíveis (entre por onde fizer sentido)

Não precisa rodar o pipeline inteiro — entre no estágio certo pro seu ponto de partida. `*` = skill
fora deste catálogo (vive no cota8).

| Situação | Fluxo |
|---|---|
| **Greenfield (ideia nova, do zero)** | `product-brainstorming` → `product-discovery` → `tech-discovery` → `prd-creator` → `research` → `plan-phase`* → `implement-phase`* |
| **Ideia já validada, sistema novo** | `tech-discovery` → `prd-creator` → `research` → `plan-phase`* → `implement-phase`* |
| **Feature nova em produto existente** | `prd-creator` → `research` → `plan-phase`* → `implement-phase`* |
| **Feature pequena/clara (decisões óbvias)** | `prd-creator` → `plan-phase`* → `implement-phase`* (pula `research`) |
| **Já tem PRD + decisões, só construir** | `plan-phase`* → `implement-phase`* |
| **Só descobrir/validar o problema** | `product-discovery` (standalone) |
| **Só explorar/estressar ideias** | `product-brainstorming` |
| **Só desenhar/revisar a arquitetura** | `tech-discovery` (standalone) |
| **Só uma decisão técnica pontual** | `research` |
| **Só escrever o PRD** | `prd-creator` |
| **Mudança técnica grande num código existente** | `tech-discovery` (foco em risco/boundaries) → `research` → `plan-phase`* |
| **Criar/melhorar uma skill** | `skill-gen` → `skill-scanner` (auditar antes de distribuir) |
| **Commit / infra (avulsos)** | `commit-message` · `hetzner-vm` · `linux-vm-hardening` · `tailscale-setup` |

Princípios:
- **Pule estágios** quando o artefato já existe (tem PRD? vá pro `research`/plan; decisões óbvias? pule `research`).
- **O slug atravessa tudo** — `discovery-<slug>` → `tech-discovery-<slug>` → `prd-<slug>` → `technical-decisions-<slug>` → `phase-NN-<slug>`.
- **Discovery (produto e técnico) é opcional** pra mudanças pequenas; obrigatório pra apostas grandes/irreversíveis.
- **Decisões em duas altitudes (ambas são hard constraints):** **ADRs** (`docs/adr/`, da `tech-discovery`) = arquiteturais/irreversíveis; **technical-decisions** (`docs/decisions/`, da `research`) = granulares por fase. `research` e `plan-phase` leem **ambas** e não as reabrem.

## Catálogo de skills

### Produto → entrega (pipeline)
| Skill | O que faz |
|---|---|
| `product-discovery` | Idéia vaga → discovery brief validado: entrevista (Mom Test/JTBD), pesquisa de mercado, instrumentos de pesquisa com usuários. |
| `tech-discovery` | Arquiteto técnico: explora opções, desenha C4/boundaries, data model, NFRs+custo, STRIDE, spikes → tech brief. |
| `prd-creator` | Gera `docs/prd-<slug>.md` no formato da casa, ancorado no codebase real. |
| `research` | Pesquisa opções técnicas e gera um doc de decisões (trade-offs) por fase. |

### Meta — criar e auditar skills
| Skill | O que faz |
|---|---|
| `skill-gen` | Gera **e melhora** skills portáveis via entrevista; research/grounding (plan→capture→consolidate), iteração por exemplos, otimização de trigger, validação. ([repo](https://github.com/gabriel-f-santos/gen-skill)) |
| `skill-scanner` | Audita uma skill (prompt injection, código malicioso, permissões, secrets) antes de instalar. |
| `example-skill` | Template mínimo de uma página pra começar uma skill nova. |

### Dev
| Skill | O que faz |
|---|---|
| `commit-message` | Gera mensagem Conventional Commits a partir do diff staged (apresenta; não commita). |

### Infra
| Skill | O que faz |
|---|---|
| `hetzner-vm` | Provisiona VM Hetzner + Coolify via Terraform. |
| `linux-vm-hardening` | Gera `cloud-init.yaml` com hardening (UFW, fail2ban, SSH key-only, Docker…). |
| `tailscale-setup` | Configura tailnet/VPN de acesso SSH. |

> `skill-gen` (a principal de autoria) é portável nos três runtimes e tem o repo dedicado
> [gabriel-f-santos/gen-skill](https://github.com/gabriel-f-santos/gen-skill).

## Instalar skills num projeto

`install-skills.sh` copia (ou linka via submódulo) skills daqui para o `.claude/skills/` do
projeto-alvo — que é o path que Claude Code e opencode descobrem nativamente (Codex usa
`.codex/skills/` ou uma entrada no `config.toml`; veja o `PORTABILITY.md` de cada skill).

```bash
# rode a partir do projeto-alvo, apontando pra este repo
./caminho/para/coding-agents/install-skills.sh --list                 # lista o catálogo
./caminho/para/coding-agents/install-skills.sh                        # instala todas
./caminho/para/coding-agents/install-skills.sh tech-discovery prd-creator   # específicas

# ou mantenha em sincronia via submódulo git
./caminho/para/coding-agents/install-skills.sh --submodule tech-discovery
```

Manualmente, é só copiar a pasta da skill (o nome da pasta tem que bater com o `name:`):
```bash
cp -r coding-agents/skills/tech-discovery <seu-projeto>/.claude/skills/
```

## Portabilidade (Claude Code · Codex · opencode)

O corpo das skills é portável; o controle por plataforma é sidecar:
- **Claude Code / opencode** — descobrem em `.claude/skills/`. `allowed-tools` só vale no Claude.
- **Codex** — copie pra `.codex/skills/` ou aponte no `config.toml`; deps em `agents/openai.yaml`.
- Cada skill multi-runtime traz um `PORTABILITY.md` com o que configurar onde.

## Autoria & qualidade

- **Criar/melhorar** uma skill → use `skill-gen` (entrevista → grounding → autoria → validação).
- **Validar** estrutura → `python3 skills/skill-gen/scripts/validate_skill.py <skill> [--cross-platform]`.
- **Auditar segurança** → `skill-scanner`.
- Referência de fundo: [`docs/advanced-skill-engineering.md`](docs/advanced-skill-engineering.md),
  [`best-practices-skill.md`](best-practices-skill.md), [`SECURITY_ANTIPATTERNS.md`](SECURITY_ANTIPATTERNS.md).

## Também neste repo

Além do catálogo de skills, o repo mantém:
- **`templates/`** — templates de projeto (FastAPI, Next.js, Flutter, Fastify) pra início rápido.
- **`.claude/`** — sistema multi-agente + PRP (agents/, commands/, docs de PRP) usado pelos templates.

---

Estrutura:
```
coding-agents/
├── skills/                 # ← o catálogo (uma pasta por skill)
├── install-skills.sh       # instalador (copy ou submódulo)
├── docs/                   # advanced-skill-engineering.md, etc.
├── templates/              # templates de projeto
└── .claude/                # multi-agente + PRP (agents, commands)
```
