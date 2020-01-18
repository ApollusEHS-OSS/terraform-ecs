variable "aws_default_ami" {}
variable "aws_region" {}
variable "aws_profile_name" {}

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile_name}"
}

terraform {
  backend "s3" {
    bucket = "kong-test-terraform"
    key = "terraform-s3-state-file"
    region = "us-east-1"
  }
}

resource "aws_kms_key" "parameter_store" {
  description             = "Parameter store kms master key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "parameter_store_alias" {
  name          = "alias/parameter_store_key"
  target_key_id = "${aws_kms_key.parameter_store.id}"
}