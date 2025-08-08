resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids             = var.public_subnet_ids
    endpoint_public_access = true
  }
}

resource "aws_eks_node_group" "wal_cdc_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "wal-cdc-default-ng"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.public_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.large"]
  capacity_type  = "ON_DEMAND"

  depends_on = [aws_eks_cluster.this]
}

resource "null_resource" "aws_node_patch" {
  depends_on = [aws_eks_node_group.wal_cdc_nodes]

  triggers = {
    config_hash = sha1("ENABLE_PREFIX_DELEGATION=true,WARM_PREFIX_TARGET=1")
  }

  provisioner "local-exec" {
    command = <<EOT
kubectl -n kube-system patch daemonset aws-node --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name":"ENABLE_PREFIX_DELEGATION","value":"true"}},
  {"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name":"WARM_PREFIX_TARGET","value":"1"}}
]'
EOT
  }
}
