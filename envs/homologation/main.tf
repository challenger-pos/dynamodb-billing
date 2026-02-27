terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "dynamodb-billing"
      Service     = "billing"
      Project     = var.project_name
    }
  }
}

# DYNAMODB MODULE

module "dynamodb_billing" {
  source = "../../modules/dynamodb"

  # Identificação
  environment  = var.environment
  project_name = var.project_name
  service_name = var.service_name

  # Billing
  billing_mode   = var.billing_mode


  # Features
  enable_ttl                    = var.enable_ttl
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
  enable_streams                = var.enable_streams
  kms_key_arn                   = var.kms_key_arn
}
