variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Infrastructure de base - optionnelle, auto-détectée sinon
variable "vpc_id" {
  description = "The ID of the VPC (optionnel, auto-détection du VPC par défaut sinon)"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (optionnel, auto-détection sinon)"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (optionnel, auto-détection sinon)"
  type        = list(string)
  default     = []
}

# Environnement et domaine
variable "environment" {
  description = "Environment name (e.g. dev, staging, production)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Domain name for the application (facultatif pour le déploiement initial)"
  type        = string
  default     = "example.com"  # Valeur par défaut pour éviter l'erreur, ne sera pas utilisée
}

# Configuration EKS
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

# Configuration RDS
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "digitalstore"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database (in GB)"
  type        = number
  default     = 20
}

# Tags communs
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "digital-store"
    ManagedBy   = "terraform"
  }
}