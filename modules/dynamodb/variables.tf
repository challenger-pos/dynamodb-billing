# VARIABLES - DYNAMODB MODULE

variable "environment" {
  description = "Environment name (dev, homologation, production)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "service_name" {
  description = "Service name"
  type        = string
}

# BILLING MODE

variable "billing_mode" {
  description = "Billing mode: PAY_PER_REQUEST (on-demand) or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be either PAY_PER_REQUEST or PROVISIONED"
  }
}

variable "read_capacity" {
  description = "Read capacity units (only for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "gsi_read_capacity" {
  description = "GSI read capacity units (only for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "gsi_write_capacity" {
  description = "GSI write capacity units (only for PROVISIONED mode)"
  type        = number
  default     = 5
}

# FEATURES

variable "enable_ttl" {
  description = "Enable Time To Live for automatic data expiration"
  type        = bool
  default     = false
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery (backup continuous)"
  type        = bool
  default     = true
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams for CDC"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (use AWS managed key if null)"
  type        = string
  default     = null
}
