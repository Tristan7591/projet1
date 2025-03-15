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