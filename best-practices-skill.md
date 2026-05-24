# Boas Práticas para Criar Skills no Claude Code

Skills são slash commands `/nome` que o Claude pode invocar automaticamente ou que você invoca manualmente. Este guia cobre tudo para criar, organizar e distribuir skills de qualidade.

---

## Estrutura de Arquivos

```
.claude/
└── skills/
    └── nome-da-skill/
        ├── SKILL.md          ← obrigatório (nome exato, case-sensitive)
        ├── reference.md      ← opcional: referências extensas
        ├── examples.md       ← opcional: exemplos de uso
        └── scripts/
            └── helper.sh     ← opcional: scripts auxiliares
```

**Onde colocar:**

| Local | Escopo | Uso |
|-------|--------|-----|
| `.claude/skills/` no repositório | Projeto/time | Skills do time, vão pro git |
| `~/.claude/skills/` | Pessoal | Usadas em todos os projetos |

**Regras de nome:**
- Diretório: `kebab-case` → vira o comando `/nome-da-skill`
- Arquivo principal: sempre `SKILL.md` (maiúsculo)
- Tamanho: manter `SKILL.md` abaixo de ~500 linhas; detalhes em arquivos separados

---

## Formato do SKILL.md

```yaml
---
name: nome-da-skill               # opcional, padrão = nome do diretório
description: |                    # RECOMENDADO — como Claude decide invocar
  O que faz e quando usar.
  Frases que o usuário naturalmente falaria.
  Palavras-chave do domínio.
argument-hint: "[issue-number]"   # aparece no autocomplete
arguments: [issue, branch]        # argumentos nomeados ($0, $1 ou $name)
disable-model-invocation: true    # só usuário pode invocar (sem auto-trigger)
user-invocable: false             # só Claude invoca (oculto do menu /)
allowed-tools: Bash(git *) Read   # aprova ferramentas sem prompt
context: fork                     # executa em subagente isolado
agent: Explore                    # tipo do subagente (Explore, Plan, general-purpose)
model: sonnet                     # sobrescreve modelo
---

# Conteúdo da skill aqui
```

---

## Progressive Disclosure (Divulgação Progressiva)

Coloque o que é mais importante primeiro. Claude carrega o conteúdo do skill inteiro na sessão — cada linha custa tokens por toda a conversa.

```
SKILL.md
├── 1. Objetivo (1-2 frases) ← sempre visível, carregado primeiro
├── 2. Quando usar / não usar ← guia Claude na decisão de invocar
├── 3. Processo (passos principais) ← instrução principal
└── 4. Ver reference.md para detalhes ← carregado só quando necessário
```

**Princípio:** Se remover uma seção não confundiria Claude durante a execução, remova ou mova para arquivo auxiliar.

---

## Boas Descrições (Como Claude Decide Invocar)

A `description` é o que Claude lê para decidir **se e quando** invocar o skill. É o campo mais importante.

### Fórmula
1. Ação/resultado primeiro ("Gera PRD...", "Faz review do código...")
2. Frases de trigger ("Use quando...", "Quando o usuário pedir...")
3. Contexto relevante ("Requer backend pronto", "Edita docs/...")
4. O que NÃO usar ("Pula pra X se for bugfix")

### Exemplos

```yaml
# ✅ Bom: ação-primeiro, triggers claros, escopo definido
description: |
  Gera PRD estruturado em docs/prd/<slug>-prd.md via entrevista guiada.
  Use antes de implementar qualquer feature com UI.
  Pula se for bugfix, refactor ou backend-only.

# ✅ Bom: keywords naturais, output claro
description: |
  Faz review do diff atual buscando bugs, problemas de segurança e violações
  de convenção. Use quando quiser feedback antes de commitar ou abrir PR.

# ❌ Ruim: vago, sem trigger, sem output claro
description: |
  Ferramenta para ajudar com código.
```

**Limite:** ~1.536 caracteres combinando `description` + `when_to_use`. Coloque os triggers mais importantes primeiro.

---

## Controle de Invocação

| Frontmatter | Usuário invoca | Claude auto-invoca | Aparece no menu `/` |
|-------------|----------------|-------------------|---------------------|
| (padrão) | ✅ | ✅ | ✅ |
| `disable-model-invocation: true` | ✅ | ❌ | ✅ |
| `user-invocable: false` | ❌ | ✅ | ❌ |

**Use `disable-model-invocation: true` para:**
- Skills com efeitos colaterais (commit, deploy, envio de mensagem)
- Fluxos de entrevista/wizard que você quer controlar manualmente
- Qualquer coisa perigosa de acionar sem intenção explícita

**Use `user-invocable: false` para:**
- Conhecimento de background (arquitetura, contexto legado)
- Guias que Claude aplica mas nunca como comando direto

