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
  count = var.deploy_app ? 1 : 0
  
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
  atomic           = true
  cleanup_on_fail  = true
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
  
  set {
    name  = "backend.image.repository"
    value = var.backend_image
  }
  
  set {
    name  = "frontend.image.repository"
    value = var.frontend_image
  }
}

# Backup avec null_resource pour exécuter Helm manuellement si nécessaire
resource "null_resource" "helm_prepare" {
  provisioner "local-exec" {
    command = <<EOT
      helm upgrade --install digital-store ${path.module}/chart \
        --namespace default \
        --values ${path.module}/chart/values.yaml \
        --timeout 900s \
        --atomic \
        --cleanup-on-fail \
        --wait \
        --set backend.image=${var.backend_image} \
        --set frontend.image=${var.frontend_image}
    EOT
    environment = {
      KUBECONFIG = var.kubeconfig_path  # Assurez-vous que cette variable est définie
    }
  }

  # Déclencheur pour relancer uniquement si nécessaire (optionnel)
  triggers = {
    helm_release_id = helm_release.digital_store.id
    always_run     = false  # Ne se déclenche que si explicitement demandé
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

# Plan B : Déployer avec kubectl si Helm échoue
resource "null_resource" "kubectl_fallback" {
  depends_on = [
    helm_release.digital_store
  ]

  # Simplifions le trigger au maximum pour éviter les erreurs de syntaxe
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Version simplifiée du script qui ne fait pas référence au statut du helm_release
      echo "Vérification du déploiement Helm..."
      
      # Vérifier si nous avons accès au cluster
      if ! aws eks describe-cluster --name ${aws_eks_cluster.main.name} --region ${var.aws_region} > /dev/null 2>&1; then
        echo "Impossible d'accéder au cluster EKS. Abandon."
        exit 0
      fi
      
      # Configurer kubectl
      aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}
      
      # Vérifier si le déploiement Helm existe et son statut
      if helm status digital-store -n default > /dev/null 2>&1; then
        HELM_STATUS=$(helm status digital-store -n default -o json | grep -q '"status":"deployed"' && echo "success" || echo "failed")
        
        if [ "$HELM_STATUS" == "failed" ]; then
          echo "Déploiement Helm en échec, application du plan B avec kubectl..."
          
          # Nettoyer les ressources existantes
          echo "Nettoyage des ressources existantes..."
          kubectl delete deployment,service,ingress,configmap -l app=digital-store --ignore-not-found=true -n default
          
          echo "Attente de la suppression des ressources..."
          sleep 30
          
          # Appliquer les nouveaux manifests
          echo "Application des ressources Kubernetes avec kubectl..."
          kubectl apply -f ../k8s/configmap.yaml || true
          kubectl apply -f ../k8s/backend/ || true
          kubectl apply -f ../k8s/frontend/ || true
          kubectl apply -f ../k8s/ingress/ || true
          
          echo "Attente des déploiements..."
          kubectl wait --for=condition=available --timeout=300s deployment/digital-store-backend -n default || true
          kubectl wait --for=condition=available --timeout=300s deployment/digital-store-frontend -n default || true
        else
          echo "Déploiement Helm réussi. Aucune action requise."
        fi
      else
        if [ "${var.deploy_app}" == "true" ]; then
          echo "Déploiement Helm non trouvé. Application des manifests Kubernetes directement..."
          kubectl apply -f ../k8s/configmap.yaml || true
          kubectl apply -f ../k8s/backend/ || true
          kubectl apply -f ../k8s/frontend/ || true
          kubectl apply -f ../k8s/ingress/ || true
        else
          echo "Déploiement de l'application non demandé (deploy_app=false)."
        fi
      fi
    EOT
  }
} 
