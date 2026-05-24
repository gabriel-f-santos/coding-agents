terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_api_token
}

resource "hcloud_ssh_key" "main" {
  name       = "${var.project_name}-deploy-key"
  public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "hcloud_server" "main" {
  name         = "${var.project_name}-${var.environment}"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.main.id]
  firewall_ids = [hcloud_firewall.main.id]
  user_data    = file("${path.module}/cloud-init.yaml")

  lifecycle {
    ignore_changes = [ssh_keys, user_data]
  }
}
