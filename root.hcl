# root.hcl
# ------------------------------------------------------------
# Configuração partilhada por todos os ambientes.
# Nenhum ambiente precisa de backend.tf ou providers.tf próprio.
# ------------------------------------------------------------
locals {
  aws_region  = "us-east-1"
  project     = "hands-on-satubinha"
  tf_version  = "~> 1.10"
  aws_version = "~> 5.0"
}

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
    use_lockfile = true
  }
}

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

# ------------------------------------------------------------
# Terraform CLI arguments partilhados
# ------------------------------------------------------------
terraform {
  # Desactiva prompts interactivos — necessário para CI/CD
  extra_arguments "non_interactive" {
    commands  = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }

  # Provider cache partilhado — evita re-download do provider
  # em cada layer/ambiente. Todos os layers partilham a mesma
  # cópia do hashicorp/aws em vez de baixar ~400MB por run.
  # O directório é criado pelo Ansible no provisionamento da EC2.
  extra_arguments "provider_cache" {
    commands = ["init", "validate", "plan", "apply", "destroy", "import", "push", "refresh"]
    env_vars = {
      TF_PLUGIN_CACHE_DIR = "/var/jenkins_home/.terraform-plugin-cache"
    }
  }
}

