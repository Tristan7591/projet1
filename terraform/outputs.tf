output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_ca" {
  description = "Certificat CA du cluster EKS"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "rds_endpoint" {
  description = "Endpoint de la base PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "ecr_backend_repository_url" {
  description = "The URL of the backend repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "The URL of the frontend repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "certificate_validation_instructions" {
  description = "Instructions for validating the certificate"
  value       = "Si vous configurez HTTPS ultérieurement, validez le certificat en ajoutant les enregistrements DNS nécessaires"
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.postgres.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.postgres.db_name
}