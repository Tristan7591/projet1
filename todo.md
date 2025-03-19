# Liste des Tâches pour Rendre le Système Digital Store Fonctionnel

Ce document liste toutes les étapes nécessaires pour configurer et déployer complètement le système Digital Store.

## 1. Configuration de l'Environnement AWS

- [ ] Créer un compte AWS ou utiliser un compte existant avec les permissions appropriées
- [ ] Créer un utilisateur IAM avec les droits nécessaires pour:
  - EKS, EC2, ECR, IAM, VPC, S3, ALB, RDS
- [ ] Générer et sauvegarder les clés d'accès AWS (`AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY`)
- [ ] Vérifier les quotas de service AWS (instances EC2, EKS clusters, etc.)
- [ ] Installer l'AWS CLI et le configurer (`aws configure`)

## 2. Configuration du VPC et des Sous-Réseaux AWS

- [ ] Créer un VPC ou identifier un VPC existant
- [ ] Créer/Identifier au moins 2 sous-réseaux privés dans différentes zones de disponibilité (pour EKS)
- [ ] Créer/Identifier au moins 2 sous-réseaux publics (pour ALB)
- [ ] Configurer les tables de routage et NAT Gateways pour les sous-réseaux privés
- [ ] Noter l'ID du VPC et des sous-réseaux pour la configuration Terraform

## 3. Configuration du Repository GitHub

- [ ] Fork/Créer le repository GitHub pour le projet
- [ ] Créer les secrets GitHub Actions suivants:
  - `AWS_ACCESS_KEY_ID`: Clé d'accès AWS
  - `AWS_SECRET_ACCESS_KEY`: Clé secrète AWS
  - `TF_API_TOKEN`: Token Terraform Cloud (si applicable)
  - `DOCKERHUB_USERNAME`: Nom d'utilisateur Docker Hub (facultatif)
  - `DOCKERHUB_TOKEN`: Token Docker Hub (facultatif)
- [ ] Configurer les branches protégées si nécessaire

## 3.1 Initialisation du Backend Terraform

- [ ] Créer le bucket S3 pour le backend Terraform:
  ```bash
  aws s3 mb s3://digital-store-terraform-state
  ```

- [ ] Créer la table DynamoDB pour le verrouillage Terraform:
  ```bash
  aws dynamodb create-table \
    --table-name digital-store-terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
  ```

- [ ] Activer le versioning sur le bucket S3:
  ```bash
  aws s3api put-bucket-versioning \
    --bucket digital-store-terraform-state \
    --versioning-configuration Status=Enabled
  ```

- [ ] Configurer le chiffrement par défaut pour le bucket:
  ```bash
  aws s3api put-bucket-encryption \
    --bucket digital-store-terraform-state \
    --server-side-encryption-configuration '{
      "Rules": [
        {
          "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
          }
        }
      ]
    }'
  ```

- [ ] Bloquer l'accès public au bucket:
  ```bash
  aws s3api put-public-access-block \
    --bucket digital-store-terraform-state \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  ```

## 4. Configuration de Terraform

- [ ] Créer le fichier `terraform/terraform.tfvars` avec les valeurs suivantes:
  ```hcl
  environment        = "production"
  vpc_id             = "vpc-xxxxxxx"         # Remplacer par votre VPC ID
  private_subnet_ids = ["subnet-xxx", "subnet-yyy"] # IDs des sous-réseaux privés
  public_subnet_ids  = ["subnet-aaa", "subnet-bbb"] # IDs des sous-réseaux publics
  domain_name        = "your-domain.com"     # Domaine pour les certificats SSL
  region             = "us-east-1"           # Région AWS à utiliser
  db_username        = "postgres"            # Utilisateur PostgreSQL
  db_password        = "securepassword"      # Mot de passe PostgreSQL sécurisé
  ```
- [ ] Configurer le backend Terraform (S3 ou Terraform Cloud)
- [ ] Valider la configuration avec `terraform validate`

## 4.1 Vérification des Permissions AWS

- [ ] Vérifier les permissions IAM minimales requises:
  ```bash
  aws iam get-user
  aws eks describe-cluster --name digital-store-cluster || echo "Permission OK"
  aws s3 ls s3://digital-store-terraform-state || echo "Permission OK"
  aws dynamodb describe-table --table-name digital-store-terraform-lock || echo "Permission OK"
  ```

