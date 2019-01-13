provider "aws" {
  region = "${var.region}"
}

provider "random" {}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  net_bitmask           = "${element(split("/", var.link_cidr), 1)}"
  server_link_ipaddress = "${cidrhost(var.link_cidr, 1)}"
  client_link_ipaddress = "${cidrhost(var.link_cidr, 2)}"
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/resources/cloud-config-aws.sh")}"

  vars {
    WG_PKEY               = "${var.wg_server_private_key}"
    SERVER_LINK_IPADDRESS = "${local.server_link_ipaddress}"
    LINK_NETMASK          = "${local.net_bitmask}"
    NET_PORT              = "${var.listen_port}"
    PEER_ALLOWED_IPS      = "${local.client_link_ipaddress}"
    PEER_KEY              = "${var.wg_client_public_key}"
  }
}

data "template_file" "client_config" {
  template = "${file("${path.module}/resources/client-config.conf")}"

  vars {
    WG_CLIENT_PRIVATE_KEY = "${var.wg_client_private_key}"
    WG_SERVER_PUBLIC_KEY  = "${var.wg_server_public_key}"
    WG_CLIENT_ALLOWED_IPS = "${var.client_allowed_ips}"
    CLIENT_LINK_IPADDRESS = "${local.client_link_ipaddress}"
    LINK_NETMASK          = "${local.net_bitmask}"
    SERVER_IP             = "${aws_spot_instance_request.instance.public_ip}"
    SERVER_PORT           = "${var.listen_port}"
  }
}

# start here :)

resource "random_string" "id" {
  length  = 5
  special = false
  number  = false
  upper   = false
}

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key" {
  key_name   = "wireguard-quickvpn-${random_string.id.result}"
  public_key = "${tls_private_key.sshkey.public_key_openssh}"
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wireguard-quickvpn-${random_string.id.result}"
  cidr = "${var.vpc_cidr}"

  azs            = ["${data.aws_availability_zones.available.names[0]}"]
  public_subnets = ["${var.vpc_cidr}"]

  tags = {
    VPN = "wireguard"
  }
}

resource "aws_spot_instance_request" "instance" {
  availability_zone      = "${"${data.aws_availability_zones.available.names[0]}"}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  user_data              = "${data.template_file.cloud_config.rendered}"
  vpc_security_group_ids = ["${aws_security_group.secgroup.id}"]
  subnet_id              = "${element(module.vpc.public_subnets,0)}"
  key_name               = "${aws_key_pair.key.key_name}"

  # spot parameters
  spot_price           = "${var.spot_price}"
  wait_for_fulfillment = true
  spot_type            = "one-time"

  root_block_device {
    volume_size = "${var.root_ebs_size}"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags {
    Name = "wireguard-quickvpn-${random_string.id.result}"
  }
}

resource "aws_security_group" "secgroup" {
  name        = "wireguard-quickvpn-${random_string.id.result}"
  description = "Allow wireguard UDP and SSH TCP traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.listen_port}"
    to_port     = "${var.listen_port}"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
