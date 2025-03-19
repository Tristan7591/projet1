resource "aws_db_instance" "postgres" {
  identifier           = "digital-store-db"
  engine              = "postgres"
  engine_version      = "14.7"
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  
  multi_az            = true
  storage_encrypted   = true
  storage_type        = "gp3"
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  deletion_protection     = true
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.environment}-digital-store-final-snapshot"
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  
  tags = {
    Name        = "digital-store-db"
    Environment = var.environment
    Project     = "digital-store"
  }
}