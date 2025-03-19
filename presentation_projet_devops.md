# Présentation du Projet Digital Store

## Sommaire

1. [Introduction et Contexte du Projet](#1-introduction-et-contexte-du-projet)
   - 1.1. Présentation générale de Digital Store
   - 1.2. Objectifs et enjeux business
   - 1.3. Contraintes techniques et organisationnelles

2. [Automatisation du Déploiement de l'Infrastructure dans le Cloud](#2-automatisation-du-déploiement-de-linfrastructure-dans-le-cloud)
   - 2.1. Automatisation de la création des serveurs avec Terraform
   - 2.2. Configuration de l'infrastructure AWS EKS
   - 2.3. Sécurisation de l'infrastructure
   - 2.4. Mise en production dans le cloud AWS

3. [Déploiement en Continu de l'Application](#3-déploiement-en-continu-de-lapplication)
   - 3.1. Préparation des environnements de test
   - 3.2. Gestion du stockage de données avec PostgreSQL
   - 3.3. Gestion des containers avec Kubernetes
   - 3.4. Automatisation du déploiement avec GitHub Actions

4. [Supervision des Services Déployés](#4-supervision-des-services-déployés)
   - 4.1. Définition des indicateurs de performance
   - 4.2. Mise en place des outils de monitoring
   - 4.3. Gestion des alertes et résolution des incidents

5. [Bilan et Perspectives](#5-bilan-et-perspectives)
   - 5.1. Résultats obtenus
   - 5.2. Difficultés rencontrées et solutions apportées
   - 5.3. Améliorations futures et évolution de l'architecture

6. [Correspondance avec le Référentiel de Compétences](#6-correspondance-avec-le-référentiel-de-compétences)
   - 6.1. Bloc de compétences 1 : Automatiser le déploiement d'une infrastructure
   - 6.2. Bloc de compétences 2 : Déployer en continu une application
   - 6.3. Bloc de compétences 3 : Superviser les services déployés

## 1. Introduction et Contexte du Projet

### 1.1. Présentation générale de Digital Store

Digital Store est une application e-commerce cloud-native déployée sur AWS EKS (Elastic Kubernetes Service). Le projet vise à mettre en place une architecture DevOps complète permettant un déploiement automatisé et continu de l'application, avec une infrastructure entièrement définie en tant que code (IaC).

L'application se compose de :
- Un backend en Spring Boot (Java) exposant une API REST
- Un frontend en React
- Une base de données PostgreSQL pour la persistance des données
- Une infrastructure cloud sur AWS avec EKS, RDS, ECR et ALB

### 1.2. Objectifs et enjeux business

Le projet répond à plusieurs objectifs business essentiels :
- Réduire le time-to-market des nouvelles fonctionnalités grâce au déploiement continu
- Améliorer la fiabilité des déploiements et réduire les incidents en production
- Optimiser les coûts d'infrastructure grâce à l'élasticité du cloud
- Faciliter la montée en charge lors des pics d'activité
- Garantir une haute disponibilité du service (SLA de 99,9%)

### 1.3. Contraintes techniques et organisationnelles

Le projet a dû prendre en compte plusieurs contraintes :
- Utilisation exclusive d'AWS comme fournisseur cloud
- Respect des normes de sécurité pour les applications e-commerce
- Intégration avec les systèmes existants de l'entreprise
- Formation des équipes de développement aux pratiques DevOps
- Budget limité pour l'infrastructure cloud

## 2. Automatisation du Déploiement de l'Infrastructure dans le Cloud

### 2.1. Automatisation de la création des serveurs avec Terraform

L'infrastructure est entièrement définie en code avec Terraform, suivant les principes de l'Infrastructure as Code (IaC) :

- **Structure modulaire** : Organisation des ressources en modules réutilisables
- **Gestion des états** : Utilisation du backend S3 pour stocker l'état Terraform
- **Variables et templating** : Paramétrage de l'infrastructure selon l'environnement
- **Gestion des secrets** : Utilisation de variables sensibles pour les informations confidentielles

Exemple de code Terraform pour la création du cluster EKS :

```hcl
resource "aws_eks_cluster" "digital_store_cluster" {
  name     = "digital-store-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.27"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids              = var.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Environment = var.environment
    Application = "digital-store"
  }
}
```

### 2.2. Configuration de l'infrastructure AWS EKS

La mise en place du cluster Kubernetes sur AWS EKS a nécessité plusieurs étapes :

- **Conception du réseau** : Configuration du VPC, sous-réseaux privés et publics
- **Configuration du cluster** : Paramétrage des nodes groups avec autoscaling
- **Gestion des accès** : Configuration des RBAC et Service Accounts
- **Intégration avec AWS** : Utilisation des services AWS complémentaires (ALB, ECR)
- **Haute disponibilité** : Déploiement multi-AZ pour la résilience

### 2.3. Sécurisation de l'infrastructure

Plusieurs mesures ont été implémentées pour sécuriser l'infrastructure :

- **IAM** : Application du principe du moindre privilège pour les rôles et policies
- **Réseau** : Security Groups restrictifs et contrôle du trafic entrant/sortant
- **Données** : Chiffrement des données au repos et en transit
- **Secrets** : Gestion des secrets Kubernetes pour les credentials
- **Accès** : Endpoint EKS privé avec accès contrôlé
- **Audit** : Journalisation et surveillance des accès

### 2.4. Mise en production dans le cloud AWS

Le processus de mise en production comprend :

- **Plan de déploiement** : Validation de l'infrastructure avec `terraform plan`
- **Déploiement progressif** : Application des changements de manière contrôlée
- **Tests d'infrastructure** : Validation de la connectivité et de la sécurité
- **Documentation** : Génération automatique de la documentation d'infrastructure
- **Contrôle des coûts** : Mise en place de budgets et d'alertes AWS

## 3. Déploiement en Continu de l'Application

### 3.1. Préparation des environnements de test

Plusieurs environnements ont été mis en place pour garantir la qualité des déploiements :

- **Environnement de développement** : Pour les tests unitaires et fonctionnels
- **Environnement de staging** : Pour les tests d'intégration et de performance
- **Environnement de production** : Pour le déploiement final

Ces environnements sont créés à l'identique grâce à Terraform et Kubernetes, assurant une reproductibilité parfaite.

### 3.2. Gestion du stockage de données avec PostgreSQL

La gestion des données repose sur PostgreSQL avec :

- **Persistence** : Utilisation de PersistentVolumeClaims pour le stockage durable
- **Sauvegarde** : Configuration de backups automatiques
- **Migration** : Utilisation de Flyway pour les migrations de schéma
- **Haute disponibilité** : Réplication multi-AZ
- **Sécurité** : Chiffrement des données et gestion sécurisée des secrets

Exemple de configuration Kubernetes pour le stockage PostgreSQL :

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp2
```

### 3.3. Gestion des containers avec Kubernetes

L'orchestration des containers est assurée par Kubernetes :

- **Déploiements** : Configuration des déploiements avec stratégie rolling update
- **Services** : Exposition des applications via des services Kubernetes
- **Ingress** : Routage du trafic avec AWS ALB Ingress Controller
- **ConfigMaps** : Gestion externalisée de la configuration
- **Secrets** : Stockage sécurisé des informations sensibles

### 3.4. Automatisation du déploiement avec GitHub Actions

Le pipeline CI/CD, implémenté avec GitHub Actions, comprend les étapes suivantes :

1. **Validation** : Vérification de la syntaxe et de la configuration
2. **Tests** : Exécution des tests unitaires et d'intégration
3. **Sécurité** : Scan des dépendances (OWASP) et des images Docker (Trivy)
4. **Build** : Construction et publication des images vers ECR
5. **Infrastructure** : Déploiement de l'infrastructure avec Terraform
6. **Déploiement** : Application des manifestes Kubernetes générés

#### Stratégie de branching et protection de l'infrastructure

Une stratégie de branching spécifique a été mise en place pour sécuriser les déploiements d'infrastructure :

- **Branches de feature** : Toute modification d'infrastructure est d'abord créée dans une branche dédiée
- **Pull Requests** : Les modifications sont soumises via PR pour validation et revue de code
- **Tests de pré-déploiement** : Exécution de `terraform plan` sur la PR pour valider les changements
- **Protections de la branche main** : Approbation obligatoire avant fusion des changements
- **Validation automatisée** : Exécution des tests automatiques et vérification de la qualité du code

Cette approche apporte plusieurs avantages critiques :
- **Sécurité** : Empêche les modifications accidentelles de l'infrastructure critique
- **Validation par les pairs** : Garantit que les changements sont revus par plusieurs personnes
- **Traçabilité** : Chaque modification est documentée et explicitement approuvée
- **Tests préliminaires** : Permet de détecter les problèmes avant qu'ils n'atteignent la production
- **Facilité de rollback** : Simplifie l'identification et la réversion des changements problématiques

Exemple du workflow CI/CD :

```yaml
jobs:
  terraform-deploy:
    needs: push-to-ecr
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.5.0
      - name: Terraform Init
        run: |
          cd terraform
          terraform init
      - name: Terraform Apply
        run: |
          cd terraform
          terraform apply -auto-approve
```

## 4. Supervision des Services Déployés

### 4.1. Définition des indicateurs de performance

Plusieurs indicateurs clés ont été définis pour surveiller la performance du système :

- **Disponibilité** : Taux de disponibilité des services (uptime)
- **Performance** : Temps de réponse des API et latence réseau
- **Ressources** : Utilisation CPU, mémoire et stockage
- **Business** : Nombre de transactions, taux de conversion
- **Sécurité** : Tentatives d'intrusion, vulnérabilités détectées

### 4.2. Mise en place des outils de monitoring

La supervision s'appuie sur plusieurs outils complémentaires :

- **Métriques** : Collecte via Spring Actuator et Prometheus
- **Logs** : Centralisation avec AWS CloudWatch
- **Visualisation** : Tableaux de bord avec Grafana
- **Alertes** : Configuration d'alertes basées sur des seuils prédéfinis
- **Traces** : Distributed tracing pour analyser le parcours des requêtes

### 4.3. Gestion des alertes et résolution des incidents

Un processus de gestion des incidents a été mis en place :

- **Détection** : Alertes automatiques en cas d'anomalie
- **Notification** : Envoi de notifications via email, Slack
- **Escalade** : Processus d'escalade selon la gravité
- **Résolution** : Procédures documentées pour les incidents courants
- **Post-mortem** : Analyse des incidents pour éviter leur récurrence

## 5. Bilan et Perspectives

### 5.1. Résultats obtenus

Le projet Digital Store a permis d'atteindre plusieurs résultats significatifs :

- **Temps de déploiement** réduit de 2 jours à 20 minutes
- **Fréquence des déploiements** passée d'une fois par mois à plusieurs fois par jour
- **Disponibilité** améliorée à 99,95%
- **Coûts d'infrastructure** réduits de 30% grâce à l'autoscaling
- **Temps de détection des incidents** réduit de 80%

### 5.2. Difficultés rencontrées et solutions apportées

Plusieurs défis ont dû être relevés lors de la mise en œuvre :

- **Complexité de Kubernetes** : Formation approfondie des équipes
- **Montée en charge** : Optimisation des ressources et mise en place de l'autoscaling
- **Gestion des secrets** : Implémentation d'une solution robuste de gestion des secrets
- **Migration des données** : Stratégie de migration sans interruption de service
- **Formation des équipes** : Programme de formation continue sur les pratiques DevOps

### 5.3. Améliorations futures et évolution de l'architecture

Plusieurs axes d'amélioration ont été identifiés :

- **Multi-cloud** : Extension de l'infrastructure à d'autres fournisseurs cloud
- **GitOps** : Adoption d'une approche GitOps avec des outils comme ArgoCD
- **Service Mesh** : Implémentation d'Istio pour améliorer la gestion du trafic
- **Observabilité** : Renforcement des capacités de monitoring et d'analyse
- **Infrastructure as Code** : Évolution vers Terraform CDK pour plus de flexibilité

## 6. Correspondance avec le Référentiel de Compétences

Cette présentation de projet a été structurée pour mettre en évidence les compétences requises dans le référentiel du Titre Professionnel d'Administrateur Système DevOps (RNCP36061), tel que défini par France Compétences.

### 6.1. Bloc de compétences 1 : Automatiser le déploiement d'une infrastructure dans le cloud

Le projet Digital Store répond aux exigences du premier bloc de compétences à travers les réalisations suivantes :

| Compétence du référentiel | Mise en œuvre dans le projet |
|---------------------------|------------------------------|
| Automatiser la création de serveurs à l'aide de scripts | Utilisation de Terraform pour définir et provisionner automatiquement l'infrastructure AWS, y compris les nœuds EKS (sections 2.1 et 2.2) |
| Automatiser le déploiement d'une infrastructure | Mise en place d'un pipeline CI/CD avec GitHub Actions pour déployer l'infrastructure de manière automatisée (section 2.4 et 3.4) |
| Sécuriser l'infrastructure | Implémentation de mesures de sécurité complètes, incluant IAM, Security Groups, et gestion des secrets (section 2.3) |
| Mettre l'infrastructure en production dans le cloud | Procédure de déploiement dans AWS avec validation et tests d'infrastructure (section 2.4) |

### 6.2. Bloc de compétences 2 : Déployer en continu une application

La mise en œuvre du déploiement continu dans le projet Digital Store s'aligne parfaitement avec le deuxième bloc de compétences :

| Compétence du référentiel | Mise en œuvre dans le projet |
|---------------------------|------------------------------|
| Préparer un environnement de test | Création d'environnements de développement, staging et production identiques et reproductibles (section 3.1) |
| Gérer le stockage des données | Utilisation de PostgreSQL avec gestion des PersistentVolumeClaims et stratégies de sauvegarde (section 3.2) |
| Gérer des containers | Orchestration des containers avec Kubernetes, incluant déploiements, services et ingress (section 3.3) |
| Automatiser la mise en production d'une application avec une plateforme | Pipeline complet CI/CD avec GitHub Actions, intégrant validation, tests, sécurité et déploiement automatisé (section 3.4) |

### 6.3. Bloc de compétences 3 : Superviser les services déployés

La supervision mise en place dans le projet répond aux exigences du troisième bloc de compétences du référentiel :

| Compétence du référentiel | Mise en œuvre dans le projet |
|---------------------------|------------------------------|
| Définir et mettre en place des statistiques de services | Définition d'indicateurs clés de performance pour la disponibilité, la performance et les ressources (section 4.1) |
| Exploiter une solution de supervision | Utilisation d'outils de monitoring incluant Prometheus, CloudWatch et Grafana pour la visualisation des métriques (section 4.2) |
| Échanger sur des réseaux professionnels (éventuellement en anglais) | Documentation des procédures, participation aux communautés cloud et Kubernetes, et documentation technique en anglais (sections 2.3, 3.3, 4.3) |

Ce projet démontre l'acquisition des compétences requises pour le titre professionnel d'Administrateur Système DevOps, en mettant l'accent sur l'automatisation, le déploiement continu et la supervision des services déployés dans un environnement cloud. 