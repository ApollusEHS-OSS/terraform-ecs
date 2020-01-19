# ECS cluster

#variable "vpc_cidr" {}
variable "environment" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "instance_type" {}
variable "ecs_aws_ami" {}



module "ecs" {
  source = "./modules/ecs"

  environment          = "${var.environment}"
  cluster              = "${var.environment}"
  cloudwatch_prefix    = "${var.environment}"           #See ecs_instances module when to set this and when not!
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnet_cidrs  = "${var.public_subnet_cidrs}"
  private_subnet_cidrs = "${var.private_subnet_cidrs}"
  availability_zones   = "${var.availability_zones}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  key_name             = "${aws_key_pair.ecs.key_name}"
  instance_type        = "${var.instance_type}"
  ecs_aws_ami          = "${var.ecs_aws_ami}"
}

resource "aws_key_pair" "ecs" {
  key_name   = "ecs-key-${var.environment}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAorjPQ7947Dgvpj0oOsN2q+XNUiABvYPsEKMPAxCbcwHwH9XdGFxdGL0BXEVmErP9H2gBvZ8vv29XradKVkneY2+BR7bnPLNHkqvm0XH2t4Tx+mmAHWXGnZwCdcPCXQPO1UO9Gzrn7OS1zJ8D8AKwM5OUXg6TPTQ/uoPenxPcRgzjaLkkC8tkhLgxOZRl2hRkR9IO8xWeihtafuVSftVUd9MxDEc7jwQ9I+4JoNL6FIbZzUDqdYFgCfA9lw1JPYPfmo9IilJ7d6k+3h3ycER8FbB+/NwBvIOP30QtKx2+pWtpGcxglq4GEhlJMNCTIGtoxEDN4fxziLkZla40ZijX robert@Roberts-MacBook-Pro.local"
}

output "default_alb_target_group" {
  value = "${module.ecs.default_alb_target_group}"
}
