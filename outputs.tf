output "public_ips" {
  value = "${var.connections}"

  depends_on = ["null_resource.firewall"]
}

output "allowed_ipv4_ports" {
  value = "${var.allowed_ipv4_ports}"

  depends_on = ["null_resource.firewall"]
}

output "allowed_ipv6_ports" {
  value = "${var.allowed_ipv6_ports}"

  depends_on = ["null_resource.firewall"]
}

output "allowed_ipv4_networks_count" {
  value = "${var.allowed_ipv4_networks_count}"

  depends_on = ["null_resource.firewall"]
}

output "allowed_ipv4_networks" {
  value = "${var.allowed_ipv4_networks}"

  depends_on = ["null_resource.firewall"]
}

output "allowed_ipv6_networks_count" {
  value = "${var.allowed_ipv6_networks_count}"

  depends_on = ["null_resource.firewall"]
}

output "allowed_ipv6_networks" {
  value = "${var.allowed_ipv6_networks}"

  depends_on = ["null_resource.firewall"]
}

output "extra_chains" {
  value = "${var.extra_chains}"

  depends_on = ["null_resource.firewall"]
}