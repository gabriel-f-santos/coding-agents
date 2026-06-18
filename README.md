# coding-agents — Agent Skills catalog

A curated catalog of portable [Agent Skills](https://agentskills.io) — reusable, version-
controlled capabilities for Claude Code, OpenAI Codex, and opencode. This repo is the central
place we author, store, and distribute skills; copy what you need into a project.

Skills live under **`skills/`** (one folder per skill, each with a `SKILL.md`). Install them into
a project's `.claude/skills/` (the discovery path) with `install-skills.sh`.

> **Fonte da verdade.** Este repo é **canônico**. Edite uma skill **aqui**; os projetos
> consumidores (cota8, maripassa, …) recebem **cópias** via `install-skills.sh` ou
> `cp -r`. Nunca hand-edite a cópia num consumidor — a mudança é feita aqui e copiada de volta.

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
| **Iniciar o monorepo do zero (scaffold do esqueleto)** | `greenfield-monorepo` (entrevista → apps, AGENTS.md, lint/test/pre-commit, docker+seed, CI) |
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
| `celery-rabbitmq` | Processamento assíncrono confiável com Celery sobre RabbitMQ: retries nativos, DLX/DLQ (padrão `acks_late` + `acks_on_failure_or_timeout=False`), publish/consume por nome, beat/cron, monitoramento de mensagens presas. |

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

## Inspirações & adaptações

Parte do catálogo e do fluxo foi adaptada/inspirada em terceiros — crédito completo em
[`CREDITS.md`](CREDITS.md):
- **[Sentry](https://github.com/getsentry)** ([getsentry/skills](https://github.com/getsentry/skills)) —
  adaptação direta: `skill-scanner`, `sentry-security-review`, e o reporte *confidence-based* dos
  reviewers; aprendizado do `skill-writer` (iteração + description-optimization) foi pra `skill-gen`.
- **[Full Cycle](https://github.com/devfullcycle)** — influência metodológica: DDD/bounded
  contexts/event-driven → `tech-discovery` e `ddd`; os projetos `mba-ia-*` (refactor, PR
  evaluation, greenfield) ecoam `review-phase`, `refactor` e a mentalidade do pipeline
  discovery → design → plan → execute.

## Skills oficiais recomendadas (não duplicamos — usamos)

Para alguns domínios já existe uma skill **oficial do fornecedor**, mantida e sincronizada com a
doc deles. Em vez de duplicar (e envelhecer), recomendamos instalar a oficial e deixar as nossas
cuidarem do *workflow* (deploy, CI, pipeline).

| Domínio | Skill oficial | De quem / fonte | Como instalar |
|---|---|---|---|
| **Cloudflare** (Workers/Pages, D1/R2/KV, Workers AI/Agents, DNS, WAF, IaC) | `cloudflare` | **Cloudflare**, via marketplace oficial da Anthropic `anthropics/claude-plugins-official`. Viesada a buscar na doc em tempo real ("trust the docs"). | `/plugin marketplace add anthropics/claude-plugins-official` → `/plugin install cloudflare@claude-plugins-official` |

> Divisão: a skill oficial cobre **profundidade de plataforma/API**; as nossas (`greenfield-monorepo`,
> `github-actions`) cobrem o **workflow de deploy/CI** (wrangler, OIDC, gate por environment). Não
> criamos uma `cloudflare` nossa — seria redundante com a oficial.

## MCPs e ferramentas recomendadas

Algumas skills **descobrem e usam servidores MCP / apps externos em runtime** (e degradam de boa
se não estiverem conectados). Recomendados:

| Ferramenta | O que é | Usada por | Instalar / conectar |
|---|---|---|---|
| **Context7** (MCP) | Docs de libs/frameworks **version-specific**, em tempo real (melhor que memória) | `research`, `tech-discovery`, `skill-gen` (grounding), `copilotkit` | `claude mcp add context7 -- npx -y @upstash/context7-mcp` (Upstash) — ou via marketplace oficial |
| **Playwright** (MCP) | Automação de browser (snapshot, click, navigate, network) | `e2e-test-review`, `ux-design` (validação visual) | `claude mcp add playwright -- npx -y @playwright/mcp@latest` (Microsoft) |
| **pencil.dev** (app + MCP) | Ferramenta de design AI-first; gera telas a partir de spec; MCP **local** | `pencil`, `ux-design` | Baixar o app em [pencil.dev](https://pencil.dev); a MCP sobe local e é **auto-registrada** pela extensão (sem `claude mcp add`). Abrir com o alias `pencil` |
| **Figma** (MCP) *(opcional)* | Dev Mode MCP — cria/edita frames | `figma`, `ux-design` | Habilitar o Figma Dev Mode MCP (precisa de seat pago p/ write) |

> As skills de design (`ux-design` → `pencil`/`figma`) e de docs (`research`/`tech-discovery` →
> context7) fazem **descoberta em runtime**: usam a MCP se estiver conectada, senão degradam
> (wireframes textuais / docs por web). Nada quebra se a ferramenta não estiver presente.

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
