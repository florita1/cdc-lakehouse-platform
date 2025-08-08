module "eks" {
  source = "../../modules/eks"

  cluster_name        = "wal-cdc-cluster"
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn
  public_subnet_ids   = module.vpc.public_subnet_ids
}
