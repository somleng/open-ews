output "ecs_cluster" {
  value = aws_ecs_cluster.this
}

output "app_ecr_repository" {
  value = aws_ecr_repository.app.repository_url
}

output "nginx_ecr_repository" {
  value = aws_ecr_repository.nginx.repository_url
}