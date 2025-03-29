# Définit les variables locales qui seront utilisées par d'autres modules
# Ces variables sont remplies par les ressources VPC créées explicitement
locals {
  # Variables utilisées par les autres modules
  vpc_id             = aws_vpc.main.id
  private_subnet_ids = aws_subnet.private[*].id
  public_subnet_ids  = aws_subnet.public[*].id
} 