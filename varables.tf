variable "env" {}
variable "project_name" {}
variable "kms_key_id" {}

variable "rds"{}
variable "vpc" {}

# above are common for all the modules below are for each module.

variable "backend_app_port" {}
variable "bastion_cidrs" {}
variable "backend_instance_capacity" {}
variable "backend_instance_type" {}
