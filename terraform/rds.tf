resource "aws_db_instance" "postgres" {
  identifier          = "my-postgres-db"
  engine              = "postgres"
  engine_version      = "14.7"
  instance_class      = var.db_instance_class
  allocated_storage   = 20
  db_name                = var.db_name
  username            = var.db_username
  password            = var.db_password
  db_subnet_group_name         = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids        = [aws_security_group.rds_sg.id]
  skip_final_snapshot           = true
  deletion_protection           = false
  multi_az                      = false
  publicly_accessible           = false
  storage_encrypted             = true
  backup_retention_period       = 7
  auto_minor_version_upgrade    = true
}