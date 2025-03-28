#!/bin/bash

# This script creates a Kubernetes secret for RDS credentials using Terraform outputs and SSM
# It should be run after Terraform has successfully created the RDS instance

set -e

# Get RDS endpoint and parse it
RDS_ENDPOINT=$(terraform -chdir=terraform output -raw rds_endpoint)
RDS_HOST=$(echo $RDS_ENDPOINT | cut -d':' -f1)
RDS_PORT=$(echo $RDS_ENDPOINT | cut -d':' -f2)

# Get database name and username from Terraform outputs
DB_NAME=$(terraform -chdir=terraform output -raw db_name)
DB_USERNAME=$(terraform -chdir=terraform output -raw db_username)

# Get password directly from SSM Parameter Store
DB_PASSWORD=$(aws ssm get-parameter --name "/terraform/db_password" --with-decryption --query "Parameter.Value" --output text)

# Encode values in base64
DB_NAME_B64=$(echo -n "$DB_NAME" | base64)
DB_USERNAME_B64=$(echo -n "$DB_USERNAME" | base64)
DB_PASSWORD_B64=$(echo -n "$DB_PASSWORD" | base64)
DB_HOST_B64=$(echo -n "$RDS_HOST" | base64)
DB_PORT_B64=$(echo -n "$RDS_PORT" | base64)

# Create/update secret template
cat > k8s/database/rds-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: rds-credentials
  namespace: default
type: Opaque
data:
  DB_NAME: ${DB_NAME_B64}
  DB_USERNAME: ${DB_USERNAME_B64}
  DB_PASSWORD: ${DB_PASSWORD_B64}
  DB_HOST: ${DB_HOST_B64}
  DB_PORT: ${DB_PORT_B64}
EOF

echo "RDS secret template created at k8s/database/rds-secret.yaml"
echo "Ready to be applied to Kubernetes cluster" 