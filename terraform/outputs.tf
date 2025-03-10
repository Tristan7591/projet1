output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "Certificat CA du cluster EKS"
  value       = module.eks.cluster_certificate_authority_data
}

output "rds_endpoint" {
  description = "Endpoint de la base PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}