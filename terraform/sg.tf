############################################
# Groupes de sécurité
############################################

# Groupe de sécurité pour RDS
resource "aws_security_group" "rds_sg" {
  name        = "digital-store-rds-sg"
  description = "Security Group pour RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  # Autorise le trafic PostgreSQL depuis le groupe de sécurité du cluster EKS
  ingress {
    description     = "PostgreSQL access from EKS cluster"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # Autorise le trafic PostgreSQL depuis les groupes de sécurité des nœuds EKS
  ingress {
    description     = "PostgreSQL access from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node.id]
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
    Project     = "digital-store"
  }
}

# Groupe de sécurité pour les nœuds EKS
resource "aws_security_group" "eks_node" {
  name        = "digital-store-eks-node-sg"
  description = "Security Group pour les nœuds EKS"
  vpc_id      = aws_vpc.main.id

  # Autorise tout le trafic entrant depuis le cluster et les autres nœuds
  ingress {
    description     = "Allow node to communicate with each other"
    from_port       = 0
    to_port         = 65535
    protocol        = "-1"
    self            = true
  }

  ingress {
    description     = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # Autorise le trafic sortant vers le cluster EKS, les autres nœuds, et Internet
  egress {
    description     = "Allow all outbound traffic"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "digital-store-eks-node-sg"
    Environment = var.environment
    Project     = "digital-store"
    "kubernetes.io/cluster/digital-store-cluster" = "owned"
  }
}

# Groupe de sécurité pour les pods EKS (utilisé avec VPC CNI)
resource "aws_security_group" "eks_pod" {
  name        = "digital-store-eks-pod-sg"
  description = "Security Group pour les pods EKS"
  vpc_id      = aws_vpc.main.id

  # Aucune règle d'entrée par défaut - gérée par les politiques réseau Kubernetes
  
  # Autorise tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "digital-store-eks-pod-sg"
    Environment = var.environment
    Project     = "digital-store"
  }
}

# Groupe de sécurité pour le cluster EKS
resource "aws_security_group" "eks_cluster" {
  name        = "digital-store-eks-cluster-sg"
  description = "Security Group pour le plan de contrôle EKS"
  vpc_id      = aws_vpc.main.id

  # Autorise le trafic API Server depuis les nœuds et Internet (pour kubectl)
  ingress {
    description     = "Allow pods to communicate with the cluster API Server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node.id]
  }
  
  ingress {
    description     = "Allow admin to communicate with the cluster API Server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  # Idéalement remplacer par des plages plus restrictives
  }

  # Autorise tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "digital-store-eks-cluster-sg"
    Environment = var.environment
    Project     = "digital-store"
  }
}