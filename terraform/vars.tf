variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}
variable "aws_secret_key" {
  type      = string
  sensitive = true
}

# VPC ID
variable "vpc_id" {
  type    = string
  default = "vpc-xxxxxxxx"
}

# Subnets publics (pour ALB)
variable "public_subnets" {
  type    = list(string)
  default = ["subnet-public1", "subnet-public2"]  # À adapter
}

# Subnets privés (pour EKS + RDS)
variable "private_subnets" {
  type    = list(string)
  default = ["subnet-private1", "subnet-private2"] # À adapter
}

variable "cluster_name" {
  type    = string
  default = "exemple-eks-cluster"
}

# Paramètres RDS PostgreSQL
variable "db_name" {
  type    = string
  default = "mydb"
}
variable "db_username" {
  type    = string
  default = "admin"
}
variable "db_password" {
  type      = string
  default   = "SuperSecretPass123!"
  sensitive = true
}
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}