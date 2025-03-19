resource "aws_security_group" "rds_sg" {
  name        = "digital-store-rds-sg"
  description = "Security Group pour RDS PostgreSQL"
  vpc_id      = local.vpc_id

  ingress {
    description     = "PostgreSQL port"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "digital-store-rds-sg"
    Environment = var.environment
  }
}