# DYNAMODB TABLE - PAYMENTS

resource "aws_dynamodb_table" "payments" {
  name           = "${var.project_name}-${var.service_name}-${var.environment}"
  billing_mode   = var.billing_mode

  # Hash Key (Partition Key) - workOrderId é único no domínio da aplicação
  hash_key = "workOrderId"

  # Atributos
  attribute {
    name = "workOrderId"
    type = "S"  # String (UUID convertido para String)
  }

  attribute {
    name = "externalPaymentId"
    type = "S"  # String - para GSI (Mercado Pago ID)
  }

  attribute {
    name = "status"
    type = "S"  # String - para GSI
  }

  # Global Secondary Index - Query por externalPaymentId (Mercado Pago)
  global_secondary_index {
    name            = "ExternalPaymentIdIndex"
    hash_key        = "externalPaymentId"
    projection_type = "ALL"
    
    read_capacity  = var.billing_mode == "PROVISIONED" ? var.gsi_read_capacity : null
    write_capacity = var.billing_mode == "PROVISIONED" ? var.gsi_write_capacity : null
  }

  # Global Secondary Index - Query por status
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    projection_type = "ALL"
    
    read_capacity  = var.billing_mode == "PROVISIONED" ? var.gsi_read_capacity : null
    write_capacity = var.billing_mode == "PROVISIONED" ? var.gsi_write_capacity : null
  }

  # TTL (Time To Live) - opcional para auto-cleanup de dados antigos
  ttl {
    attribute_name = "expiresAt"
    enabled        = var.enable_ttl
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  # Stream para CDC (Change Data Capture) - útil para auditing/eventos
  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? "NEW_AND_OLD_IMAGES" : null

  tags = {
    Name        = "${var.project_name}-${var.service_name}-${var.environment}"
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "Terraform"
  }
}

# CLOUDWATCH ALARMS - MONITORAMENTO

# Alarm para consumo de read capacity
# resource "aws_cloudwatch_metric_alarm" "read_capacity" {
#   count = var.billing_mode == "PROVISIONED" ? 1 : 0

#   alarm_name          = "${var.project_name}-${var.service_name}-read-capacity-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "ConsumedReadCapacityUnits"
#   namespace           = "AWS/DynamoDB"
#   period              = "300"
#   statistic           = "Sum"
#   threshold           = var.read_capacity * 240  # 80% de 300 segundos
#   alarm_description   = "Alerta quando consumo de leitura ultrapassa 80%"
#   treat_missing_data  = "notBreaching"

#   dimensions = {
#     TableName = aws_dynamodb_table.payments.name
#   }

#   tags = {
#     Environment = var.environment
#     Service     = var.service_name
#   }
# }

# Alarm para consumo de write capacity
# resource "aws_cloudwatch_metric_alarm" "write_capacity" {
#   count = var.billing_mode == "PROVISIONED" ? 1 : 0

#   alarm_name          = "${var.project_name}-${var.service_name}-write-capacity-${var.environment}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "ConsumedWriteCapacityUnits"
#   namespace           = "AWS/DynamoDB"
#   period              = "300"
#   statistic           = "Sum"
#   threshold           = var.write_capacity * 240  # 80% de 300 segundos
#   alarm_description   = "Alerta quando consumo de escrita ultrapassa 80%"
#   treat_missing_data  = "notBreaching"

#   dimensions = {
#     TableName = aws_dynamodb_table.payments.name
#   }

#   tags = {
#     Environment = var.environment
#     Service     = var.service_name
#   }
# }

# Alarm para erros de sistema
resource "aws_cloudwatch_metric_alarm" "system_errors" {
  alarm_name          = "${var.project_name}-${var.service_name}-system-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SystemErrors"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alerta quando há erros de sistema no DynamoDB"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.payments.name
  }

  tags = {
    Environment = var.environment
    Service     = var.service_name
  }
}

# Alarm para throttling
resource "aws_cloudwatch_metric_alarm" "throttled_requests" {
  alarm_name          = "${var.project_name}-${var.service_name}-throttled-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alerta quando há requests throttled"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.payments.name
  }

  tags = {
    Environment = var.environment
    Service     = var.service_name
  }
}
