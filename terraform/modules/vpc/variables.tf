variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.2.0.0/16)"
}

variable "az_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones to use"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all VPC resources"
}
