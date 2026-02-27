# DynamoDB Billing Infrastructure

Infrastructure as Code (Terraform) para provisionamento da tabela DynamoDB utilizada pelo **Payment Service** (Billing).

## 📋 Sobre

Este repositório contém os recursos Terraform para criar e gerenciar a tabela DynamoDB que armazena os dados de pagamentos do sistema, substituindo a anterior implementação com PostgreSQL RDS.

## Estrutura

A estrutura principal do repositório é a seguinte:

```
dynamodb-billing/
├── README.md
├── envs/                   # Ambientes (dev, homologation, production)
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   ├── homologation/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   └── production/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
└── modules/
   └── dynamodb/           # Módulo reutilizável do DynamoDB
      ├── dynamodb.tf
      ├── outputs.tf
      └── variables.tf

```

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

### Deploy - Environment Homologation

```bash
cd envs/homologation

# Inicializar Terraform
terraform init

# Planejar mudanças
terraform plan -var-file=terraform.tfvars

# Aplicar
terraform apply -var-file=terraform.tfvars
```

### Deploy - Environment Production

```bash
cd envs/production

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
# Dev
terraform output table_name  # challengeone-billing-dev

# Homologation
terraform output table_name  # challengeone-billing-homologation

# Production
terraform output table_name  # challengeone-billing-production
```

# Dev
data "terraform_remote_state" "dynamodb_billing" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/dynamodb-billing/dev/terraform.tfstate"
    region = "us-east-2"
  }
}

# Homologation
data "terraform_remote_state" "dynamodb_billing" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/dynamodb-billing/homologation/terraform.tfstate"
    region = "us-east-2"
  }
}

# Production
data "terraform_remote_state" "dynamodb_billing" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/dynamodb-billing/production/terraform.tfstate"
    region = "us-east-2"
  }
}

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

**Capacidade Free Tier DynamoDB:**
- 25 GB de armazenamento
- 25 unidades de leitura/s
- 25 unidades de escrita/s


## 📚 Referências

- [AWS DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Terraform AWS DynamoDB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)

## 🤝 Contribuindo

1. Criar feature branch
2. Fazer alterações nos arquivos Terraform
3. Testar em dev: `terraform plan`
4. Commitar e criar PR
5. Após merge, aplicar em outros ambientes


**Maintainer**: Grupo 19

**Last Updated**: 2026-02-17