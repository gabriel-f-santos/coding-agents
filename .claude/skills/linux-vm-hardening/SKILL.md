---
name: linux-vm-hardening
description: |
  Gera cloud-init.yaml com hardening completo para VM Linux.
  Configura: usuário não-root sudo, SSH key-only (root prohibit-password para Coolify),
  UFW, fail2ban com ban progressivo, Docker, Coolify e unattended-upgrades.
  Invocada pelo /hetzner-vm ou diretamente para qualquer VPS (DigitalOcean, AWS EC2, etc.).
  Use quando precisar de um cloud-init.yaml seguro para nova VM Linux.
argument-hint: "[caminho/para/cloud-init.yaml]"
arguments: [output_path]
allowed-tools: Write Read
---

# Linux VM Hardening — Gerador de Cloud-Init

Gera `cloud-init.yaml` pronto para uso em qualquer VM Linux. Quando invocada pelo `/hetzner-vm`, todos os parâmetros já estão no contexto — usar diretamente sem perguntar novamente.

## Template base

!`cat "${CLAUDE_SKILL_DIR}/templates/cloud-init.yaml.tpl"`

## Parâmetros

Se os valores abaixo **não estiverem no contexto** (invocação standalone), perguntar um por vez:

| Parâmetro | Default | Descrição |
|-----------|---------|-----------|
| `admin_username` | `deploy` | Usuário não-root com sudo |
| `ssh_public_key` | — | Conteúdo de `~/.ssh/id_ed25519.pub` |
| `ssh_port` | `22` | Porta SSH |
| `timezone` | `UTC` | Ex: `America/Sao_Paulo` |
| `output_path` | `$output_path` ou `cloud-init.yaml` | Onde escrever o arquivo |

Se invocado com argumento (`/linux-vm-hardening infra/hetzner/cloud-init.yaml`), usar `$output_path` como destino.

## Processo

1. Confirmar todos os parâmetros (contexto atual ou perguntar)
2. Substituir cada `{{PLACEHOLDER}}` do template pelo valor real:
   - `{{ADMIN_USERNAME}}` → admin_username
   - `{{SSH_PUBLIC_KEY}}` → ssh_public_key (linha completa)
   - `{{SSH_PORT}}` → ssh_port
   - `{{TIMEZONE}}` → timezone
3. Escrever o YAML resultante no `output_path` usando a ferramenta Write
4. Confirmar: "cloud-init.yaml gerado em [path]"

## Decisões de segurança

| Configuração | Valor | Por que |
|---|---|---|
| `PermitRootLogin` | `prohibit-password` | Coolify exige root SSH; bloqueia senha, libera chave |
| `PasswordAuthentication` | `no` | Elimina superfície de ataque de brute-force |
| `AllowUsers` | `{{ADMIN_USERNAME}} root` | Whitelist explícita — outros usuários rejeitados na autenticação |
| `MaxAuthTries 3` + fail2ban | ban após 3 erros | Combinação que bane rapidamente IPs atacantes |
| `bantime.increment` | até 7 dias | Reincidentes levam ban progressivo (1h → 2h → 4h...) |
| Swap 2GB + swappiness=10 | só usa swap em último recurso | Coolify com PostgreSQL/Redis precisa de margem em VMs pequenas |
| UFW | deny incoming + allow explícito | Defense-in-depth: funciona mesmo se o firewall do provider falhar |
