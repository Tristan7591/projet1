############################################
# VPC et sous-réseaux
############################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "digital-store-vpc"
    Environment = var.environment
    Project     = "digital-store"
  }
}

# Sous-réseaux publics dans différentes zones de disponibilité
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "digital-store-public-${var.availability_zones[count.index]}"
    Environment                                    = var.environment
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/digital-store-cluster" = "shared"
  }
}

# Sous-réseaux privés dans différentes zones de disponibilité
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                           = "digital-store-private-${var.availability_zones[count.index]}"
    Environment                                    = var.environment
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/digital-store-cluster" = "shared"
  }
}

############################################
# Internet Gateway et NAT Gateway
############################################

# Internet Gateway pour permettre l'accès Internet aux sous-réseaux publics
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "digital-store-igw"
    Environment = var.environment
  }
}

# Elastic IP pour NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "digital-store-eip-${count.index}"
    Environment = var.environment
  }
}

# NAT Gateway dans les sous-réseaux publics pour l'accès Internet depuis les sous-réseaux privés
resource "aws_nat_gateway" "nat" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "digital-store-nat-${count.index}"
    Environment = var.environment
  }
}

############################################
# Tables de routage
############################################

# Table de routage pour les sous-réseaux publics
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "digital-store-rt-public"
    Environment = var.environment
  }
}

# Table de routage pour les sous-réseaux privés, une pour chaque AZ
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name        = "digital-store-rt-private-${count.index}"
    Environment = var.environment
  }
}

############################################
# Associations de tables de routage
############################################

# Association des tables de routage aux sous-réseaux publics
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Association des tables de routage aux sous-réseaux privés
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Outputs for subnets
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
} 