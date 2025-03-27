# Projet Digital Store - Infrastructure DevOps

## Description
Ce projet met en place une infrastructure cloud complète pour une application de commerce électronique (Digital Store) en utilisant les meilleures pratiques DevOps. L'infrastructure est entièrement automatisée via Terraform et gère le déploiement continu via GitHub Actions.

## Architecture
- **Infrastructure AWS** :
  - Cluster EKS pour l'orchestration Kubernetes
  - RDS PostgreSQL pour la base de données
  - ECR pour le stockage des images Docker
  - ALB (Application Load Balancer) pour le routage du trafic
  - VPC avec sous-réseaux publics et privés

- **Technologies** :
  - Terraform pour l'Infrastructure as Code
  - Kubernetes pour l'orchestration des conteneurs
  - Helm pour la gestion des packages Kubernetes
  - GitHub Actions pour le CI/CD
  - Docker pour la conteneurisation

## Structure du Projet
```
.
├── terraform/                 # Configuration Terraform
│   ├── templates/            # Templates Kubernetes
│   ├── chart/               # Chart Helm
│   └── k8s/                 # Manifests Kubernetes générés
├── .github/                  # Configuration GitHub Actions
└── docs/                     # Documentation
```

## Prérequis
- AWS CLI configuré
- Terraform >= 1.0
- kubectl
- helm
- docker

## Déploiement
1. Cloner le repository :
```bash
git clone https://github.com/Tristan7591/projet1.git
cd projet1
```

2. Configurer les variables d'environnement :
```bash
export AWS_ACCESS_KEY_ID="votre_access_key"
export AWS_SECRET_ACCESS_KEY="votre_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
export TF_VAR_db_password="votre_mot_de_passe"
```

3. Déployer l'infrastructure :
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

4. Vérifier le déploiement :
```bash
kubectl get nodes
kubectl get pods -n default
```

## Accès à l'Application
1. Récupérer l'URL de l'ALB :
```bash
kubectl get ingress -n default
```

2. Accéder à l'application :
- Frontend : http://<ALB_HOSTNAME>/
- Backend API : http://<ALB_HOSTNAME>/api

## Monitoring et Maintenance
- Les logs sont disponibles via CloudWatch
- Les métriques sont collectées via Prometheus/Grafana
- Les alertes sont configurées pour les événements critiques

## Sécurité
- Les secrets sont gérés via AWS Secrets Manager
- Les communications sont sécurisées via TLS (à configurer)
- Les groupes de sécurité sont configurés pour limiter l'accès

## Contribution
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Licence
Ce projet est sous licence MIT.
