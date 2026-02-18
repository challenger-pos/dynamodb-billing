# VARIABLES - DYNAMODB BILLING HOMOLOGATION

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "homologation"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "challengeone"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "billing"
}

# DYNAMODB CONFIGURATION

variable "billing_mode" {
  description = "Billing mode: PAY_PER_REQUEST or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# FEATURES

variable "enable_ttl" {
  description = "Enable Time To Live"
  type        = bool
  default     = false
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false 
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null 
}
