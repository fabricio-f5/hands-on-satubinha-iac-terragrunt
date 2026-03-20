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
│   │   ├── network/                # Layer 1 — VPC, subnet, IGW, route table
│   │   │   └── terragrunt.hcl
│   │   ├── security-group/         # Layer 1 — Security Group
│   │   │   └── terragrunt.hcl
│   │   └── ec2/                    # Layer 2 — instância EC2
│   │       └── terragrunt.hcl
│   ├── staging/
│   │   ├── network/
│   │   ├── security-group/
│   │   └── ec2/
│   └── prod/
│       ├── network/
│       ├── security-group/
│       └── ec2/
└── modules/
    ├── aws-vpc/                     # VPC, subnet pública, IGW, route table
    ├── aws-ec2-instance/            # EC2 com IMDSv2, EBS encriptado, monitoring
    ├── aws-iam-ec2/                 # IAM Role para instâncias EC2
    ├── aws-iam-oidc-github/         # OIDC Provider + IAM Role GitHub Actions
    ├── aws-keypair/                 # Key Pair para acesso SSH
    ├── aws-s3-bucket/               # Bucket S3 genérico
    └── aws-security-group/          # Security Group configurável
```

---

## Padrão DRY com Terragrunt

O `root.hcl` centraliza toda a configuração comum — backend S3, provider AWS e tags globais. Cada ambiente só declara o que é genuinamente diferente:

```hcl
# environments/dev/ec2/terragrunt.hcl — apenas o que muda no dev
include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  environment   = "dev"
  instance_type = "t3.micro"
  instance_name = "hands-on-satubinha-dev"
}
```

---

## Arquitectura de rede por ambiente

Cada ambiente tem a sua própria VPC completamente isolada — sem partilha de rede entre dev, staging e prod:

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
Subnet pública
    │
    ▼
Security Group  ←  SSH (22), TLS (443)
    │
    ▼
EC2 Instance
```

| Ambiente | VPC CIDR | Subnet CIDR | AZ |
|---|---|---|---|
| dev | `10.0.0.0/16` | `10.0.1.0/24` | us-east-1a |
| staging | `10.1.0.0/16` | `10.1.1.0/24` | us-east-1a |
| prod | `10.2.0.0/16` | `10.2.1.0/24` | us-east-1a |

---

## Dependency blocks — grafo de dependências declarado

O Terragrunt lê o state remoto do módulo dependente e injeta os outputs como inputs do módulo seguinte. Não há SSM nem hardcode — a dependência é declarada explicitamente no código:

```hcl
# environments/dev/ec2/terragrunt.hcl
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnet_id = "subnet-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "sg" {
  config_path = "../security-group"

  mock_outputs = {
    sg_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  subnet_id         = dependency.network.outputs.subnet_id
  security_group_id = dependency.sg.outputs.sg_id
}
```

O grafo de dependências por ambiente:

```
network
    │
    ├──────────────────┐
    ▼                  ▼
security-group      (subnet_id)
    │                  │
    └────────┬─────────┘
             ▼
            ec2
```

O Terragrunt garante automaticamente a ordem de apply:
1. `network` — cria VPC, subnet, IGW, route table
2. `security-group` — lê `vpc_id` do network, cria SG
3. `ec2` — lê `subnet_id` e `sg_id`, cria instância

---

## Separação por camadas

A infra é dividida em duas camadas com ciclos de vida independentes:

| Layer | Recursos | Quando muda |
|---|---|---|
| Layer 1 — Network | VPC, Subnet, IGW, Route Table, Security Group | Raramente — mudança deliberada |
| Layer 2 — Application | EC2 Instance | Frequentemente — a cada deploy |

Esta separação evita que um push de código toque em recursos de rede críticos.

---

## State isolado por ambiente e layer

Um único bucket S3 com separação por path — sem risco de um `apply` num ambiente tocar no state de outro:

```
hands-on-satubinha-tfstate/
├── environments/dev/network/terraform.tfstate
├── environments/dev/security-group/terraform.tfstate
├── environments/dev/ec2/terraform.tfstate
├── environments/staging/network/terraform.tfstate
├── environments/staging/security-group/terraform.tfstate
├── environments/staging/ec2/terraform.tfstate
├── environments/prod/network/terraform.tfstate
├── environments/prod/security-group/terraform.tfstate
└── environments/prod/ec2/terraform.tfstate
```

A key é calculada automaticamente pelo Terragrunt via `path_relative_to_include()`.

---

## SSM Parameter Store

Valores globais que não dependem de nenhum módulo de rede continuam no SSM:

