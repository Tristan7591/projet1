terraform {
  backend "s3" {
    bucket         = "mon-bucket-terraform"   # À adapter
    key            = "infra/eks-rds.tfstate"
    region         = "us-east-1"              # À adapter
    dynamodb_table = "terraform-lock-table"   # À adapter
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}