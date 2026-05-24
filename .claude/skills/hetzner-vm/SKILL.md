---
name: hetzner-vm
description: |
  Provisiona VM Hetzner completa com Coolify via Terraform.
  Copia templates terraform para infra/hetzner/, chama /linux-vm-hardening
  para gerar cloud-init seguro, e executa terraform apply.
  Funciona em qualquer projeto — não exige estrutura pré-existente.
  Use para criar nova VM Hetzner com Coolify em qualquer projeto.
  Não usar para atualizar infra existente sem revisar o plan primeiro.
disable-model-invocation: true
allowed-tools: Bash(terraform *) Bash(tofu *) Bash(hcloud *) Bash(ssh *) Bash(curl *) Bash(cp *) Bash(mkdir *) Bash(ls *) Bash(cat *) Read Write
---

# Hetzner VM — Provisionamento Completo

Wizard que provisiona do zero: copia templates → chama `/linux-vm-hardening` → terraform apply.

## Estado atual do ambiente

```!
echo "=== Ferramentas ===" \
  && (terraform version 2>/dev/null | head -1 || tofu version 2>/dev/null | head -1 || echo "terraform/tofu: NAO INSTALADO") \
  && (hcloud version 2>/dev/null | head -1 || echo "hcloud: nao instalado (opcional)") \
  && echo "" && echo "=== Projeto ===" \
  && (ls infra/hetzner/ 2>/dev/null && echo "infra/hetzner/ ja existe" || echo "infra/hetzner/ sera criado") \
  && (ls infra/hetzner/terraform.tfvars 2>/dev/null && echo "terraform.tfvars: JA EXISTE" || echo "terraform.tfvars: sera criado") \
  && (ls infra/hetzner/cloud-init.yaml 2>/dev/null && echo "cloud-init.yaml: JA EXISTE" || echo "cloud-init.yaml: sera gerado") \
  && echo "" && echo "=== Seu IP publico ===" && (curl -s --max-time 3 ifconfig.me || echo "nao obtido") \
  && echo "" && echo "=== SSH Key ===" \
  && (cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo "~/.ssh/id_ed25519.pub nao encontrada")
```

## Passo 1 — Ferramentas

Se `terraform`/`tofu` não instalado, parar e orientar:
- OpenTofu (recomendado): `snap install --classic opentofu` ou `brew install opentofu`
- Terraform: `brew install terraform`

hcloud CLI é opcional mas útil para validar o token:
- `brew install hcloud` ou https://github.com/hetznercloud/cli/releases

## Passo 2 — Copiar templates para o projeto

```bash
mkdir -p infra/hetzner
cp -r "${CLAUDE_SKILL_DIR}/templates/." infra/hetzner/
ls infra/hetzner/
```

## Passo 3 — Coletar parâmetros (um por vez)

**Obrigatórios:**

1. **`project_name`** — nome do projeto em kebab-case (ex: `meuapp`). Nomeia todos os recursos no Hetzner.

2. **`hetzner_api_token`** — token de API Hetzner com permissão Read+Write.
   > Console Hetzner > selecione o projeto > **Security > API Tokens > Generate API Token**
   > Permissão: **Read & Write** — token mostrado uma única vez, copiar agora.

3. **`ssh_public_key`** — conteúdo da chave pública SSH (já detectado acima).
   - Se não existe: `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "deploy@hetzner"`

4. **`ssh_allowed_ips`** — IP público atual já detectado acima. Confirmar com o usuário.
   - Se IP for dinâmico: avisar que precisará atualizar e rodar `terraform apply` quando mudar.
   - Formato: `["1.2.3.4/32"]` — múltiplos: `["1.2.3.4/32", "5.6.7.8/32"]`

5. **`admin_username`** — usuário não-root no servidor (default: `deploy`).

6. **`ssh_mode`** — como quer acessar o servidor via SSH:

   ```
   [1] Público (padrão) — porta 22 aberta, restrita ao seu IP no firewall Hetzner
   [2] Tailscale — porta 22 fechada na internet, acesso só via VPN Tailscale
   ```

   **Se escolher Tailscale**, pedir o auth key:
   > 1. Acesse https://login.tailscale.com/admin/settings/keys
   > 2. **Generate auth key** com: Reusable + Pre-authorized + tag:server + expiry 1 dia
   > 3. Copie o `tskey-auth-...`

   Vantagem do Tailscale: funciona com IP dinâmico, times com múltiplos IPs, e fecha completamente a porta 22 na internet. Desvantagem: dependência do serviço Tailscale (se travado, usar o Console web da Hetzner).

