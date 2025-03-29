# Rôle IAM pour le contrôleur ALB Ingress
resource "aws_iam_role" "alb_ingress_controller" {
  name = "digital-store-alb-ingress-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "digital-store"
  }

  override_existing_serviceaccounts = true
  service_account_namespace         = "kube-system"
  service_account_name              = "aws-load-balancer-controller"
  
  # Référencer le nouveau VPC
  vpc_id = aws_vpc.main.id
  
  # Utiliser les sous-réseaux publics pour les ALB
  subnet_mapping = [
    for i, subnet in aws_subnet.public : {
      subnet_id     = subnet.id
      allocation_id = aws_eip.nat[i].id
    }
  ]
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # À remplacer par une politique plus restrictive en production
  role       = aws_iam_role.alb_ingress_controller.name
}

# Installation du contrôleur ALB via Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress_controller.arn
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.alb_ingress_controller_policy
  ]
}

# Data pour récupérer l'ID du compte AWS
data "aws_caller_identity" "current" {} 