- [ ] Créer une politique IAM dédiée pour le déploiement:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::digital-store-terraform-state",
          "arn:aws:s3:::digital-store-terraform-state/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource": "arn:aws:dynamodb:*:*:table/digital-store-terraform-lock"
      }
    ]
  }
  ```

- [ ] Attacher la politique à l'utilisateur/rôle de déploiement:
  ```bash
  aws iam put-user-policy \
    --user-name VOTRE_USER \
    --policy-name terraform-state-access \
    --policy-document file://terraform-state-policy.json
  ```

## 4.2 Test de l'Initialisation

- [ ] Tester l'initialisation de Terraform:
  ```bash
  cd terraform
  terraform init
  ```

- [ ] Vérifier l'état du backend:
  ```bash
  terraform state list || echo "État vide, prêt pour le déploiement"
  ```

- [ ] Valider la configuration:
  ```bash
  terraform validate
  terraform plan
  ```

## 5. Configuration des Secrets Kubernetes

- [ ] Créer un fichier temporaire pour les secrets PostgreSQL (ne pas commiter):
  ```yaml
  # k8s/database/postgres/secret.yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: postgres-secret
  type: Opaque
  data:
    username: <BASE64_ENCODED_USERNAME>  # echo -n "postgres" | base64
    password: <BASE64_ENCODED_PASSWORD>  # echo -n "securepassword" | base64
  ```
- [ ] Ou mettre à jour le template Terraform correspondant avec les mêmes valeurs

## 6. Configuration des Images Docker

- [ ] S'assurer que les Dockerfiles sont optimisés (multi-stage build, layers minimaux)
- [ ] Vérifier les configurations des images dans les templates de déploiement:
  - `terraform/templates/backend-deployment.tpl`
  - `terraform/templates/frontend-deployment.tpl`
- [ ] Si nécessaire, créer les repositories ECR manuellement avant le déploiement:
  ```bash
  aws ecr create-repository --repository-name digital-store/backend
  aws ecr create-repository --repository-name digital-store/frontend
  ```

## 7. Déploiement Initial

- [ ] Exécuter le déploiement Terraform manuellement ou via le pipeline CI/CD:
  ```bash
  cd terraform
  terraform init
  terraform plan
  terraform apply -auto-approve
  ```
- [ ] Configurer kubectl pour accéder au cluster:
  ```bash
  aws eks update-kubeconfig --name digital-store-cluster --region <your-region>
  ```
- [ ] Vérifier que les nœuds EKS sont disponibles:
  ```bash
  kubectl get nodes
  ```

## 8. Déploiement des Ressources Kubernetes

- [ ] Appliquer les manifestes Kubernetes manuellement ou via le pipeline CI/CD:
  ```bash
  kubectl apply -f k8s/database/postgres/secret.yaml
  kubectl apply -f k8s/database/postgres/storage.yaml
  kubectl apply -f k8s/database/postgres/deployment.yaml
  kubectl apply -f k8s/database/postgres/service.yaml
  kubectl apply -f k8s/configmap.yaml
  kubectl apply -f k8s/backend/deployment.yaml
  kubectl apply -f k8s/backend/service.yaml
  kubectl apply -f k8s/frontend/deployment.yaml
  kubectl apply -f k8s/frontend/service.yaml
  kubectl apply -f k8s/ingress/ingress.yaml
  ```
- [ ] Vérifier le déploiement des pods:
  ```bash
  kubectl get pods
  ```

## 9. Configuration du DNS et des Certificats SSL

- [ ] Récupérer l'adresse du load balancer:
  ```bash
  kubectl get ingress digital-store-ingress
  ```
- [ ] Configurer le DNS pour pointer vers l'adresse du load balancer
- [ ] Vérifier l'émission et la validation des certificats SSL

## 10. Vérification Finale

- [ ] Suivre les étapes du fichier `verification.md` pour vérifier que tout fonctionne
- [ ] Tester l'accès à l'application via l'URL configurée
- [ ] Vérifier que le CI/CD fonctionne en effectuant un petit changement
- [ ] Valider que les métriques et logs sont correctement collectés

## 11. Documentation et Formation

- [ ] Mettre à jour la documentation avec les URLs et endpoints spécifiques
- [ ] Documenter les procédures de déploiement, rollback et monitoring
- [ ] Former l'équipe sur l'utilisation du système et du pipeline CI/CD

## 12. Sécurité et Conformité

- [ ] Exécuter un scan de sécurité complet (OWASP ZAP, AWS Inspector)
- [ ] Vérifier que tous les secrets sont correctement protégés
- [ ] Activer la rotation automatique des secrets si applicable
- [ ] Configurer des alertes de sécurité et de performance

## 13. Maintenance et Sauvegarde

- [ ] Configurer des sauvegardes automatiques pour la base de données
- [ ] Mettre en place un plan de maintenance et de mise à jour
- [ ] Documenter les procédures de restauration en cas de défaillance

## 14. Configuration du Monitoring

- [ ] Installation de Prometheus et Grafana sur EKS:
  ```bash
  # Ajouter le repo Helm de Prometheus
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

  # Créer le namespace monitoring
  kubectl create namespace monitoring

  # Installer Prometheus
  helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set grafana.adminPassword=your-secure-password \
    --set prometheus.prometheusSpec.retention=15d
  ```

- [ ] Configuration des dashboards Grafana essentiels:
  - Node Exporter Full
  - Kubernetes Cluster
  - PostgreSQL Overview
  - AWS EKS Monitoring
  - Application Performance Metrics

- [ ] Mise en place des alertes:
  ```yaml
  # alerts.yaml
  groups:
  - name: digital-store-alerts
    rules:
    - alert: HighCPUUsage
      expr: avg(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        description: Pod {{ $labels.pod }} CPU usage is above 80%
    
    - alert: HighMemoryUsage
      expr: avg(container_memory_usage_bytes{container!=""}) by (pod) / avg(container_spec_memory_limit_bytes{container!=""}) by (pod) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        description: Pod {{ $labels.pod }} memory usage is above 80%
    
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[1h]) > 3
      for: 10m
      labels:
        severity: critical
      annotations:
        description: Pod {{ $labels.pod }} is crash looping
  ```

- [ ] Configuration CloudWatch:
  - Métriques RDS
  - Métriques EKS
  - Logs d'application
  - Métriques ALB

- [ ] Tableau de bord CloudWatch:
  ```hcl
  resource "aws_cloudwatch_dashboard" "main" {
    dashboard_name = "digital-store-dashboard"
    
    dashboard_body = jsonencode({
      widgets = [
        {
          type = "metric"
          properties = {
            metrics = [
              ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "digital-store-db"],
              ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "digital-store-db"]
            ]
            period = 300
            region = var.region
            title  = "RDS Metrics"
          }
        },
        {
          type = "metric"
          properties = {
            metrics = [
              ["AWS/EKS", "cluster_failed_node_count", "ClusterName", "digital-store-cluster"],
              ["AWS/EKS", "node_cpu_utilization", "ClusterName", "digital-store-cluster"]
            ]
            period = 300
            region = var.region
            title  = "EKS Metrics"
          }
        }
      ]
    })
  }
  ```

## 15. Configuration des Sauvegardes

- [ ] Configuration des sauvegardes RDS:
  ```hcl
  resource "aws_db_instance" "postgres" {
    # ... configuration existante ...
    backup_retention_period = 30
    backup_window          = "03:00-04:00"
    maintenance_window     = "Mon:04:00-Mon:05:00"
    
    copy_tags_to_snapshot = true
    
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
    
    performance_insights_enabled = true
    performance_insights_retention_period = 7
  }
  ```

- [ ] Configuration des snapshots EBS:
  ```hcl
  resource "aws_dlm_lifecycle_policy" "backup_policy" {
    description = "Digital Store backup policy"
    execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
    state     = "ENABLED"
    
    policy_details {
      resource_types = ["VOLUME"]
      
      schedule {
        name = "Daily snapshots"
        
        create_rule {
          interval      = 24
          interval_unit = "HOURS"
          times        = ["23:45"]
        }
        
        retain_rule {
          count = 30
        }
        
        tags_to_add = {
          SnapshotCreator = "DLM"
          Environment     = var.environment
        }
        
        copy_tags = true
      }
      
      target_tags = {
        Backup = "true"
      }
    }
  }
  ```

- [ ] Configuration de Velero pour les sauvegardes Kubernetes:
  ```bash
  # Installation de Velero
  velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.5.0 \
    --bucket digital-store-backup \
    --backup-location-config region=us-east-1 \
    --snapshot-location-config region=us-east-1 \
    --secret-file ./credentials-velero
  
  # Configuration des sauvegardes planifiées
  velero schedule create daily-backup \
    --schedule="@daily" \
    --ttl 720h0m0s
  ```

- [ ] Configuration des rétentions:
  - RDS: 30 jours de sauvegardes
  - EBS: 30 snapshots quotidiens
  - Kubernetes: 30 jours de sauvegardes Velero
  - Logs: 90 jours dans CloudWatch

- [ ] Tests de restauration:
  ```bash
  # Test de restauration RDS
  aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier digital-store-test-restore \
    --db-snapshot-identifier <snapshot-id>
  
  # Test de restauration Velero
  velero restore create --from-backup daily-backup-20240316
  
  # Vérification des restaurations
  kubectl get pods
  aws rds describe-db-instances --db-instance-identifier digital-store-test-restore
  ```

- [ ] Documentation des procédures de restauration:
  - Procédure de restauration complète
  - Procédure de restauration partielle
  - Points de restauration (RPO)
  - Temps de restauration (RTO)
  - Contacts d'urgence 