**Opcionais** — mostrar defaults e perguntar se quer alterar:

| Parâmetro | Default | Opções |
|-----------|---------|--------|
| `server_type` | `cpx21` (€7.49) | `cx23` 2vCPU/4GB €3.49 · `cax21` 4vCPU/8GB ARM €9.49 |
| `location` | `nbg1` Nuremberg | `hel1` Helsinki · `fsn1` Falkenstein |
| `ssh_port` | `22` | outro número reduz ruído de bots (só no modo público) |
| `timezone` | `UTC` | ex: `America/Sao_Paulo` |

## Passo 4 — Gerar cloud-init.yaml

Invocar `/linux-vm-hardening` com todos os parâmetros coletados:
- `output_path`: `infra/hetzner/cloud-init.yaml`
- `admin_username`, `ssh_public_key`, `ssh_port`, `timezone`, `ssh_mode`
- `tailscale_auth_key` se `ssh_mode=tailscale`

Aguardar a geração do arquivo antes de continuar.

## Passo 5 — Criar terraform.tfvars

Criar `infra/hetzner/terraform.tfvars` com os valores coletados. Não exibir o token em output.

## Passo 6 — Terraform init + plan

```bash
cd infra/hetzner && terraform init
```

```bash
cd infra/hetzner && terraform plan -out=tfplan
```

Resumir o plano: recursos criados, server_type, location. Se aparecer qualquer `destroy`, **parar e pedir confirmação explícita** com aviso de impacto.

### Verificação obrigatória por ssh_mode

Antes de pedir confirmação, validar que o plano bate com o modo escolhido:

**`ssh_mode = tailscale`** — plano deve ter **apenas**:
- ✅ UDP 41641 — Tailscale WireGuard
- ✅ TCP 80 / 443 — Cloudflare
- ✅ ICMP
- ❌ TCP 22 — não deve aparecer
- ❌ TCP 8000 / 6001 / 6002 — não devem aparecer (Coolify via Tailscale IP)

**`ssh_mode = public`** — plano deve ter:
- ✅ TCP 22 restrito a `ssh_allowed_ips`
- ✅ TCP 8000 / 6001 / 6002 restrito a `ssh_allowed_ips`
- ✅ TCP 80 / 443 — Cloudflare
- ✅ ICMP

Se qualquer porta errada aparecer, parar, corrigir o tfvars e re-rodar o plan.

## Passo 7 — Confirmação e apply

Pedir confirmação antes de aplicar. Após OK do usuário:

```bash
cd infra/hetzner && terraform apply tfplan
```

## Passo 8 — Outputs e próximos passos

```bash
cd infra/hetzner && terraform output
```

Apresentar ao usuário — mensagem varia por `ssh_mode`:

**Modo `public`:**
```
SERVIDOR PROVISIONADO
=====================
IP público: [server_ip]
SSH:        ssh [admin_username]@[server_ip] -p [ssh_port]
Coolify:    http://[server_ip]:8000  (disponível em ~10 min)

O servidor ainda está instalando Docker e Coolify via cloud-init.
Para acompanhar: ssh [admin_username]@[server_ip] 'sudo cloud-init status --wait'

PRÓXIMOS PASSOS:
1. Acesse http://[server_ip]:8000 → crie conta admin
2. Setup wizard → escolha "Localhost"
3. Tela "Server is not reachable": copie a chave pública exibida e rode:
   ssh [admin_username]@[server_ip] 'sudo mkdir -p /root/.ssh && sudo chmod 700 /root/.ssh && echo "CHAVE_AQUI" | sudo tee -a /root/.ssh/authorized_keys && sudo chmod 600 /root/.ssh/authorized_keys'
   Depois clique "Check Again" — deve conectar.
4. Configure DNS: coolify.seudominio.com → A → [server_ip] (DNS Only)
   ⚠️  PORTA 8000 NÃO É SUPORTADA pelo proxy Cloudflare — deixe o registro em "DNS Only" (nuvem cinza)
5. Coolify Settings > Instance > FQDN → https://coolify.seudominio.com
   ⚠️  SSL Cloudflare: use modo "Full" (NÃO "Full Strict") até o Coolify gerar o certificado Let's Encrypt
       "Full Strict" com cert self-signed gera erro 526. Troque para Full Strict depois que o cert estiver ativo.
6. Conecte GitHub App → Resources → primeiro deploy
```

