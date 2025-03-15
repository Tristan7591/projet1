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

# Variables nécessaires
variable "environment" {
  description = "Environment name (e.g. dev, staging, production)"
  type        = string
  default     = "production"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "digitalstore"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database (in GB)"
  type        = number
  default     = 20
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "digital-store-cluster"
}

variable "eks_node_group_instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_group_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
  default     = 2
}

variable "eks_node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 4
}

variable "eks_node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 1
}