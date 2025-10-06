# Who am I?
data "aws_caller_identity" "current" {}

# Build URL (without https://) and ARN from the cluster identity
locals {
  eks_oidc_provider_url = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_provider_url}"
}

module "iceberg" {
  source                = "../../modules/iceberg"
  env                   = "dev"
  region                = "us-east-1"

  # pass these derived values instead of module outputs
  account               = data.aws_caller_identity.current.account_id
  eks_oidc_provider_arn = local.eks_oidc_provider_arn
  eks_oidc_provider_url = local.eks_oidc_provider_url
}