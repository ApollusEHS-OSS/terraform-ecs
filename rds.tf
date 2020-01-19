# DB variables
variable "db_name" {
  default = "kong"
}
variable "db_username" {
  default = "kong"
}
variable "db_password" {
  default = "blablabla"
}
variable "db_engine" {
  default = "aurora-postgresql"
}
variable "db_engine_version" {
  default = "9.5"
}
variable "db_instance_class" {
  default = "db.t2.micro"
}
variable "db_port" {
  default = 5432
}

# RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-RDS-SG"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    description               = "Postgres access from ECS cluster"
    protocol                  = "tcp"
    from_port                 = "5432"
    to_port                   = "5432"
    security_groups           = ["${aws_security_group.ecs_service_kong.id}"]
  }
  egress = {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = [
    {
      Name    = "${var.app_name}-RDS-SG"
    }
  ]
}
resource "aws_db_parameter_group" "main" {
  name    = "${var.db_engine}"
  family  = "${var.db_engine}${var.db_engine_version}"

  parameter {
    name         = "autovacuum"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

#module "rds_cluster" {
#  source  = "thanhbn87/rds-cluster/aws"
#  version = "0.16.0"
#  name            = "${var.db_name}"
#  engine          = "${var.db_engine}"
#  cluster_family  = "${var.db_engine}${var.db_engine_version}"
#  cluster_size    = "2"
#  namespace       = "eg"
#  stage           = "${var.environment}"
#  admin_user      = "${var.db_username}"
#  admin_password  = "${var.db_password}"
#  db_name         = "${var.db_name}"
#  db_port         = "${var.db_port}"
#  instance_type   = "${var.db_instance_class}"
#  vpc_id          = "${aws_vpc.vpc.id}"
#  security_groups = ["${var.environment}_${var.environment}_${var.instance_group.id}"]
#  subnets         = [${var.private_subnet_cidrs}]
#  zone_id         = "Zxxxxxxxx"
#}
