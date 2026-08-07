variable "project_name" {
  description = "Used to prefix/tag all resources so they're identifiable"
  type        = string
}

variable "environment" {
  description = "e.g. dev, staging, prod"
  type        = string
}

variable "vpc_cidr" {
  description = "The IP range for the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across (start with 2 for real HA testing)"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "One CIDR per AZ, for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "One CIDR per AZ, for private subnets"
  type        = list(string)
}
