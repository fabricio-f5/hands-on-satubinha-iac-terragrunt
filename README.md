# hands-on-satubinha-iac-terragrunt

Infraestrutura AWS multi-ambiente provisionada com **Terraform + Terragrunt**, aplicando o padrão DRY para eliminar duplicação de código entre ambientes. Refatoração do projecto [hands-on-satubinha-iac](https://github.com/fabricio-f5/hands-on-satubinha-iac) com foco em boas práticas de mercado.

---

## Visão geral

| Componente | Tecnologia |
|---|---|
| IaC | Terraform ~> 1.10 |
| Orquestração multi-ambiente | Terragrunt 0.67 |
| Cloud | AWS (us-east-1) |
| State backend | S3 com lockfile nativo |
| Autenticação CI/CD | OIDC — sem credenciais estáticas |
| Segurança IaC | Checkov |
| Pipeline | GitHub Actions |

---

## Estrutura do projecto
```
hands-on-satubinha-iac-terragrunt/
├── root.hcl                        # Backend S3, provider AWS e tags comuns
├── .checkov.yaml                   # Supressões documentadas do Checkov
├── foundation/                     # OIDC Provider + IAM Role para GitHub Actions
│   ├── main.tf
│   ├── variables.tf
│   ├── backend.tf
│   └── foundation.tfvars
├── environments/
│   ├── dev/
│   │   └── terragrunt.hcl          # Só o que é diferente no dev
│   ├── staging/
│   │   └── terragrunt.hcl          # Só o que é diferente no staging
│   └── prod/
│       └── terragrunt.hcl          # Só o que é diferente no prod
└── modules/
    ├── aws-ec2-instance/            # EC2 com IMDSv2, EBS encriptado, monitoring
    ├── aws-iam-ec2/                 # IAM Role para instâncias EC2
    ├── aws-iam-oidc-github/         # OIDC Provider + IAM Role GitHub Actions
    ├── aws-keypair/                 # Key Pair para acesso SSH
    ├── aws-s3-bucket/               # Bucket S3 genérico
    └── aws-security-group/          # Security Group configurável
```

---

## Padrão DRY com Terragrunt

O problema do projecto anterior era ~90% de código duplicado entre ambientes. Cada ambiente tinha `backend.tf`, `providers.tf` e `variables.tf` quase idênticos — qualquer mudança de versão de provider ou tag precisava ser feita em 3 ficheiros.

Com Terragrunt, o `root.hcl` centraliza toda a configuração comum e cada ambiente só declara o que é genuinamente diferente:
```hcl
# environments/prod/terragrunt.hcl — apenas o que muda no prod
include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment                = "prod"
  instance_type              = "t3.micro"
  instance_name              = "hands-on-satubinha-prod"
  enable_deletion_protection = true
  backup_retention_days      = 30
}
```

---

## State isolado por ambiente

Um único bucket S3 com separação por path — sem risco de um `apply` no dev tocar no state do prod:
```
hands-on-satubinha-tfstate/
├── environments/dev/terraform.tfstate
├── environments/staging/terraform.tfstate
└── environments/prod/terraform.tfstate
```

A key é calculada automaticamente pelo Terragrunt via `path_relative_to_include()` — sem configuração manual por ambiente.

---

## SSM Parameter Store

Valores de infraestrutura centralizados no SSM — sem hardcode de IDs no código:
```
/hands-on-satubinha/common/ami_id
/hands-on-satubinha/common/subnet_id
/hands-on-satubinha/common/security_group_id
/hands-on-satubinha/common/key_name
```

O módulo `aws-ec2-instance` lê estes valores via data sources em `data.tf`. Em produção real, os IDs seriam geridos por um módulo de networking e referenciados via `dependency` block do Terragrunt.

---

## Autenticação OIDC

O GitHub Actions autentica na AWS via OIDC — sem credenciais estáticas armazenadas como secrets. O único secret necessário é o ARN da IAM Role:
```yaml
- name: Configure AWS credentials via OIDC
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

A IAM Role é provisionada pela `foundation/` com restrição ao repositório e branch `main`.

---

## Pipelines GitHub Actions

Três workflows independentes com disparo manual (`workflow_dispatch`):

| Workflow | Ambiente | Aprovação manual |
|---|---|---|
| `terragrunt-dev.yml` | dev | Não |
| `terragrunt-staging.yml` | staging | Não |
| `terragrunt-prod.yml` | prod | **Sim** |

Cada workflow suporta três operações seleccionáveis:

| Input | Descrição |
|---|---|
| `apply` | Executa `terragrunt apply` |
| `plan_destroy` | Mostra o plan de destroy sem executar |
| `destroy` | Executa `terragrunt destroy` |

O Checkov corre em todos os workflows com `soft_fail: true` e gera um relatório como artefacto por run.

---

## Como usar

### Pré-requisitos

- Terraform >= 1.10
- Terragrunt >= 0.67
- AWS CLI configurado
- Conta AWS com permissões de EC2, S3, SSM e IAM

### Provisionar a foundation (primeira vez)
```bash
cd foundation
terraform init
terraform apply -var-file="foundation.tfvars"
```

### Provisionar um ambiente
```bash
cd environments/dev
terragrunt init
terragrunt apply
```

### Provisionar todos os ambientes de uma vez
```bash
terragrunt run --all apply
```

### Destruir um ambiente
```bash
cd environments/dev
terragrunt destroy
```

---

## Segurança

- **IMDSv2 obrigatório** — protecção contra SSRF em instâncias EC2
- **EBS encriptado** — disco raiz encriptado em todos os ambientes
- **Detailed monitoring** — métricas CloudWatch com granularidade de 1 minuto
- **S3 TLS obrigatório** — bucket de state rejeita ligações não encriptadas
- **OIDC** — autenticação keyless no CI/CD
- **Deletion protection** — activa no ambiente prod
- **Checkov** — scan de segurança IaC em cada run do pipeline

---

## Limitações conhecidas

| Finding Checkov | Decisão |
|---|---|
| `CKV_AWS_144` — S3 cross-region replication | Over-engineering para este projecto |
| `CKV_AWS_145` — S3 KMS encryption | AES256 suficiente para este contexto |
| `CKV_AWS_18` — S3 access logging | Fora do scope — requer bucket dedicado |
| `CKV2_AWS_5` — SG attached to resource | Falso positivo — SG associado via input |

---

## Projecto anterior

Este repositório é uma refatoração de [hands-on-satubinha-iac](https://github.com/fabricio-f5/hands-on-satubinha-iac) com introdução do Terragrunt para eliminar duplicação de código entre ambientes.
