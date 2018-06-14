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