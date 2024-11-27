resource "aws_elasticache_subnet_group" "redis" {
  name       = "open-ews-redis"
  subnet_ids = local.region.vpc.database_subnets
}

resource "aws_security_group" "redis" {
  name   = "open-ews-redis"
  vpc_id = local.region.vpc.vpc_id

  ingress {
    from_port = "6379"
    to_port   = "6379"
    protocol  = "TCP"
    self      = true
  }

  tags = {
    Name = "open-ews-redis"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id                 = "open-ews-redis"
  engine                     = "redis"
  node_type                  = "cache.t4g.micro"
  num_cache_nodes            = 1
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  auto_minor_version_upgrade = true
}
