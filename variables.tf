variable "region" {
  default     = "eu-west-2"                                        # london
  description = "the AWS region in which to create the VPN server"
}

variable "wg_server_private_key" {
  description = "the PRIVATE key of the SERVER in BASE64 format (default)"
}

variable "wg_server_public_key" {
  description = "the PUBLIC key of the SERVER in BASE64 format (default)"
}

variable "wg_client_public_key" {
  description = "the PUBLIC key of the CLIENT in BASE64 format (default)"
}

variable "wg_client_private_key" {
  description = "the PRIVATE key of the CLIENT in BASE64 format (default)"
}

# you should not need to change this

variable "listen_port" {
  default     = "51820"
  description = "the port the server listens on"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "the instance type to use"
}

variable "spot_price" {
  default     = "0.4"
  description = "the max. spot price to pay for the instance"
}

variable "vpc_cidr" {
  default     = "172.16.1.0/24"
  description = "the CIDR for the VPC, only change this if it conflicts with one of your networks"
}

variable "link_cidr" {
  default     = "172.16.1.0/24"
  description = "the CIDR for the VPC link, only change this if it conflicts with one of your networks"
}

variable "root_ebs_size" {
  default = 8
}
