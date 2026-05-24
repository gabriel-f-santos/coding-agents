---
name: linux-vm-hardening
description: |
  Gera cloud-init.yaml com hardening completo para VM Linux.
  Configura: usuário não-root sudo, SSH key-only (root prohibit-password para Coolify),
  UFW, fail2ban com ban progressivo, Docker, Coolify e unattended-upgrades.
  Suporta dois modos: SSH público restrito por IP ou SSH exclusivo via Tailscale VPN.
  Invocada pelo /hetzner-vm ou diretamente para qualquer VPS (DigitalOcean, AWS EC2, etc.).
argument-hint: "[caminho/para/cloud-init.yaml]"
arguments: [output_path]
allowed-tools: Write Read
---

# Linux VM Hardening — Gerador de Cloud-Init

Gera `cloud-init.yaml` pronto para qualquer VM Linux. Quando invocada pelo `/hetzner-vm`, todos os parâmetros já estão no contexto — usar diretamente sem perguntar novamente.

## Template base

!`cat "${CLAUDE_SKILL_DIR}/templates/cloud-init.yaml.tpl"`

## Parâmetros

Se não estiverem no contexto (invocação standalone), perguntar um por vez:

| Parâmetro | Default | Descrição |
|-----------|---------|-----------|
| `admin_username` | `deploy` | Usuário não-root com sudo |
| `ssh_public_key` | — | Conteúdo de `~/.ssh/id_ed25519.pub` |
| `ssh_port` | `22` | Porta SSH (só relevante no modo público) |
| `timezone` | `UTC` | Ex: `America/Sao_Paulo` |
| `ssh_mode` | `public` | `public` ou `tailscale` |
| `tailscale_auth_key` | — | Obrigatório se `ssh_mode=tailscale` |
| `output_path` | `$output_path` | Onde escrever o arquivo |

## Modo SSH — perguntar ao usuário

```
Como prefere acessar o servidor via SSH?

  [1] Público (padrão) — porta 22 aberta, restrita ao seu IP no firewall
  [2] Tailscale — porta 22 fechada, acesso só via VPN Tailscale
```

### Se ssh_mode = public

Substituir `{{UFW_SSH_RULES}}` por:
```yaml
  - ufw allow {{SSH_PORT}}/tcp comment "SSH"
```

Substituir `{{TAILSCALE_INSTALL}}` por linha vazia.

### Se ssh_mode = tailscale

Pedir ao usuário:
> **Você precisa de um auth key Tailscale.**
>
> 1. Acesse https://login.tailscale.com/admin/settings/keys
> 2. Clique **Generate auth key**
> 3. Marque: **Reusable** + **Pre-authorized** + **Tags: tag:server**
> 4. Expiry: 1 dia (a chave é usada só uma vez no boot)
> 5. Copie o token `tskey-auth-...`

Substituir `{{UFW_SSH_RULES}}` por:
```yaml
  - ufw allow in on tailscale0 comment "SSH via Tailscale"
  - ufw allow 41641/udp comment "Tailscale direct WireGuard"
```

Substituir `{{TAILSCALE_INSTALL}}` por:
```yaml
  # Tailscale VPN — instalar após UFW para não travar na ativação
  - curl -fsSL https://tailscale.com/install.sh | sh
  - tailscale up --auth-key={{TAILSCALE_AUTH_KEY}} --ssh --advertise-tags=tag:server
```

## Processo

1. Confirmar todos os parâmetros
2. Substituir cada `{{PLACEHOLDER}}` com os valores reais
3. Para `{{SSH_MODE}}`, `{{UFW_SSH_RULES}}` e `{{TAILSCALE_INSTALL}}`: aplicar a lógica de modo acima
4. Escrever o YAML resultante no `output_path` com a ferramenta Write
5. Confirmar: "cloud-init.yaml gerado em [path] — modo: [ssh_mode]"

## Decisões de segurança

| Configuração | Valor | Por que |
|---|---|---|
| `PermitRootLogin` | `prohibit-password` | Coolify exige root SSH; bloqueia senha, libera chave |
| `PasswordAuthentication` | `no` | Elimina superfície de ataque de brute-force |
| `AllowUsers` | `{{ADMIN_USERNAME}} root` | Whitelist — outros usuários rejeitados na autenticação |
| `MaxAuthTries 3` + fail2ban | ban após 3 erros | Bane IPs atacantes rapidamente |
| `bantime.increment` | até 7 dias | Reincidentes levam ban progressivo |
| Swap 2GB + swappiness=10 | só usa em último recurso | Coolify + PostgreSQL precisa de margem em VMs pequenas |
| UFW | deny incoming + allow explícito | Defense-in-depth além do firewall do provider |
| **Tailscale** | porta 22 fechada na internet | Maior postura: SSH só via WireGuard mesh criptografado |

## Comparação dos modos SSH

| | Modo público | Modo Tailscale |
|---|---|---|
| Porta 22 exposta | Sim, filtrada por IP | Não — completamente fechada |
| IP dinâmico | Problema (precisa atualizar tfvars) | Sem problema |
| Time com múltiplos IPs | Precisa listar todos | Basta estar no tailnet |
| Dependência externa | Nenhuma | Tailscale control plane |
| Recuperação se travado | Hetzner Console | Hetzner Console |
| Recomendado para | Projetos solo, IP fixo | Times, IPs dinâmicos |
