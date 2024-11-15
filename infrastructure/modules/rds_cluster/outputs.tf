output "db_master_password_parameter" {
  value = aws_ssm_parameter.db_master_password
}

output "security_group" {
  value = aws_security_group.db
}

output "this" {
  value = aws_rds_cluster.db
}
