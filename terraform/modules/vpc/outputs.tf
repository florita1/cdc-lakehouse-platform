output "vpc_id" {
  description = "VPC ID for wal-cdc cluster"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}
