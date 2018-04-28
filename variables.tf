variable "region" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "lb_logs_s3_bucket" {}
