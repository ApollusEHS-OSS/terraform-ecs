# VPC

variable "app_name" {
    default = "Kong"
}
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
}

variable "private_subnet_cidrs" {
}

module "vpc" {
  source                    = "modules/vpc"

  name                      = "${var.app_name} VPC"
  cidr                      = "${var.vpc_cidr}"
  map_public_ip_on_launch   = false

  azs                       = "${data.aws_availability_zones.available.names}"
  private_subnets           = [$var.private_subnet_cidrs]
  public_subnets            = [${var.public_subnet_cidrs}]

  enable_nat_gateway        = true
  single_nat_gateway        = false
  one_nat_gateway_per_az    = true
  enable_vpn_gateway        = false
  enable_dns_support        = true
  enable_dns_hostnames      = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}