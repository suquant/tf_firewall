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

resource "null_resource" "firewall" {
  count       = "${var.count}"
  depends_on  = ["null_resource.install"]

  triggers {
    count                         = "${var.count}"
    allowed_ipv4_networks_count   = "${var.allowed_ipv4_networks_count}"
    allowed_ipv6_networks_count   = "${var.allowed_ipv6_networks_count}"
    allowed_ipv4_ports            = "${join(",", var.allowed_ipv4_ports)}"
    allowed_ipv6_ports            = "${join(",", var.allowed_ipv6_ports)}"
    extra_chains                  = "${join(",", var.extra_chains)}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    destination = "/etc/sysctl.d/firewall.conf"
    source      = "${path.module}/templates/sysctl.conf"
  }

  # Install packages
  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt install -yq iptables iptables-persistent"
    ]
  }

  # Apply sysctl
  provisioner "remote-exec" {
    inline = [
      "sysctl -p /etc/sysctl.d/firewall.conf"
    ]
  }

  provisioner "file" {
    destination = "/etc/iptables/rules.v4"
    content     = "${element(data.template_file.rules_v4.*.rendered, count.index)}"
  }

  provisioner "file" {
    destination = "/etc/iptables/rules.v6"
    content     = "${element(data.template_file.rules_v6.*.rendered, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "iptables-restore /etc/iptables/rules.v4 && ip6tables-restore /etc/iptables/rules.v6"
    ]
  }
}

data "template_file" "extra_chains" {
  count = "${length(var.extra_chains)}"

  template = ":$${chain} - [0:0]"

  vars {
    chain = "${element(var.extra_chains, count.index)}"
  }
}

data "template_file" "rules_v4" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/rules.v4")}"

  vars {
    extra_chains    = "${join("\n", data.template_file.extra_chains.*.rendered)}"

    before_forward  = "${join("\n", data.template_file.ipv4_before_forward.*.rendered)}"
    before_input    = "${join("\n", data.template_file.ipv4_before_input.*.rendered)}"
    before_output   = "${join("\n", data.template_file.ipv4_before_output.*.rendered)}"
    user_input      = "${join("\n", data.template_file.ipv4_user_input.*.rendered)}"
  }
}

data "template_file" "ipv4_before_forward" {
  count = "${var.allowed_ipv4_networks_count}"

  template = "-A fw-before-forward -s $${src_net} -j ACCEPT"

  vars {
    src_net = "${element(var.allowed_ipv4_networks, count.index)}"
  }
}

data "template_file" "ipv4_before_input" {
  count = "${var.allowed_ipv4_networks_count}"

  template = "-A fw-before-input -s $${src_net} -j ACCEPT"

  vars {
    src_net = "${element(var.allowed_ipv4_networks, count.index)}"
  }
}

data "template_file" "ipv4_before_output" {
  count = "${var.allowed_ipv4_networks_count}"

  template = "-A fw-before-output -d $${dst_net} -j ACCEPT"

  vars {
    dst_net = "${element(var.allowed_ipv4_networks, count.index)}"
  }
}

data "template_file" "ipv4_user_input" {
  count = "${length(var.allowed_ipv4_ports)}"

  template = "-A fw-user-input -p $${proto} -m $${proto} --dport $${port} -j ACCEPT"

  vars {
    port  = "${element(split("/", element(var.allowed_ipv4_ports, count.index)), 0)}"
    proto = "${element(split("/", element(var.allowed_ipv4_ports, count.index)), 1)}"
  }
}

data "template_file" "rules_v6" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/rules.v6")}"

  vars {
    extra_chains    = "${join("\n", data.template_file.extra_chains.*.rendered)}"

    before_forward  = "${join("\n", data.template_file.ipv6_before_forward.*.rendered)}"
    before_input    = "${join("\n", data.template_file.ipv6_before_input.*.rendered)}"
    before_output   = "${join("\n", data.template_file.ipv6_before_output.*.rendered)}"
    user_input      = "${join("\n", data.template_file.ipv6_user_input.*.rendered)}"
  }
}

data "template_file" "ipv6_before_forward" {
  count = "${var.allowed_ipv6_networks_count}"

  template = "-A fw6-before-forward -s $${src_net} -j ACCEPT"

  vars {
    src_net = "${element(var.allowed_ipv6_networks, count.index)}"
  }
}

data "template_file" "ipv6_before_input" {
  count = "${var.allowed_ipv6_networks_count}"

  template = "-A fw6-before-input -s $${src_net} -j ACCEPT"

  vars {
    src_net = "${element(var.allowed_ipv6_networks, count.index)}"
  }
}

data "template_file" "ipv6_before_output" {
  count = "${var.allowed_ipv6_networks_count}"

  template = "-A fw6-before-output -d $${dst_net} -j ACCEPT"

  vars {
    dst_net = "${element(var.allowed_ipv6_networks, count.index)}"
  }
}

data "template_file" "ipv6_user_input" {
  count = "${length(var.allowed_ipv6_ports)}"

  template = "-A fw6-user-input -p $${proto} -m $${proto} --dport $${port} -j ACCEPT"

  vars {
    port  = "${element(split("/", element(var.allowed_ipv6_ports, count.index)), 0)}"
    proto = "${element(split("/", element(var.allowed_ipv6_ports, count.index)), 1)}"
  }
}


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