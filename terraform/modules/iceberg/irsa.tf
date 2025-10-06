data "aws_iam_policy_document" "flink_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider_url}:sub"
      values   = ["system:serviceaccount:flink:flink-sa"]
    }
  }
}

resource "aws_iam_role" "flink_iceberg" {
  name               = "flink-iceberg-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.flink_irsa_assume.json
}

data "aws_iam_policy_document" "flink_iceberg_policy" {
  statement {
    sid       = "S3Access"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::flink-iceberg-${var.env}"]
  }
  statement {
    sid       = "S3ObjectRW"
    actions   = ["s3:*Object"]
    resources = ["arn:aws:s3:::flink-iceberg-${var.env}/*"]
  }
  statement {
    sid     = "GlueAccess"
    actions = [
      "glue:GetDatabase","glue:CreateDatabase","glue:UpdateDatabase","glue:DeleteDatabase",
      "glue:GetTable","glue:CreateTable","glue:UpdateTable","glue:DeleteTable",
      "glue:GetPartitions","glue:CreatePartition","glue:BatchCreatePartition"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "flink_iceberg" {
  name   = "flink-iceberg-${var.env}"
  policy = data.aws_iam_policy_document.flink_iceberg_policy.json
}

resource "aws_iam_role_policy_attachment" "flink_iceberg_attach" {
  role       = aws_iam_role.flink_iceberg.name
  policy_arn = aws_iam_policy.flink_iceberg.arn
}

output "flink_iceberg_role_arn" {
  value = aws_iam_role.flink_iceberg.arn
}
