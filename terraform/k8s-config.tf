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