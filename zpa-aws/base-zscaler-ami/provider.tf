terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    zpa = {
      source  = "zscaler.com/zpa/zpa"
      version = "2.0.0"
    }
  }
  required_version = ">= 0.13"
}

# Configure AWS Provider
provider "aws" {
  region = var.aws-region
}

# Configure the ZPA Provider
provider "zpa" {}