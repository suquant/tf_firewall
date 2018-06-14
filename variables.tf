variable "count" {}

variable "connections" {
  type = "list"
}

variable "allowed_ipv4_ports" {
  type = "list"
  default = ["22/tcp"]
}

variable "allowed_ipv6_ports" {
  type = "list"
  default = []
}

variable "allowed_ipv4_networks_count" {
  default = 0
}

variable "allowed_ipv4_networks" {
  type = "list"
  default = []
}

variable "allowed_ipv6_networks_count" {
  default = 0
}

variable "allowed_ipv6_networks" {
  type = "list"
  default = []
}

variable "extra_chains" {
  type = "list"
  default = []
}