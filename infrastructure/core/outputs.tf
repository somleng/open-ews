output "app_ecr_repository" {
  value = module.app_ecr_repository
}

output "webserver_ecr_repository" {
  value = module.webserver_ecr_repository
}

output "route53_zone" {
  value = aws_route53_zone.this
}

output "rds_cluster" {
  value     = module.rds_cluster
  sensitive = true
}
