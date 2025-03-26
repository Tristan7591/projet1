resource "helm_release" "digital_store" {
  name             = "digital-store"
  chart            = "${path.module}/helm"
  namespace        = "default"
  create_namespace = true
  
  timeout = 600 // 10 minutes au lieu de la valeur par défaut
  wait    = true

  values = [
    templatefile("${path.module}/templates/configmap.tpl", {
      aws_region     = var.aws_region
      cluster_name   = aws_eks_cluster.digital_store.name
    })
  ]

  depends_on = [
    aws_eks_cluster.digital_store,
    aws_eks_node_group.digital_store
  ]
} 