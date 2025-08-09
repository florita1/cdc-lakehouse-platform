locals {
  ns = var.namespace
}

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0
  metadata { name = local.ns }
}

resource "helm_release" "postgresql" {
  name       = var.release_name
  namespace  = local.ns
  chart      = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  version    = var.chart_version

  # Bitnami values
  values = [
    yamlencode({
      auth = {
        postgresPassword = var.postgres_password
      }

      primary = {
        # WAL settings for Debezium
        extendedConfiguration = <<-EOT
          wal_level=logical
          max_wal_senders=10
          max_replication_slots=10
        EOT

        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "512Mi" }
        }

        # Initialization SQL (runs in lexical order)
        initdb = {
          scripts = {
            # 00: ensure role + db exist before grants in later scripts
            "00_user_db.sql" = <<-SQL
              DO $$
              BEGIN
                IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app') THEN
                  CREATE ROLE app LOGIN PASSWORD '${var.app_password}';
                END IF;
              END
              $$;

              DO $$
              BEGIN
                IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'appdb') THEN
                  CREATE DATABASE appdb OWNER app;
                END IF;
              END
              $$;
            SQL

            # 01: your schema/table + grants (slightly renumbered so role exists first)
            "01_schema.sql" = <<-SQL
              \\connect appdb

              CREATE SCHEMA IF NOT EXISTS app;
              CREATE TABLE IF NOT EXISTS app.users (
                id UUID PRIMARY KEY,
                email TEXT NOT NULL UNIQUE,
                name TEXT,
                updated_at TIMESTAMPTZ DEFAULT now()
              );
              -- For complete row images in WAL (good for updates w/o keys)
              ALTER TABLE app.users REPLICA IDENTITY FULL;

              GRANT USAGE ON SCHEMA app TO "app";
              GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO "app";
              ALTER DEFAULT PRIVILEGES IN SCHEMA app
                GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "app";
            SQL

            # 10: optional publication (Debezium can also create it)
            "10_publication.sql" = <<-SQL
              \\connect appdb
              DO $$
              BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'dbz_pub') THEN
                  CREATE PUBLICATION dbz_pub FOR TABLE app.users;
                END IF;
              END$$;
            SQL
          }
        }

        # Helps on some storage classes (fsGroup perms)
        volumePermissions = {
          enabled = true
        }
      }

      persistence = {
        enabled           = true
        storageClass      = var.storage_class_name
      }
    })
  ]

  depends_on = [kubernetes_namespace.this]
}

# Templated resources block injection
# (Terraform can't interpolate inside yamlencode easily, so we make a small replace)
locals {
  resources_yaml = var.resources == null ? "" : <<-YAML
    resources:
      ${yamlencode(var.resources)}
  YAML
}

# Replace placeholder with resources yaml (or blank)
# This "null_resource" trick ensures the above 'values' picks the right string at plan time
# It's only for readability; helm_release already has the full yaml from values[]
resource "null_resource" "noop" {
  triggers = {
    res = local.resources_yaml
  }
}