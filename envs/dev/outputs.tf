# OUTPUTS - DYNAMODB BILLING DEV

output "table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb_billing.table_name
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = module.dynamodb_billing.table_id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = module.dynamodb_billing.table_arn
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN (null if streams disabled)"
  value       = module.dynamodb_billing.table_stream_arn
}

output "gsi_order_id_name" {
  description = "OrderId GSI name"
  value       = module.dynamodb_billing.gsi_order_id_name
}

output "gsi_status_name" {
  description = "Status GSI name"
  value       = module.dynamodb_billing.gsi_status_name
}
