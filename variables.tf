
variable "ssh_key_name" {
  default = "jk_uswest2"
}

# SSM
# variable "ssm_parameter_name_prefix" {
#   description = "prefix (like path) under which to store SSM parameters"
#   default = "/dev/kong"
# }
locals {
  ssm_parameter_name.db_username = "${var.ssm_parameter_name_prefix}/db_username"
  ssm_parameter_name.db_password = "${var.ssm_parameter_name_prefix}/db_password"
  ssm_parameter_name.db_engine = "${var.ssm_parameter_name_prefix}/db_engine"
  ssm_parameter_name.db_host = "${var.ssm_parameter_name_prefix}/db_host"
}
 

variable "bastion_instance_class" {
  default = "t2.micro"
}


