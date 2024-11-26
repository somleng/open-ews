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

output "redis_security_group" {
  value = data.terraform_remote_state.somleng_core_infrastructure.outputs.redis_security_group
}

output "elasticache_redis_endpoint" {
  value = data.terraform_remote_state.somleng_core_infrastructure.outputs.elasticache_redis_endpoint
}
