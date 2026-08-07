terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # NOTE: no backend block yet — state is local for now.
  # We deliberately add remote state (S3 + DynamoDB) LATER, once
  # you've proven the VPC works. Don't add complexity before you
  # need it.
}

provider "aws" {
  region = var.aws_region
}
