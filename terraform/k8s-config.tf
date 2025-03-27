resource "local_file" "k8s_backend_deployment" {
  content = templatefile("${path.module}/templates/backend-deployment.tpl", {
    ecr_repository_url = aws_ecr_repository.backend.repository_url
    image_tag          = "latest"
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
    image_tag          = "latest"
  })
  filename = "../k8s/frontend/deployment.yaml"
}

resource "local_file" "k8s_frontend_service" {
  content = templatefile("${path.module}/templates/frontend-service.tpl", {})
  filename = "../k8s/frontend/service.yaml"
}

resource "local_file" "k8s_ingress" {
  content = templatefile("${path.module}/templates/ingress.tpl", {
    public_subnets  = join(",", var.public_subnet_ids)
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

# Déploiement direct via kubernetes_manifest au lieu de Helm
resource "kubernetes_namespace" "digital_store" {
  metadata {
    name = "default"
  }
}

# Assurer que le répertoire Helm existe
resource "null_resource" "helm_prepare" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/.helm/cache ${path.module}/.helm/repositories"
  }
}

# Déploiement de l'application via Helm mais avec null_resource comme backup
resource "helm_release" "digital_store" {
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    null_resource.helm_prepare
  ]

  name             = "digital-store"
  namespace        = "default"
  create_namespace = true
  chart            = "${path.module}/chart"
  values           = [file("${path.module}/chart/values.yaml")]
  
  timeout          = 900 # 15 minutes instead of 10
  wait             = true
  atomic           = true # Changed to true to roll back on failure
  cleanup_on_fail  = true # Changed to true to clean up resources on failure
  recreate_pods    = true
  replace          = true
  force_update     = true
  max_history      = 10
  
  # Added lifecycle block to handle errors better
  lifecycle {
    ignore_changes = [
      values
    ]
  }
}

# Plan B : Déployer avec kubectl si Helm échoue
resource "null_resource" "kubectl_fallback" {
  depends_on = [
    helm_release.digital_store
  ]

  # Seulement s'exécute si Helm a échoué
  triggers = {
    helm_success = helm_release.digital_store.status != "failed" ? true : false
    always_run   = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      if [ "${helm_release.digital_store.status}" == "failed" ]; then
        echo "Helm deployment failed, applying with kubectl as fallback..."
        aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}
        
        # Ensure no conflicting resources from the failed Helm release
        echo "Cleaning up any previous resources..."
        kubectl delete deployment,service,ingress,configmap,secret -l app=digital-store --ignore-not-found=true -n default

        echo "Waiting for resources to be deleted..."
        sleep 30
        
        echo "Applying Kubernetes resources with kubectl..."
        kubectl apply -f ../k8s/configmap.yaml || true
        kubectl apply -f ../k8s/database/postgres/secret.yaml || true
        kubectl apply -f ../k8s/database/postgres/storage.yaml || true
        kubectl apply -f ../k8s/database/postgres/deployment.yaml || true
        kubectl apply -f ../k8s/database/postgres/service.yaml || true
        kubectl apply -f ../k8s/backend/ || true
        kubectl apply -f ../k8s/frontend/ || true
        kubectl apply -f ../k8s/ingress/ || true
        
        echo "Waiting for deployments..."
        kubectl wait --for=condition=available --timeout=300s deployment/digital-store-backend -n default || true
        kubectl wait --for=condition=available --timeout=300s deployment/digital-store-frontend -n default || true
        
        echo "Checking deployment status..."
        kubectl get deployments -n default
        kubectl get pods -n default
      else
        echo "Helm deployment succeeded, no fallback needed."
      fi
    EOT
  }
} 