module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.25"

  # Contrôleur EKS : peut être public (par défaut) ou privé
  # selon votre besoin. Ici, on suppose un contrôle public
  # avec restriction d'IP, ou paramétrage approprié.
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets
  enable_irsa     = true

  # Node groups dans les subnets privés
  manage_node_groups = true
  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 2
      instance_types   = ["t3.medium"]
      subnets          = var.private_subnets
    }
  }
}