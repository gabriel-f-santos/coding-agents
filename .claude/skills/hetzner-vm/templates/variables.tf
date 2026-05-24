# =============================================================================
# Required
# =============================================================================

variable "hetzner_api_token" {
  description = "Hetzner Cloud API token (Read+Write)"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name — used to name all Hetzner resources"
  type        = string
}

variable "ssh_public_key" {
  description = "ED25519 public key content (cat ~/.ssh/id_ed25519.pub)"
  type        = string
}

variable "ssh_allowed_ips" {
  description = "CIDR list of IPs allowed for SSH (public mode) and Coolify dashboard"
  type        = list(string)
}

# =============================================================================
# SSH mode
# =============================================================================

variable "ssh_mode" {
  description = "SSH access mode: 'public' (port open to ssh_allowed_ips) or 'tailscale' (port closed, access via VPN)"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "tailscale"], var.ssh_mode)
    error_message = "ssh_mode must be 'public' or 'tailscale'."
  }
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key (required when ssh_mode = 'tailscale'). Generate at tailscale.com/admin/settings/keys"
  type        = string
  sensitive   = true
  default     = ""
}

# =============================================================================
# Optional — sensible defaults
# =============================================================================

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "prod"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cpx21"
  # cx23:  2 vCPU  4 GB  40 GB   ~€3.49/mo  (minimum viable)
  # cpx21: 3 vCPU  4 GB  80 GB   ~€7.49/mo  (recommended)
  # cax21: 4 vCPU  8 GB  80 GB   ~€9.49/mo  (ARM — best price/perf)
}

variable "server_image" {
  description = "Server OS image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
  # nbg1: Nuremberg | hel1: Helsinki | fsn1: Falkenstein | ash: Ashburn
}

variable "ssh_port" {
  description = "SSH port (only used when ssh_mode = 'public')"
  type        = string
  default     = "22"
}

variable "admin_username" {
  description = "Non-root admin user created on the server"
  type        = string
  default     = "deploy"
}
