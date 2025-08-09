module "postgres" {
  source = "../../modules/postgres"

  namespace         = "postgres"
  release_name      = "postgresql"
  chart_version = "15.5.22"        # keep pinned intentionally
  postgres_password = var.postgres_password
  app_password      = var.app_password
  # storage_class_name = "gp3-csi"     # optional
  # resources = {                      # optional
  #   requests = { cpu = "100m", memory = "256Mi" }
  #   limits   = { cpu = "500m", memory = "512Mi" }
  # }
}

output "pg_dns" {
  value = module.postgres.service_dns
}

output "appdb_uri" {
  value = module.postgres.appdb_uri
  sensitive = true
}

output "superuser_uri" {
  value = module.postgres.postgres_superuser_uri
  sensitive = true
}