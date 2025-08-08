resource "helm_release" "wal_cdc_argocd" {
  name       = "wal-cdc-argocd"
  namespace  = "wal-cdc-argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6" # Use latest compatible version

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}