resource "null_resource" "install" {
  count   = "${var.count}"

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
}