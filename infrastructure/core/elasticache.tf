data "aws_security_group" "redis" {
  name = var.redis_security_group_name
}

data "aws_elasticache_cluster" "redis" {
  cluster_id = var.redis_cluster_id
}
