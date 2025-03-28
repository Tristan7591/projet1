resource "aws_db_instance" "postgres" {
  identifier           = "digital-store-db"
  engine               = "postgres"
  engine_version       = "15.12"    #version stable
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  multi_az             = false  # Désactivé pour version minimaliste
  storage_encrypted    = true
  storage_type         = "gp3"
  
  # backup_retention_period = 7
  # backup_window        = "03:00-04:00"
  # maintenance_window   = "Mon:04:00-Mon:05:00"
  
  deletion_protection  = false  # Désactivé pour faciliter la suppression
  skip_final_snapshot  = true   # Pas de snapshot final pour faciliter la suppression
  # final_snapshot_identifier = "${var.environment}-digital-store-final-snapshot"
  
  tags = {
    Name        = "digital-store-db"
    Environment = var.environment
    Project     = "digital-store"
  }
}

# Output the RDS endpoint for reference
output "rds_endpoint" {
  description = "The connection endpoint for the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.endpoint
}

# Output the RDS port
output "rds_port" {
  description = "The port the RDS PostgreSQL instance is listening on"
  value       = aws_db_instance.postgres.port
}
