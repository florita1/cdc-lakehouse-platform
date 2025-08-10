variable "vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "az_count" {
  default = 2
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "wal-cdc-platform"
    Environment = "dev"
  }
}
