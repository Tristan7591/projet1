resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  
  tags = {
    Name        = "digital-store-rds-subnet-group"
    Environment = var.environment
    Project     = "digital-store"
  }
}
