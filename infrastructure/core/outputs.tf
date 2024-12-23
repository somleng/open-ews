output "app_ecr_repository" {
  value = module.app_ecr_repository
}

output "route53_zone" {
  value = aws_route53_zone.this
}

output "rds_cluster" {
  value     = module.rds_cluster
  sensitive = true
}

output "elasticache_redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "redis_security_group" {
  value = aws_security_group.redis
}
