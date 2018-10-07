# Firewall service module for terraform

## Key features

* based on raw iptables

## Interfaces

### Input variables

* count - count of connections
* connections - public ips where applied
* allowed_ipv4_ports - allowed ports (default: ["22/tcp"])
* allowed_ipv6_ports - allowed ports (default: [])
* allowed_ipv4_networks_count
* allowed_ipv4_networks - allowed ipv4 networks (example: ["1.1.1.1/32", "2.2.2.2/32"]) (default: [])
* allowed_ipv4_networks_count
* allowed_ipv4_networks - allowed ipv6 networks (example: ["::/0"]) (default: [])
* extra_chains - extra chains (example: ["DOCKER", "DOCKER-ISOLATION"])

### Output variables

* public_ips - public ips of instances/servers
* allowed_ipv4_ports
* allowed_ipv6_ports
* allowed_ipv4_networks_count
* allowed_ipv4_networks
* allowed_ipv4_networks_count
* allowed_ipv4_networks
* extra_chains


## Example

```
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
  source = "git::https://github.com/suquant/tf_firewall.git?ref=v1.0.1"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"

  allowed_ipv4_networks_count = "${local.allowed_ipv4_networks_count}"
  allowed_ipv4_networks       = ["${local.allowed_ipv4_netowrks}"]
}
```
