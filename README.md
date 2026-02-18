# DynamoDB Billing Infrastructure

Infrastructure as Code (Terraform) para provisionamento da tabela DynamoDB utilizada pelo **Payment Service** (Billing).

## 📋 Sobre

Este repositório contém os recursos Terraform para criar e gerenciar a tabela DynamoDB que armazena os dados de pagamentos do sistema, substituindo a anterior implementação com PostgreSQL RDS.

### Recursos Provisionados

- **DynamoDB Table**: Tabela `challengeone-billing-{env}` com:
  - Partition Key: `paymentId` (String/UUID)
  - Sort Key: `createdAt` (String/ISO-8601)
  - GSI `OrderIdIndex`: Query por orderId
  - GSI `StatusIndex`: Query por status de pagamento
  - Encryption at rest habilitado
  - CloudWatch Alarms para monitoramento

## 🏗️ Estrutura

```
dynamodb-billing/
├── modules/
│   └── dynamodb/          # Módulo reutilizável
│       ├── dynamodb.tf    # Recurso principal DynamoDB
│       ├── outputs.tf     # Outputs do módulo
│       └── variables.tf   # Variáveis do módulo
├── envs/
│   ├── dev/              # Environment development
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   ├── homologation/     # TODO: Environment homologation
│   └── production/       # TODO: Environment production
└── README.md
```

## 🔧 Schema da Tabela

### Atributos Principais

| Atributo | Tipo | Descrição |
|----------|------|-----------|
| `paymentId` | String | UUID único do pagamento (PK) |
| `createdAt` | String | Timestamp ISO-8601 (SK) |
| `orderId` | String | ID do pedido relacionado |
| `amount` | Number | Valor do pagamento |
| `currency` | String | Moeda (BRL, USD, etc.) |
| `status` | String | Status (PENDING, APPROVED, FAILED, etc.) |
| `paymentMethod` | String | Método de pagamento |
| `merchantOrderId` | String | ID do merchant (MercadoPago) |
| `externalId` | String | ID externo da transação |
| `metadata` | Map | Dados adicionais JSON |

### Global Secondary Indexes

1. **OrderIdIndex**
   - Hash Key: `orderId`
   - Range Key: `createdAt`
   - Use case: Buscar todos os pagamentos de um pedido

2. **StatusIndex**
   - Hash Key: `status`
   - Range Key: `createdAt`
   - Use case: Listar pagamentos por status (pending, approved, failed)

## 🚀 Como Usar

### Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Credenciais AWS com permissões DynamoDB
- Backend S3 já criado (`tf-state-challenge-bucket`)

### Deploy - Environment Dev

```bash
cd envs/dev

# Inicializar Terraform
terraform init

# Planejar mudanças
terraform plan -var-file=terraform.tfvars

# Aplicar
terraform apply -var-file=terraform.tfvars
```

### Outputs

Após o apply, os seguintes outputs estarão disponíveis:

```bash
terraform output table_name  # challengeone-billing-dev
terraform output table_arn   # arn:aws:dynamodb:us-east-2:...
```

## ⚙️ Variáveis de Configuração

### Billing Mode

**PAY_PER_REQUEST**:
- Cobra por request (read/write)
- Escala automaticamente
- Sem capacidade provisionada
- Ideal para tráfego imprevisível

**PROVISIONED**:
- Capacidade fixa com auto-scaling
- Custos mais previsíveis
- Melhor para tráfego constante

```hcl
# terraform.tfvars
billing_mode = "PAY_PER_REQUEST"  # ou "PROVISIONED"
```

### Features Opcionais

```hcl
# Point-in-time Recovery (backup contínuo)
enable_point_in_time_recovery = true

# DynamoDB Streams (CDC para Lambda/EventBridge)
enable_streams = true

# TTL (auto-delete de registros antigos)
enable_ttl = true

# KMS Encryption (custom key)
kms_key_arn = "arn:aws:kms:us-east-2:..."
```

## 📊 Monitoramento

CloudWatch Alarms criados automaticamente:

- **System Errors**: Alerta em caso de erros de sistema DynamoDB
- **Throttled Requests**: Alerta quando requests são throttled

## 🔗 Integração com Payment Service

O Payment Service consome a tabela DynamoDB via:

1. **Remote State** (Terraform):
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

2. **Environment Variables** (ConfigMap):
```yaml
AWS_DYNAMODB_TABLE_NAME: challengeone-billing-dev
AWS_REGION: us-east-2
```

3. **Spring Boot Application**:
```java
@DynamoDbTable(tableName = "${aws.dynamodb.table-name}")
public class Payment {
    @DynamoDbPartitionKey
    private String paymentId;
    
    @DynamoDbSortKey
    private String createdAt;
    
    // ...
}
```

## 📚 Referências

- [AWS DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [Terraform AWS DynamoDB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)

## 🤝 Contribuindo

1. Criar feature branch
2. Fazer alterações nos arquivos Terraform
3. Testar em dev: `terraform plan`
4. Commitar e criar PR
5. Após merge, aplicar em outros ambientes

## 📝 To-Do

- [ ] Criar environment homologation
- [ ] Criar environment production com auto-scaling
- [ ] Configurar KMS custom key para encryption
- [ ] Implementar DynamoDB Streams para auditoria
- [ ] Configurar Lambda para backup para S3
- [ ] Setup de alarmes SNS para CloudWatch

---

**Maintainer**: Grupo 19
**Last Updated**: 2026-02-17