```
/hands-on-satubinha/common/ami_id
/hands-on-satubinha/common/key_name
```

Os valores de rede (`subnet_id`, `security_group_id`) são agora geridos via `dependency` blocks — eliminando a dependência de valores manuais no SSM.

---

## Autenticação OIDC

O GitHub Actions autentica na AWS via OIDC — sem credenciais estáticas armazenadas como secrets:

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

Seis workflows independentes organizados por ambiente e layer:

| Workflow | Ambiente | Layer | Trigger | Aprovação |
|---|---|---|---|---|
| `terragrunt-dev-network.yml` | dev | Network | Manual | Não |
| `terragrunt-dev-ec2.yml` | dev | EC2 | Push + Manual | Não |
| `terragrunt-staging-network.yml` | staging | Network | Manual | Não |
| `terragrunt-staging-ec2.yml` | staging | EC2 | Push (plan) + Manual (apply) | Não |
| `terragrunt-prod-network.yml` | prod | Network | Manual | **Sim** |
| `terragrunt-prod-ec2.yml` | prod | EC2 | Manual | **Sim** |

### Comportamento por ambiente

| Evento | Dev EC2 | Staging EC2 | Prod EC2 |
|---|---|---|---|
| Push para main | auto-apply | só plan | não dispara |
| workflow_dispatch | plan/apply/plan_destroy/destroy | plan/apply/plan_destroy/destroy | plan/apply/plan_destroy/destroy |
| Aprovação manual | Não | Não | **Sim — GitHub Environment** |

### Operações disponíveis em todos os pipelines

| Opção | Descrição |
|---|---|
| `plan` | Calcula alterações sem aplicar |
| `apply` | Aplica as alterações |
| `plan_destroy` | Mostra o que seria destruído — sem destruir |
| `destroy` | Destrói os recursos |

O `plan_destroy` e o `destroy` são opções isoladas — correr um não implica correr o outro.

Todos os pipelines correm `terraform fmt -check`, `terragrunt validate` e Checkov antes de qualquer operação. O Checkov corre com `soft_fail: true` e gera um relatório como artefacto por run.

---

## Como usar

### Pré-requisitos

- Terraform >= 1.10
- Terragrunt >= 0.67
- AWS CLI configurado
- Conta AWS com permissões de EC2, VPC, S3, SSM e IAM

### Provisionar a foundation (primeira vez)

```bash
cd foundation
terraform init
terraform apply -var-file="foundation.tfvars"
```

### Provisionar um ambiente completo

```bash
cd environments/dev
terragrunt run-all apply
```

O Terragrunt aplica na ordem correcta: `network` → `security-group` → `ec2`.

### Provisionar uma layer individualmente

```bash
cd environments/dev/network
terragrunt apply

cd environments/dev/security-group
terragrunt apply

cd environments/dev/ec2
terragrunt apply
```

### Destruir uma layer

```bash
cd environments/dev/ec2
terragrunt destroy
```

> **Nota:** destruir o `network` ou `security-group` com recursos dependentes activos causa erros. Destrói sempre pela ordem inversa: `ec2` → `security-group` → `network`.

---

## Segurança

- **IMDSv2 obrigatório** — protecção contra SSRF em instâncias EC2
- **EBS encriptado** — disco raiz encriptado em todos os ambientes
- **Detailed monitoring** — métricas CloudWatch com granularidade de 1 minuto
- **S3 TLS obrigatório** — bucket de state rejeita ligações não encriptadas
- **OIDC** — autenticação keyless no CI/CD
- **Aprovação manual em prod** — GitHub Environments com required reviewers
- **plan_destroy isolado** — destruição nunca acontece acidentalmente ao correr plan
- **Checkov** — scan de segurança IaC em cada run do pipeline

---

## Limitações conhecidas

| Finding Checkov | Decisão |
|---|---|
| `CKV_AWS_144` — S3 cross-region replication | Over-engineering para este projecto |
| `CKV_AWS_145` — S3 KMS encryption | AES256 suficiente para este contexto |
| `CKV_AWS_18` — S3 access logging | Fora do scope — requer bucket dedicado |
| `CKV2_AWS_5` — SG attached to resource | Falso positivo — SG associado via input |
| `CKV_AWS_24` — SSH aberto | IP dinâmico 5G impede restrição por CIDR |
| `CKV_AWS_382` — Egress total | Ambiente de estudo com IP dinâmico |

---

## Projecto anterior

Este repositório é uma refatoração de [hands-on-satubinha-iac](https://github.com/fabricio-f5/hands-on-satubinha-iac) com introdução do Terragrunt para eliminar duplicação de código entre ambientes.
