# Génération des fichiers Kubernetes à partir de templates
resource "local_file" "k8s_backend_deployment" {
  content = templatefile("${path.module}/templates/backend-deployment.tpl", {
    ecr_repository_url = aws_ecr_repository.backend.repository_url
    image_tag          = var.image_tag  # Utilise une variable dynamique au lieu de "latest"
  })
  filename = "../k8s/backend/deployment.yaml"
}

resource "local_file" "k8s_backend_service" {
  content = templatefile("${path.module}/templates/backend-service.tpl", {})
  filename = "../k8s/backend/service.yaml"
}

resource "local_file" "k8s_frontend_deployment" {
  content = templatefile("${path.module}/templates/frontend-deployment.tpl", {
    ecr_repository_url = aws_ecr_repository.frontend.repository_url
    image_tag          = var.image_tag  # Utilise une variable dynamique au lieu de "latest"
  })
  filename = "../k8s/frontend/deployment.yaml"
}

resource "local_file" "k8s_frontend_service" {
  content = templatefile("${path.module}/templates/frontend-service.tpl", {})
  filename = "../k8s/frontend/service.yaml"
}

resource "local_file" "k8s_ingress" {
  content = templatefile("${path.module}/templates/ingress.tpl", {
    public_subnets = join(",", var.public_subnet_ids)
  })
  filename = "../k8s/ingress/ingress.yaml"
}

resource "local_file" "k8s_postgres_secret" {
  content = templatefile("${path.module}/templates/postgres-secret.tpl", {
    postgres_user     = base64encode(var.db_username)
    postgres_password = base64encode(var.db_password)
    postgres_db       = base64encode(var.db_name)
    postgres_host     = base64encode(aws_db_instance.postgres.address)
  })
  filename = "../k8s/database/postgres/secret.yaml"
}

resource "local_file" "k8s_postgres_deployment" {
  content = templatefile("${path.module}/templates/postgres-deployment.tpl", {})
  filename = "../k8s/database/postgres/deployment.yaml"
}

resource "local_file" "k8s_postgres_service" {
  content = templatefile("${path.module}/templates/postgres-service.tpl", {})
  filename = "../k8s/database/postgres/service.yaml"
}

resource "local_file" "k8s_postgres_storage" {
  content = templatefile("${path.module}/templates/postgres-storage.tpl", {})
  filename = "../k8s/database/postgres/storage.yaml"
}

resource "local_file" "k8s_configmap" {
  content = templatefile("${path.module}/templates/configmap.tpl", {})
  filename = "../k8s/configmap.yaml"
}

# Suppression de kubernetes_namespace "digital_store" car "default" existe déjà
# Si un namespace spécifique est souhaité, utilisez "digital-store" et ajustez en conséquence

# Préparation du répertoire Helm (une seule instance)
resource "null_resource" "helm_prepare" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/.helm/cache ${path.module}/.helm/repositories"
  }
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

# Déploiement via Helm avec contrôle conditionnel
resource "helm_release" "digital_store" {
  count = var.deploy_app ? 1 : 0

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    null_resource.helm_prepare
  ]

  name             = "digital-store"
  namespace        = "default"
  create_namespace = false  # Pas besoin de créer "default"
  chart            = "${path.module}/chart"
  values           = [file("${path.module}/chart/values.yaml")]

  timeout         = 900  # 15 minutes
  wait            = true
  atomic          = true  # Rollback en cas d'échec
  cleanup_on_fail = true  # Nettoyage en cas d'échec
  max_history     = 10

  # Suppression des options redondantes ou risquées
  # recreate_pods, replace, force_update supprimés car gérés par atomic

  lifecycle {
    ignore_changes = [values]
  }

  set {
    name  = "backend.image.repository"
    value = var.backend_image
  }

  set {
    name  = "frontend.image.repository"
    value = var.frontend_image
  }
}


# Fallback avec kubectl si Helm échoue
resource "null_resource" "kubectl_fallback" {
  depends_on = [
    helm_release.digital_store,
    local_file.k8s_backend_deployment,
    local_file.k8s_frontend_deployment,
    local_file.k8s_ingress,
    local_file.k8s_configmap
  ]

  triggers = {
    helm_status_check = join("", helm_release.digital_store[*].id)  # Déclenche uniquement si Helm change
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Vérification du déploiement Helm..."
      aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}
      if helm status digital-store -n default > /dev/null 2>&1; then
        HELM_STATUS=$(helm status digital-store -n default -o json | grep -q '"status":"deployed"' && echo "success" || echo "failed")
        if [ "$HELM_STATUS" == "failed" ]; then
          echo "Déploiement Helm échoué, passage au fallback kubectl..."
          kubectl delete deployment,service,ingress,configmap -l app=digital-store -n default --ignore-not-found=true
          sleep 30
          kubectl apply -f ../k8s/configmap.yaml
          kubectl apply -f ../k8s/backend/
          kubectl apply -f ../k8s/frontend/
          kubectl apply -f ../k8s/ingress/
          kubectl wait --for=condition=available --timeout=300s deployment/digital-store-backend -n default || true
          kubectl wait --for=condition=available --timeout=300s deployment/digital-store-frontend -n default || true
        else
          echo "Déploiement Helm réussi, aucun fallback requis."
        fi
      else
        if [ "${var.deploy_app}" == "true" ]; then
          echo "Helm release non trouvée, déploiement direct avec kubectl..."
          kubectl apply -f ../k8s/configmap.yaml
          kubectl apply -f ../k8s/backend/
          kubectl apply -f ../k8s/frontend/
          kubectl apply -f ../k8s/ingress/
        else
          echo "Déploiement de l'application non requis (deploy_app=false)."
        fi
      fi
    EOT
  }
}

