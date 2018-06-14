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
