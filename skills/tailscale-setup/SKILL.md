---
name: tailscale-setup
description: |
  Guia setup completo do Tailscale: conta, cliente na máquina local, ACL policy
  e geração de auth key para servidor. Invocada pelo /hetzner-vm e /linux-vm-hardening
  quando ssh_mode=tailscale, ou diretamente para configurar um tailnet do zero.
  Use quando for usar Tailscale como VPN de acesso SSH a servidores.
---

# Tailscale Setup

Configura o tailnet completo: conta → cliente local → ACL policy → auth key para servidor.
Quando invocada por outra skill, os passos já concluídos podem ser pulados — perguntar ao usuário o que já está feito.

## Estado atual

```!
echo "=== Tailscale cliente ===" \
  && (tailscale version 2>/dev/null || echo "NAO INSTALADO") \
  && echo "=== Status ===" \
  && (tailscale status 2>/dev/null | head -5 || echo "nao conectado")
```

## Passo 1 — Conta Tailscale

Se o usuário ainda não tem conta:

> Acesse **https://tailscale.com** e clique em **Get started**.
> Pode usar conta Google, GitHub, Microsoft ou email.
> O plano **gratuito** cobre até 3 usuários e 100 dispositivos — suficiente para uso pessoal.

Confirmar que tem conta antes de continuar.

## Passo 2 — Instalar cliente na sua máquina

Verificar o estado acima.

**Se já instalado e conectado** (`tailscale status` mostra IP 100.x.x.x): pular este passo.

**Se não instalado**, perguntar ao usuário:
> "Tailscale não encontrado na sua máquina. Posso instalar agora?"

Se confirmar, detectar o OS e instalar:

**Linux (Ubuntu/Debian)** — rodar diretamente:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

**macOS** — rodar diretamente se `brew` disponível:
```bash
brew install tailscale
```
Ou orientar a baixar em https://tailscale.com/download/mac se não tiver brew.

**Windows:** não é possível instalar via terminal — orientar a baixar em https://tailscale.com/download/windows.

Após instalar, autenticar (abre o browser):
```bash
sudo tailscale up
```

Verificar conexão:
```bash
tailscale status
# deve mostrar seu dispositivo com IP 100.x.x.x
```

## Passo 3 — Configurar ACL Policy

A ACL define quem pode acessar o quê no tailnet. **Sem ela, o Tailscale SSH fica bloqueado mesmo com o servidor enrollado.**

Acessar: **https://login.tailscale.com/admin/acls**

Substituir o conteúdo pelo JSON abaixo (ajustar `users` com o email da conta Tailscale):

```json
{
  "tagOwners": {
    "tag:server": ["autogroup:admin"]
  },
  "grants": [
    {
      "src": ["autogroup:admin"],
      "dst": ["tag:server"],
      "ip":  ["*"]
    }
  ],
  "ssh": [
    {
      "action": "accept",
      "src":    ["autogroup:admin"],
      "dst":    ["tag:server"],
      "users":  ["deploy", "root"]
    }
  ]
}
```

Clicar em **Save** para aplicar.

**O que cada bloco faz:**

| Bloco | Função |
|---|---|
| `tagOwners` | Define que admins controlam a tag `tag:server` |
| `grants` | Libera tráfego de rede: admin → servidores com tag server |
| `ssh` | Autoriza SSH especificamente para os usuários `deploy` e `root` |

Se quiser adicionar mais usuários do time ao SSH, adicionar os emails em `src`:
```json
"src": ["autogroup:admin", "colega@email.com"]
```

## Passo 4 — Gerar auth key para o servidor

Acessar: **https://login.tailscale.com/admin/settings/keys**

Clicar em **Generate auth key** com estas configurações:

| Campo | Valor | Por que |
|---|---|---|
| Description | `hetzner-prod` (ou nome do servidor) | Identificação |
| Reusable | ✅ Sim | Permite recriar o servidor sem gerar nova key |
| Ephemeral | ❌ Não | Servidor persiste offline sem sair do tailnet |
| Pre-authorized | ✅ Sim | Pula fila de aprovação manual |
| Tags | `tag:server` | Aplica as ACL rules do Passo 3 |
| Expiry | 1 dia | A key é usada só no boot — expira antes de ser reutilizada |

Copiar o token `tskey-auth-...` — **mostrado apenas uma vez**.

Confirmar ao usuário:
> "Auth key gerada. Guarde o token `tskey-auth-...` — vamos usá-lo no terraform.tfvars."

## Passo 5 — Após o servidor subir

Quando o servidor terminar o cloud-init, verificar que entrou no tailnet:

```bash
tailscale status
# deve aparecer o novo servidor com IP 100.x.x.x e tag:server
```

Conectar via SSH:
```bash
# pelo IP do tailnet (não o IP público da Hetzner)
ssh deploy@$(tailscale ip -4 nome-do-servidor)

# ou pelo nome do dispositivo no tailnet
tailscale ssh deploy@nome-do-servidor
```

O comando `tailscale ssh` autentica automaticamente pelo tailnet — sem precisar de chave SSH no cliente.

## Troubleshooting

| Problema | Causa | Solução |
|---|---|---|
| Servidor não aparece em `tailscale status` | cloud-init ainda rodando | Aguardar ~10 min após terraform apply |
| SSH recusado com "permission denied" | ACL policy não salva | Verificar https://login.tailscale.com/admin/acls |
| `tailscale ssh` não encontra o host | Nome diferente do esperado | `tailscale status` para ver o nome exato |
| Servidor sumiu do tailnet | `tailscaled` crashou | Hetzner Console → `sudo systemctl restart tailscaled` |
| Auth key expirou antes de usar | Expiry curto demais | Gerar nova key com expiry maior |

## Recuperação de emergência (lockout)

Se perder acesso via Tailscale:

1. **Hetzner Console** (sempre funciona): dashboard Hetzner → servidor → **Console**
   - Acessa o terminal via VNC no browser, sem depender de rede
   - De lá: `sudo systemctl status tailscaled` e `sudo systemctl restart tailscaled`

2. Se precisar reinscrutar o servidor no tailnet:
   ```bash
   sudo tailscale up --auth-key=NOVA_KEY --ssh --advertise-tags=tag:server
   ```
