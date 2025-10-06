resource "aws_glue_catalog_database" "iceberg" {
  name = "appdb_${var.env}"
}
