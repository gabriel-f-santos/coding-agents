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
  description = "CIDR list of IPs allowed for SSH and Coolify (your IP)"
  type        = list(string)
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
  default     = "cx23"
  # cx23:  2 vCPU  4 GB  40 GB   ~€3.49/mo  (minimum viable for Coolify)
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
  description = "SSH port (change to reduce bot noise)"
  type        = string
  default     = "22"
}

variable "admin_username" {
  description = "Non-root admin user created on the server"
  type        = string
  default     = "deploy"
}
