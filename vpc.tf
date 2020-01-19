# VPC

variable "app_name" {
    default = "Kong"
}
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
#  type = list(string)
}

variable "private_subnet_cidrs" {
#  type = list(string)
}

variable "availability_zones" {
#  type = "string"
}
module "vpc" {
  source                    = "modules/vpc"
  cidr                      = "${var.vpc_cidr}"
  environment               = "${var.environment}"

}