---

## Injeção de Contexto Dinâmico

Use `` !`comando` `` para executar shell antes de Claude ver o conteúdo:

```markdown
## Estado atual
!`git status --short`

## Diff
!`git diff HEAD`

## Instruções
Resuma as mudanças acima em 2-3 bullets...
```

Multi-linha:

````markdown
## Ambiente
```!
node --version
git status --short
cat package.json | jq '.dependencies | keys'
```
````

**Variáveis disponíveis:**

| Variável | Valor |
|----------|-------|
| `$ARGUMENTS` | Todos os argumentos: `/skill arg1 arg2` |
| `$0`, `$1`, `$2` | Posicionais |
| `$nome` | Argumento nomeado (de `arguments: [nome]`) |
| `${CLAUDE_SKILL_DIR}` | Caminho do diretório da skill |
| `${CLAUDE_EFFORT}` | Nível de esforço atual |

---

## Estrutura de Conteúdo Recomendada

```markdown
# Nome da Skill

Uma frase: o que faz.

## Quando usar

- Caso A
- Caso B

## Quando NÃO usar

- Caso C → use /outra-skill
- Caso D → não precisa de skill

## Pipeline (se faz parte de um fluxo)

skill-atual ──► proxima-skill ──► outra-skill

## Processo

1. Passo com ação clara
2. Passo seguinte
3. ...

## Referência

Ver [reference.md](reference.md) para detalhes.
```

---

## Portabilidade (Copiar Entre Projetos)

Para que uma skill seja portável:

1. **Coloque em `.claude/skills/`** do repo (não em `~/.claude/`) para versionar
2. **Use `${CLAUDE_SKILL_DIR}`** em vez de caminhos absolutos em bash
3. **Use caminhos relativos** ao root do projeto (ex: `docs/prd/`)
4. **Documente pré-requisitos** na description ou numa seção "Requer"
5. **Evite hardcode** de nomes de branches, URLs ou variáveis de ambiente específicas

```markdown
## Requer
- Estrutura `docs/prd/` no projeto
- Backend com endpoints REST documentados
- Variável `$PROJECT_ROOT` acessível
```

---

## Checklist Antes de Publicar

- [ ] `description` tem triggers claros e output esperado
- [ ] `SKILL.md` tem menos de ~500 linhas (resto em arquivos auxiliares)
- [ ] Seção "Quando usar" e "Quando NÃO usar" presente
- [ ] `disable-model-invocation: true` se tem efeitos colaterais
- [ ] Testou invocando manualmente: `/nome-da-skill`
- [ ] Testou auto-trigger: pediu ao Claude algo que deveria invocar a skill
- [ ] Caminhos são relativos (portável entre projetos)
- [ ] Sem comentários redundantes que expliquem "o quê" em vez do "porquê"

---

## Armadilhas Comuns

| Problema | Causa | Solução |
|----------|-------|---------|
| Skill não auto-invoca | Description vaga ou `disable-model-invocation: true` | Reescrever description com triggers; rodar `/skills` |
| Description truncada | Mais de ~1.536 chars | Mover detalhes para `when_to_use` ou início do conteúdo |
| Tokens altos por sessão | `SKILL.md` longo demais | Mover referências para `reference.md` |
| Argumentos não substituem | Sintaxe errada | Usar `$0`, `$1` não `$ARGUMENTS[0]` |
| Bash injection não roda | Espaço faltando | `` !`cmd` `` com backtick colado ao `!` |
| Skill funciona localmente mas não após copiar | Caminho hardcoded | Usar `${CLAUDE_SKILL_DIR}` e caminhos relativos |

---

## Exemplo de Skill Mínima Portável

```
.claude/skills/code-review/
├── SKILL.md
└── checklist.md
```

**SKILL.md:**
```yaml
---
name: code-review
description: |
  Faz review do diff atual buscando bugs, segurança e convenções do projeto.
  Use quando quiser feedback antes de commitar, abrir PR ou após implementar uma feature.
  Não usar para revisão de arquitetura ou decisões de produto.
allowed-tools: Bash(git diff *) Bash(git log *) Read Grep
---

# Code Review

## Estado do diff
!`git diff HEAD --stat`

## Instruções

Analise o diff atual com foco em:

1. Bugs de lógica e casos extremos
2. Vulnerabilidades de segurança (OWASP Top 10)
3. Violações de convenção do projeto (leia CLAUDE.md se existir)
4. Performance óbvia degradada

Para cada problema encontrado:
- Cite arquivo:linha
- Classifique: Bug / Segurança / Convenção / Performance
- Sugira correção concreta

Ver [checklist.md](checklist.md) para critérios detalhados por categoria.
```
