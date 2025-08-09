output "service_dns" {
  value = "${var.release_name}.${var.namespace}.svc.cluster.local"
}

output "postgres_superuser_uri" {
  value     = "postgresql://postgres:${var.postgres_password}@${var.release_name}.${var.namespace}.svc.cluster.local:5432/postgres"
  sensitive = true
}

output "appdb_uri" {
  value     = "postgresql://app:${var.app_password}@${var.release_name}.${var.namespace}.svc.cluster.local:5432/appdb"
  sensitive = true
}
