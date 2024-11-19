resource "aws_security_group" "db" {
  name   = "scfm"
  vpc_id = var.region.vpc.vpc_id

  ingress {
    from_port = var.db_port
    to_port   = var.db_port
    protocol  = "TCP"
    self      = true
  }

  tags = {
    Name = "aurora-${var.identifier}"
  }
}

resource "aws_ssm_parameter" "db_master_password" {
  name  = "scfm.db_master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_db_subnet_group" "db" {
  name        = var.identifier
  description = "For Aurora cluster ${var.identifier}"
  subnet_ids  = var.region.vpc.database_subnets

  tags = {
    Name = "aurora-${var.identifier}"
  }
}

resource "aws_rds_cluster" "db" {
  cluster_identifier               = var.identifier
  engine                           = "aurora-postgresql"
  engine_mode                      = "provisioned"
  engine_version                   = "16.1"
  allow_major_version_upgrade      = true
  db_instance_parameter_group_name = "aurora-postgresql15"
  master_username                  = "somleng"
  master_password                  = aws_ssm_parameter.db_master_password.value
  vpc_security_group_ids           = [aws_security_group.db.id]
  skip_final_snapshot              = true
  storage_encrypted                = true
  enabled_cloudwatch_logs_exports  = ["postgresql"]

  serverlessv2_scaling_configuration {
    max_capacity = 64
    min_capacity = 0.5
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_rds_cluster_instance" "db" {
  identifier         = var.identifier
  cluster_identifier = aws_rds_cluster.db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db.engine
  engine_version     = aws_rds_cluster.db.engine_version
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/rds/cluster/${var.identifier}/postgresql"
  retention_in_days = 7
}
