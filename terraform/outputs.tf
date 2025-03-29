output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_ca" {
  description = "Certificat d'autorité du cluster EKS"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_node_group_arn" {
  description = "ARN du groupe de nœuds EKS"
  value       = aws_eks_node_group.main.arn
}

output "db_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = aws_db_instance.postgres.endpoint
}

output "db_name" {
  description = "Nom de la base de données"
  value       = aws_db_instance.postgres.db_name
}

output "db_username" {
  description = "Nom d'utilisateur de la base de données"
  value       = aws_db_instance.postgres.username
}

output "ecr_backend_repository_url" {
  description = "URL du repository ECR pour le backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL du repository ECR pour le frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "alb_ingress_hostname" {
  description = "Nom d'hôte de l'ALB créé par l'Ingress Controller"
  value       = "digital-store-alb.${aws_eks_cluster.main.name}.${var.aws_region}.elb.amazonaws.com"
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
}

output "rds_endpoint" {
  description = "Endpoint complet de la base de données RDS"
  value       = aws_db_instance.postgres.endpoint
}

output "vpc_id" {
  description = "ID du VPC où sont déployées les ressources"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs des sous-réseaux publics"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs des sous-réseaux privés"
  value       = [for subnet in aws_subnet.private : subnet.id]
}