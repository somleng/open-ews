module container_instances {
  source = "../container_instances"

  identifier = var.app_identifier
  vpc = var.vpc
  instance_subnets = var.vpc.private_subnets
  cluster_name = aws_ecs_cluster.this.name
  max_capacity = (var.webserver_max_tasks * 2) + (var.worker_max_tasks * 2)
}
