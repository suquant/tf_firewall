variable "token" {}
variable "hosts" {
  default = 2
}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = "git::https://github.com/suquant/tf_hcloud.git?ref=v1.1.0"

  count = "${var.hosts}"
}

locals {
  allowed_static_networks     = ["192.168.0.0/16"]
  allowed_ipv4_networks_count = "${var.hosts + length(local.allowed_static_networks)}"
  allowed_ipv4_netowrks       = ["${concat(module.provider.public_ips, local.allowed_static_networks)}"]
}

module "firewall" {
  source = ".."

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"

  allowed_ipv4_networks_count = "${local.allowed_ipv4_networks_count}"
  allowed_ipv4_networks       = ["${local.allowed_ipv4_netowrks}"]
}