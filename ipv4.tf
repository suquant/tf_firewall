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