**Modo `tailscale`:**
```
SERVIDOR PROVISIONADO
=====================
IP público:   [server_ip]  (só para tráfego web — SSH/Coolify fechados)
IP Tailscale: aguardando... rode: tailscale status | grep [project_name]
SSH:          ssh [admin_username]@<tailscale-ip>
Coolify:      http://<tailscale-ip>:8000  (disponível em ~10 min, só via Tailscale)

O servidor ainda está instalando Docker, Coolify e Tailscale via cloud-init.
Para acompanhar: ssh [admin_username]@<tailscale-ip> 'sudo cloud-init status --wait'

PRÓXIMOS PASSOS:
1. Aguarde o IP Tailscale: tailscale status
2. Acesse http://<tailscale-ip>:8000 → crie conta admin
3. Setup wizard → escolha "Localhost"
4. Tela "Server is not reachable": copie a chave pública exibida e rode:
   ssh [admin_username]@<tailscale-ip> 'sudo mkdir -p /root/.ssh && sudo chmod 700 /root/.ssh && echo "CHAVE_AQUI" | sudo tee -a /root/.ssh/authorized_keys && sudo chmod 600 /root/.ssh/authorized_keys'
   Depois clique "Check Again" — deve conectar.
5. Configure DNS: coolify.seudominio.com → A → [server_ip] (DNS Only)
   ⚠️  PORTA 8000 NÃO É SUPORTADA pelo proxy Cloudflare — deixe o registro em "DNS Only" (nuvem cinza)
6. Coolify Settings > Instance > FQDN → https://coolify.seudominio.com
   ⚠️  SSL Cloudflare: use modo "Full" (NÃO "Full Strict") até o Coolify gerar o certificado Let's Encrypt
       "Full Strict" com cert self-signed gera erro 526. Troque para Full Strict depois que o cert estiver ativo.
7. Conecte GitHub App → Resources → primeiro deploy
```

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `SSH key name already exists` | Chave já no projeto Hetzner | `terraform import hcloud_ssh_key.main <KEY_ID>` |
| `Invalid token` | API token errado ou expirado | Regerar no console Hetzner |
| SSH recusa após 10+ min | IP não está em `ssh_allowed_ips` | `curl ifconfig.me` e atualizar tfvars |
| Coolify não abre na 8000 | cloud-init ainda rodando | `ssh [admin_username]@IP 'sudo cloud-init status'` |
| `Server is not reachable` no wizard Coolify | Chave SSH do Coolify não está em `/root/.ssh/authorized_keys` | Copiar a chave exibida na tela e rodar: `echo "CHAVE" \| sudo tee -a /root/.ssh/authorized_keys` → Check Again |
| `connect to host.docker.internal port 22: Operation timed out` | UFW bloqueia SSH do container Docker para o host — `ufw allow` não funciona para bridge Docker, precisa ir em `before.rules` | `sudo sed -i '/^# End required lines/a \\n# Allow Docker containers to reach host SSH\n-A ufw-before-input -i docker0 -p tcp --dport 22 -j ACCEPT\n-A ufw-before-input -i br-+ -p tcp --dport 22 -j ACCEPT' /etc/ufw/before.rules && sudo ufw reload` |
| `Error acquiring state lock` | Apply anterior travado | `cd infra/hetzner && terraform force-unlock LOCK_ID` |
| Erro 526 no Cloudflare | SSL mode "Full Strict" com cert self-signed do Coolify | Trocar para modo "Full" no Cloudflare até o Let's Encrypt ser gerado |
| Dashboard Coolify abre mas sem HTTPS via Cloudflare | Porta 8000 não é suportada pelo proxy Cloudflare | Acesse via IP direto (`:8000`) ou configure FQDN com porta padrão 443 |
