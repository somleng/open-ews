variable "aws_region" {
  default = "ap-southeast-1"
}

variable "redis_security_group_name" {
  default = "somleng-redis"
}

variable "redis_cluster_id" {
  default = "somleng-redis"
}

locals {
  region = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
}
