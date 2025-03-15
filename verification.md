# Guide de Vérification du Système Digital Store

Ce document fournit les étapes à suivre pour vérifier que le système Digital Store fonctionne correctement. Il peut être utilisé lors d'un déploiement manuel ou pour diagnostiquer des problèmes dans un déploiement existant.

## Prérequis

- AWS CLI configuré avec les accès appropriés
- kubectl configuré pour accéder au cluster EKS
- terraform (pour les déploiements manuels)

## 1. Vérification de l'Infrastructure

### Terraform

```bash
# Vérification des ressources Terraform
cd terraform
terraform state list
terraform output
```

Les ressources suivantes devraient être présentes:
- EKS Cluster (`aws_eks_cluster.digital_store_cluster`)
- EKS Node Group (`aws_eks_node_group.node_group`)
- Security Groups (`aws_security_group.*`)
- IAM Roles (`aws_iam_role.*`)
- ECR Repositories (`aws_ecr_repository.*`)

### AWS EKS

```bash
# Configurer kubectl pour accéder au cluster
aws eks update-kubeconfig --name digital-store-cluster --region us-east-1

# Vérifier les nœuds du cluster
kubectl get nodes
kubectl describe nodes | grep "Capacity\|Allocatable"
```

Assurez-vous que les nœuds sont en état `Ready` et qu'ils ont suffisamment de ressources disponibles.

## 2. Vérification des Pods et Services Kubernetes

### Vérification des Pods

```bash
# Vérifier tous les pods
kubectl get pods -o wide
kubectl get pods -o wide | grep -v "Running\|Completed"
```

Tous les pods devraient être en état `Running`. En cas de problème:
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name> --tail=100
```

### Vérification des Services

```bash
# Lister tous les services
kubectl get services

# Vérifier les endpoints
kubectl get endpoints
```

Les services suivants devraient être disponibles et avoir des endpoints:
- `digital-store-backend-service`
- `digital-store-frontend-service`
- `postgres`

### Vérification de l'Ingress

```bash
# Vérifier l'ingress
kubectl get ingress
kubectl describe ingress digital-store-ingress
```

L'ingress devrait avoir une adresse disponible et des règles pour le backend et le frontend.

## 3. Vérification de l'Application

### Vérification de la Base de Données

```bash
# Vérifier que le pod PostgreSQL est connecté
kubectl exec -it $(kubectl get pod -l app=postgres -o jsonpath="{.items[0].metadata.name}") -- \
  pg_isready -h localhost
```

### Vérification du Backend

```bash
# Obtenir l'URL du backend
BACKEND_URL=$(kubectl get ingress digital-store-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

# Vérifier l'état de santé du backend
curl -k https://$BACKEND_URL/api/health
```

La réponse devrait être `{"status":"UP"}` ou similaire.

### Vérification du Frontend

```bash
# Obtenir l'URL du frontend
FRONTEND_URL=$(kubectl get ingress digital-store-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

# Vérifier que le frontend est accessible
curl -k -I https://$FRONTEND_URL
```

La réponse devrait être un code HTTP 200.

## 4. Tests de Bout en Bout

```bash
# Test d'API simple avec curl
curl -k https://$BACKEND_URL/api/products

# Test de charge simple
for i in {1..10}; do
  curl -k -s -o /dev/null -w "%{http_code}" https://$BACKEND_URL/api/products
  echo ""
  sleep 1
done
```

## 5. Dépannage Courant

### Problèmes de Déploiement

Si les pods ne démarrent pas:
```bash
kubectl describe pod <pod-name>  # Vérifier les événements
kubectl logs <pod-name>          # Vérifier les logs
```

### Problèmes de Configuration

Si l'application ne fonctionne pas correctement:
```bash
# Vérifier le ConfigMap
kubectl get configmap digital-store-config -o yaml

# Vérifier le Secret
kubectl get secret postgres-secret -o yaml
```

### Problèmes de Réseau

Si les services ne communiquent pas:
```bash
# Test de connectivité réseau
kubectl run -it --rm test --image=busybox -- sh
# Dans le pod:
wget -O- digital-store-backend-service:8080/health
wget -O- postgres:5432
```

## 6. Nettoyage et Redéploiement

Si nécessaire, redéployez les composants:

```bash
# Redéployer les manifestes Kubernetes
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/database/postgres/secret.yaml
kubectl apply -f k8s/database/postgres/storage.yaml
kubectl apply -f k8s/database/postgres/deployment.yaml
kubectl apply -f k8s/database/postgres/service.yaml
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml
kubectl apply -f k8s/ingress/ingress.yaml

# Forcer un redémarrage des déploiements
kubectl rollout restart deployment digital-store-backend
kubectl rollout restart deployment digital-store-frontend
```

## Conclusion

Si toutes les vérifications ci-dessus réussissent, votre système Digital Store est correctement déployé et fonctionnel. En cas de problème, utilisez les commandes de dépannage pour identifier et résoudre les problèmes. 