# OUTPUTS - DYNAMODB MODULE

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.payments.name
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.payments.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.payments.arn
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN"
  value       = var.enable_streams ? aws_dynamodb_table.payments.stream_arn : null
}

output "table_stream_label" {
  description = "DynamoDB table stream label"
  value       = var.enable_streams ? aws_dynamodb_table.payments.stream_label : null
}

output "gsi_order_id_name" {
  description = "OrderId Global Secondary Index name"
  value       = "OrderIdIndex"
}

output "gsi_status_name" {
  description = "Status Global Secondary Index name"
  value       = "StatusIndex"
}
