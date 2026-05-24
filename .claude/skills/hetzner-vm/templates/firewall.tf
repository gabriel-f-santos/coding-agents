# Fetch Cloudflare IP ranges dynamically
# HTTP/HTTPS are restricted to Cloudflare only — prevents bypassing WAF/DDoS protection
data "http" "cloudflare_ips_v4" {
  url = "https://www.cloudflare.com/ips-v4"
}

data "http" "cloudflare_ips_v6" {
  url = "https://www.cloudflare.com/ips-v6"
}

locals {
  cloudflare_ipv4 = compact(split("\n", trimspace(data.http.cloudflare_ips_v4.response_body)))
  cloudflare_ipv6 = compact(split("\n", trimspace(data.http.cloudflare_ips_v6.response_body)))
  cloudflare_ips  = concat(local.cloudflare_ipv4, local.cloudflare_ipv6)
}

resource "hcloud_firewall" "main" {
  name   = "${var.project_name}-${var.environment}-fw"
  labels = { project = var.project_name, env = var.environment }

  # SSH — admin IPs only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = var.ssh_port
    source_ips  = var.ssh_allowed_ips
    description = "SSH"
  }

  # HTTP — Cloudflare only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = local.cloudflare_ips
    description = "HTTP via Cloudflare"
  }

  # HTTPS — Cloudflare only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = local.cloudflare_ips
    description = "HTTPS via Cloudflare"
  }

  # Coolify dashboard — admin only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "8000"
    source_ips  = var.ssh_allowed_ips
    description = "Coolify UI"
  }

  # Coolify WebSocket — admin only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "6001"
    source_ips  = var.ssh_allowed_ips
    description = "Coolify WebSocket"
  }

  # Coolify terminal proxy — admin only
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "6002"
    source_ips  = var.ssh_allowed_ips
    description = "Coolify terminal"
  }

  # ICMP for diagnostics
  rule {
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "ICMP"
  }
}
