# Récupération du VPC par défaut
data "aws_vpc" "default" {
  default = true
}

# Récupération de tous les subnets dans ce VPC
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Récupération des détails de chaque subnet
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

# Sélection des subnets pour EKS (au moins 2)
locals {
  # Récupérer tous les IDs de subnets
  all_subnet_ids = data.aws_subnets.all.ids
  
  # Sélectionner 2 subnets aléatoires pour EKS
  eks_subnet_count = min(length(local.all_subnet_ids), 2)
  eks_subnet_ids   = slice(local.all_subnet_ids, 0, local.eks_subnet_count)
  
  # Sélectionner 2 subnets aléatoires pour ALB
  alb_subnet_count = min(length(local.all_subnet_ids), 2)
  alb_subnet_ids   = slice(local.all_subnet_ids, 0, local.alb_subnet_count)
  
  # Variables utilisées par les autres modules
  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = local.eks_subnet_ids
  public_subnet_ids  = local.alb_subnet_ids
} 