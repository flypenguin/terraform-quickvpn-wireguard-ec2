output "ssh_private_key" {
  value = "${tls_private_key.sshkey.private_key_pem}"
}

output "ssh_public_key" {
  value = "${tls_private_key.sshkey.public_key_openssh}"
}

output "server_ip" {
  value = "${aws_spot_instance_request.instance.public_ip}"
}

output "client_config" {
  value = "${data.template_file.client_config.rendered}"
}

output "server_public_key" {
  value = "${var.wg_server_public_key}"
}

output "client_private_key" {
  value = "${var.wg_client_private_key}"
}
