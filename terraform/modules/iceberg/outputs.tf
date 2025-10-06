output "s3_bucket" {
  value = aws_s3_bucket.iceberg.bucket
}
output "glue_database" {
  value = aws_glue_catalog_database.iceberg.name
}
output "irsa_role_arn" {
  value = aws_iam_role.flink_iceberg.arn
}
