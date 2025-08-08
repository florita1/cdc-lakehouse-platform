variable "cluster_name" {
  type        = string
  description = "EKS cluster name (e.g., wal-cdc-cluster)"
}

variable "cluster_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS control plane"
}

variable "node_group_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS worker nodes"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to use for the EKS cluster and node group"
}
