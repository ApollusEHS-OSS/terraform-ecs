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

resource "aws_ecs_service" "kong" {
  name                = "${var.app_name}"
  launch_type         = "EC2"
  cluster             = "${aws_ecs_cluster.main.id}"
  task_definition     = "${aws_ecs_task_definition.kong.arn}"
  desired_count       = "${var.ecs_service_desired_count}"
  scheduling_strategy = "DAEMON"

  load_balancer {
    target_group_arn  = "${aws_alb_target_group.main.id}"
    container_name    = "${var.app_name}"
    container_port    = "${var.kong_port_http}"
  }

  network_configuration {
    subnets             = ["${module.vpc.private_subnets}"]
    assign_public_ip    = false
    security_groups     = ["${aws_security_group.ecs_service_kong.id}"]
  }
  depends_on = [
    "aws_alb.main"
  ]
}

resource "aws_ecs_task_definition" "kong" {
  family                = "${var.app_name}"
  task_role_arn         = "${module.ecs_task_iam.arn}"
  network_mode          = "awsvpc"
  container_definitions = <<EOF
[
  {
    "name": "${var.app_name}",
    "container_name": "${var.app_name}",
    "image": "${var.app_image}",
    "memoryReservation": ${var.container_memory_reservation},
    "portMappings": [
      {
        "ContainerPort": ${var.kong_port_http},
        "Protocol": "tcp"
      },
      {
        "ContainerPort": ${var.kong_port_https},
        "Protocol": "tcp"
      },
      {
        "ContainerPort": ${var.kong_port_admin},
        "Protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name"  : "KONG_ADMIN_LISTEN",
        "value" : "0.0.0.0:${var.kong_port_admin}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_USERNAME",
        "value" : "${local.ssm_parameter_name_db_username}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_PASSWORD",
        "value" : "${local.ssm_parameter_name_db_password}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_ENGINE",
        "value" : "${local.ssm_parameter_name_db_engine}"
      },
      {
        "name"  : "SSM_PARAMETER_NAME_DB_HOST",
        "value" : "${local.ssm_parameter_name_db_host}"
      }
    ]
  }
]
EOF
}