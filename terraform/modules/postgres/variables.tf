variable "namespace" {
  description = "Namespace to install Postgres into"
  type        = string
  default     = "postgres"
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "postgresql"
}

variable "chart_version" {
  description = "Bitnami PostgreSQL chart version"
  type        = string
  default     = "16.7.24"
}

variable "postgres_password" {
  description = "postgres superuser password"
  type        = string
  sensitive   = true
}

variable "app_password" {
  description = "password for 'app' role"
  type        = string
  sensitive   = true
}

variable "storage_class_name" {
  description = "Optional explicit StorageClass"
  type        = string
  default     = null
}

variable "resources" {
  description = "Optional primary container resources block"
  type        = any
  default     = null
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}
