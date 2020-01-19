# ECS Service & Task Definition

variable "container_memory_reservation" {
  default = 64
}

# SSM
variable "ssm_parameter_name_prefix" {
  description = "prefix (like path) under which to store SSM parameters"
  default = "/dev/kong"
}
locals {
  ssm_parameter_name_db_username = "${var.ssm_parameter_name_prefix}/db_username"
  ssm_parameter_name_db_password = "${var.ssm_parameter_name_prefix}/db_password"
  ssm_parameter_name_db_engine = "${var.ssm_parameter_name_prefix}/db_engine"
  ssm_parameter_name_db_host = "${var.ssm_parameter_name_prefix}/db_host"
}

variable "app_image" {
  default = "rdkls/kong_ssm:latest"
}
variable "ecs_service_desired_count" {
  default = 1
}

variable "kong_port_admin" {
  default = "8001"
}
variable "kong_port_http" {
  default = 8000
}
variable "kong_port_https" {
  default = 8443
}
resource "aws_security_group" "ecs_service_kong" {
  name        = "${var.app_name}-ECS-SG-kong"
  vpc_id      = "${module.vpc.id}"

  ingress = {
    description       = "all from self + alb + bastion + kong dash"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_groups   = [
#      "${module.alb_sg.this_security_group_id}",
#      "${aws_security_group.bastion.id}",
#      "${aws_security_group.ecs_service_kong_dash.id}"
    ]
    self              = true
  }
  egress = {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags  = [
    {
      Name = "${var.app_name}-ECS-SG-kong"
    }
  ]
}

