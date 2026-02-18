# DynamoDB Billing - Deployment Guide

Guia de deployment para os ambientes de **dev**, **homologation** e **production**.

## 🚀 Quick Start

### Deploy usando script automatizado

```powershell
# Development
.\deploy.ps1 -Environment dev

# Homologation
.\deploy.ps1 -Environment homologation

# Production
.\deploy.ps1 -Environment production
```

O script executa automaticamente:
1. ✅ `terraform init` - Inicializa backend e providers
2. ✅ `terraform validate` - Valida configuração
3. ✅ `terraform plan` - Mostra mudanças planejadas
4. ⏸️ Pausa para confirmação
5. ✅ `terraform apply` - Aplica as mudanças
6. ✅ Mostra outputs (table name, ARN, etc)

---

## 📋 Deploy Manual

### 1. Development Environment

```bash
cd envs/dev

# Initialize
terraform init

# Plan
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars
```

**Expected Output:**
```
table_name = "challengeone-billing-dev"
table_arn = "arn:aws:dynamodb:us-east-2:...:table/challengeone-billing-dev"
```

---

### 2. Homologation Environment

```bash
cd envs/homologation

# Initialize
terraform init

# Plan
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars
```

**Expected Output:**
```
table_name = "challengeone-billing-homologation"
table_arn = "arn:aws:dynamodb:us-east-2:...:table/challengeone-billing-homologation"
```

---

### 3. Production Environment

```bash
cd envs/production

# Initialize
terraform init

# Plan
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars
```

**Expected Output:**
```
table_name = "challengeone-billing-production"
table_arn = "arn:aws:dynamodb:us-east-2:...:table/challengeone-billing-production"
```

---

## ✅ Validation

### Verificar tabelas criadas

```bash
# List all billing tables
aws dynamodb list-tables --region us-east-2 | grep challengeone-billing

# Describe specific table
aws dynamodb describe-table --table-name challengeone-billing-dev --region us-east-2
aws dynamodb describe-table --table-name challengeone-billing-homologation --region us-east-2
aws dynamodb describe-table --table-name challengeone-billing-production --region us-east-2
```

### Verificar outputs do Terraform

```bash
# Em cada diretório de ambiente
terraform output
terraform output table_name
terraform output table_arn
terraform output gsi_order_id_name
terraform output gsi_status_name
```

---

## 🔗 Integração com Payment Service

Após o deploy das tabelas DynamoDB, é necessário atualizar o **payment-service** para consumir as tabelas corretas.

### Atualizar Remote State

No `payment-service/terraform/providers.tf`, ajuste o remote state conforme o ambiente:

**Dev:**
```hcl
data "terraform_remote_state" "dynamodb_billing" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/dynamodb-billing/dev/terraform.tfstate"
    region = "us-east-2"
  }
}
```

**Homologation:**
```hcl
data "terraform_remote_state" "dynamodb_billing" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/dynamodb-billing/homologation/terraform.tfstate"
    region = "us-east-2"
  }
}
```

**Production:**
```hcl
data "terraform_remote_state" "dynamodb_billing" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/dynamodb-billing/production/terraform.tfstate"
    region = "us-east-2"
  }
}
```

### Atualizar ConfigMap

No `payment-service/terraform/configmap.tf`, a tabela será automaticamente consumida do remote state:

```hcl
data "terraform_remote_state" "dynamodb_billing" {
  # ... configuração acima
}

resource "kubernetes_config_map" "billing_config" {
  metadata {
    name      = "billing-config"
    namespace = var.namespace
  }

  data = {
    AWS_DYNAMODB_TABLE_NAME = data.terraform_remote_state.dynamodb_billing.outputs.table_name
    AWS_REGION              = var.region
    AWS_DYNAMODB_ENDPOINT   = ""
  }
}
```

### Deploy do Payment Service

```bash
cd payment-service/terraform

# Dev
terraform apply -var-file=terraform.tfvars.dev

# Homologation
terraform apply -var-file=terraform.tfvars.homologation

# Production
terraform apply -var-file=terraform.tfvars.production
```

---

## 🔄 Atualização de Recursos

### Modificar configuração da tabela

1. Edite `envs/{environment}/terraform.tfvars`
2. Execute:
   ```bash
   cd envs/{environment}
   terraform plan -var-file=terraform.tfvars
   terraform apply -var-file=terraform.tfvars
   ```

### Exemplo: Habilitar Streams em Production

```hcl
# envs/production/terraform.tfvars
enable_streams = true
```

```bash
cd envs/production
terraform apply -var-file=terraform.tfvars
```

---

## 🗑️ Destroy

### ⚠️ CUIDADO: Isso deleta a tabela e todos os dados!

```bash
cd envs/{environment}
terraform destroy -var-file=terraform.tfvars
```

Requer confirmação (`yes`) antes de executar.

---

## 💰 Custos

Todos os ambientes estão configurados para **FREE TIER**:

| Feature | Config | Custo |
|---------|--------|-------|
| Billing Mode | PAY_PER_REQUEST | $0 (até 25 WCU/RCU) |
| Storage | - | $0 (até 25 GB) |
| Point-in-time Recovery | Disabled | $0 |
| Streams | Disabled | $0 |
| TTL | Disabled | $0 |
| Encryption | AWS Managed | $0 |

**Total estimado por ambiente:** $0.00 - $0.50/mês (tráfego muito baixo)

---

## 📊 Monitoring

### CloudWatch Metrics

Acesse CloudWatch para visualizar métricas:
- **ConsumedReadCapacityUnits**: Unidades de leitura consumidas
- **ConsumedWriteCapacityUnits**: Unidades de escrita consumidas
- **UserErrors**: Erros de usuário (400)
- **SystemErrors**: Erros de sistema (500)
- **ThrottledRequests**: Requests rejeitados por throttling

### CloudWatch Alarms

Alarms criados automaticamente:
- `{table_name}-system-errors`: Alerta em caso de erros 500
- `{table_name}-throttled-requests`: Alerta em caso de throttling

---

## 🐛 Troubleshooting

### Erro: "ResourceNotFoundException"

**Causa:** Tabela não existe ou foi deletada

**Solução:**
```bash
cd envs/{environment}
terraform apply -var-file=terraform.tfvars
```

### Erro: "Backend initialization required"

**Causa:** Terraform não inicializado

**Solução:**
```bash
terraform init -reconfigure
```

### Erro: "AccessDeniedException"

**Causa:** Credenciais AWS sem permissão

**Solução:** Verificar IAM policy:
```json
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:CreateTable",
    "dynamodb:DescribeTable",
    "dynamodb:UpdateTable",
    "dynamodb:DeleteTable"
  ],
  "Resource": "*"
}
```

### Erro: "Table already exists"

**Causa:** Tentando criar tabela que já existe

**Solução:** Import da tabela existente:
```bash
terraform import module.dynamodb_billing.aws_dynamodb_table.this challengeone-billing-{env}
```

---

## 📚 References

- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [Terraform AWS Provider - DynamoDB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)
- [DynamoDB Free Tier](https://aws.amazon.com/dynamodb/pricing/)

---

**Last Updated:** 2026-02-18  
**Maintainer:** Grupo 19
