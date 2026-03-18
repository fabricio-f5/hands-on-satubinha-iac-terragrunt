# terragrunt.hcl (raiz)
# ------------------------------------------------------------
# Configuração partilhada por todos os ambientes.
# Nenhum ambiente precisa de backend.tf ou providers.tf próprio.
# ------------------------------------------------------------

locals {
  aws_region  = "us-east-1"
  project     = "hands-on-satubinha"
  tf_version  = "~> 1.9"
  aws_version = "~> 5.0"
}

# Gera o backend.tf em cada ambiente automaticamente.
# A key do state é calculada pelo path do ambiente:
#   environments/dev  → dev/terraform.tfstate
#   environments/prod → prod/terraform.tfstate
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket       = "hands-on-satubinha-tfstate"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.aws_region
    encrypt      = true
    use_lockfile = true  # lockfile nativo — sem DynamoDB
  }
}

# Gera o providers.tf em cada ambiente automaticamente.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Project     = "${local.project}"
      ManagedBy   = "terragrunt"
      Environment = var.environment
    }
  }
}

terraform {
  required_version = "${local.tf_version}"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${local.aws_version}"
    }
  }
}
EOF
}
