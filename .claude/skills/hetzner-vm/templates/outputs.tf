output "server_ip" {
  description = "Server public IPv4"
  value       = hcloud_server.main.ipv4_address
}

output "ssh_command" {
  description = "SSH command to connect as admin"
  value       = "ssh -p ${var.ssh_port} ${var.admin_username}@${hcloud_server.main.ipv4_address}"
}

output "coolify_url" {
  description = "Coolify dashboard (direct IP, use until domain is configured)"
  value       = "http://${hcloud_server.main.ipv4_address}:8000"
}

output "server_name" {
  value = hcloud_server.main.name
}

output "firewall_id" {
  value = hcloud_firewall.main.id
}
