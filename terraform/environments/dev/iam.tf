module "iam" {
  source = "../../modules/iam"

  cluster_role_name    = "wal-cdc-eks-cluster-role"
  node_group_role_name = "wal-cdc-eks-nodegroup-role"
}
