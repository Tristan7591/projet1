# Digital Store - Architecture Cloud Native

## Vue d'Ensemble
Digital Store est une application e-commerce cloud-native déployée sur AWS EKS en utilisant Terraform et Kubernetes. L'architecture suit les principes DevOps avec un pipeline CI/CD complet pour automatiser le déploiement et les tests.

## Table des Matières

- [Structure du Projet](#structure-du-projet)
- [Architecture Technique](#architecture-technique)
- [Composants](#composants)
- [Déploiement](#déploiement)
- [CI/CD](#ci-cd)
- [Configuration](#configuration)
- [Développement Local](#développement-local)
- [Sécurité](#sécurité)

## Structure du Projet

```
digital-store/
├── application/                 # Code source de l'application
│   ├── src/                     # Code Java Spring Boot
│   ├── frontend/               # Application React
│   ├── pom.xml                 # Configuration Maven
│   └── Dockerfile              # Construction de l'image backend
├── k8s/                        # Manifestes Kubernetes
│   ├── backend/                # Déploiement backend
│   ├── frontend/               # Déploiement frontend
│   ├── ingress/                # Configuration ingress
│   ├── database/
│   │   └── postgres/           # Configuration PostgreSQL
│   └── configmap.yaml          # Configuration de l'application
├── terraform/                  # Infrastructure as Code
│   ├── templates/              # Templates pour la génération de manifestes K8s
│   ├── eks.tf                  # Cluster Kubernetes
│   ├── rds.tf                  # Base de données PostgreSQL
│   ├── ecr.tf                  # Registry pour les images
│   ├── alb.tf                  # Load Balancer & certificats SSL
│   ├── k8s-config.tf           # Génération des configurations K8s
│   └── vars.tf                 # Variables Terraform
└── .github/
    └── workflows/
        └── ci-cd.yml           # Pipeline CI/CD automatisé
```

## Architecture Technique

### Composants Cloud (AWS)

- **EKS** : Cluster Kubernetes managé pour l'orchestration des conteneurs
- **RDS** : Base de données PostgreSQL managée pour la persistance des données
- **ECR** : Registry pour les images Docker
- **ACM** : Certificats SSL pour sécuriser les communications
- **ALB** : Application Load Balancer pour l'ingress HTTPS

### Automatisation de l'Infrastructure

L'infrastructure est entièrement définie en code (IaC) avec Terraform. Les ressources AWS et les manifestes Kubernetes sont générés automatiquement, garantissant une cohérence entre les environnements.

**Fonctionnalités clés:**
- Génération automatique des manifestes Kubernetes à partir de templates Terraform
- Provisionnement du cluster EKS, RDS et autres ressources AWS
- Gestion des secrets et des configurations
- Intégration avec le pipeline CI/CD

## Composants

### Backend

- **Framework**: Spring Boot 3.2.3
- **Java**: Version 17
- **Persistence**: JPA/Hibernate avec PostgreSQL
- **Migration**: Flyway
- **API**: RESTful avec documentation
- **Monitoring**: Spring Actuator

### Frontend

- **Framework**: React 18
- **HTTP Client**: Axios
- **Serveur Web**: Nginx optimisé
- **UI**: Interface responsive
- **Routing**: Single Page Application

## Déploiement

Le déploiement est entièrement automatisé via le pipeline CI/CD et Terraform.

### Prérequis

- AWS CLI configuré
- Terraform ≥ 1.0.0
- kubectl
- Docker

### Déploiement Manuel (si nécessaire)

```bash
# Configurer les variables Terraform
cat > terraform/prod.tfvars << EOF
environment        = "production"
vpc_id             = "vpc-xxxxxxx"
private_subnet_ids = ["subnet-xxx", "subnet-yyy"]
public_subnet_ids  = ["subnet-aaa", "subnet-bbb"]
domain_name        = "your-domain.com"
db_username        = "postgres"
db_password        = "securepassword"
EOF

# Déployer l'infrastructure
cd terraform
terraform init
terraform apply -var-file=prod.tfvars

# Configurer kubectl
aws eks update-kubeconfig --name digital-store-cluster --region us-east-1
```

## CI/CD

Le pipeline CI/CD est configuré avec GitHub Actions et comprend les étapes suivantes:

1. **Validation**: Vérification des fichiers de configuration
2. **Tests**: Tests unitaires et d'intégration
3. **Sécurité**: 
   - Analyse des dépendances (OWASP)
   - Scan des images Docker (Trivy)
4. **Build**: Construction et publication des images Docker vers ECR
5. **Infrastructure**: Déploiement de l'infrastructure avec Terraform
6. **Déploiement**: Application des manifestes Kubernetes générés

## Configuration

### Variables Terraform Requises

```terraform
# Créer le fichier terraform/prod.tfvars
environment        = "production"    # Environnement (production, staging, etc.)
vpc_id             = "vpc-xxxxxx"    # ID du VPC existant
private_subnet_ids = ["subnet-xxx"]  # Sous-réseaux privés pour EKS
public_subnet_ids  = ["subnet-yyy"]  # Sous-réseaux publics pour ALB
domain_name        = "example.com"   # Domaine pour le certificat SSL
region             = "us-east-1"     # Région AWS
db_username        = "postgres"      # Utilisateur PostgreSQL 
db_password        = "password"      # Mot de passe PostgreSQL (utiliser un secret manager en production)
```

### Secrets GitHub

Pour le pipeline CI/CD, configurez les secrets suivants dans les paramètres du repository GitHub:

- `AWS_ACCESS_KEY_ID`: Clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY`: Clé secrète AWS
- `TF_API_TOKEN`: Token Terraform Cloud (optionnel)

## Développement Local

### Backend

```bash
cd application
mvn spring-boot:run
```

### Frontend

```bash
cd application/frontend
npm install
npm start
```

## Sécurité

### Mesures Implémentées

- **Transport**: HTTPS forcé via ALB avec TLS 1.2+
- **Secrets**: Gestion des credentials via Kubernetes Secrets
- **IAM**: Principe du moindre privilège pour les rôles et politiques
- **Réseau**: Security Groups restrictifs
- **Images**: Scan automatique des vulnérabilités avec Trivy
- **Dépendances**: Analyse OWASP des dépendances

## Maintenance

### Mise à jour de l'Application

Pour mettre à jour l'application, il suffit de pousser les modifications sur la branche principale:

```bash
git add .
git commit -m "feat: ajout de nouvelles fonctionnalités"
git push origin main
```

Le pipeline CI/CD se chargera automatiquement du reste.

### Monitoring et Logs

- Métriques d'application exposées via Spring Actuator
- Logs centralisés via CloudWatch
- Statut des déploiements via kubectl 
