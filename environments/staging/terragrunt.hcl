# environments/staging/terragrunt.hcl
# ------------------------------------------------------------
# Ambiente de staging — espelho do prod em comportamento.
# instance_type mantido em t3.micro (free tier).
# Em produção real: t3.small ou equivalente ao prod.
# ------------------------------------------------------------

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment   = "staging"
  instance_type = "t3.micro"
}

terraform {
  source = "../../modules/aws-ec2-instance"
}

inputs = {
  environment          = local.environment
  instance_type        = local.instance_type
  instance_name        = "hands-on-satubinha-staging"
  iam_instance_profile = null
}
