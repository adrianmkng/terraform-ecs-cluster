variable "region" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

# variable "lb_logs_s3_bucket" {}

variable "instance_profile" {}

variable "min_instances" {}

variable "max_instances" {}

