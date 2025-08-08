variable "cluster_role_name" {
  type        = string
  description = "Name for the EKS cluster IAM role"
}

variable "node_group_role_name" {
  type        = string
  description = "Name for the EKS node group IAM role"
}
