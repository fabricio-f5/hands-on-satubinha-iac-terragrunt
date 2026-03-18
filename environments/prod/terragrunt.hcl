# environments/prod/terragrunt.hcl
# ------------------------------------------------------------
# Ambiente de produção — deletion protection activa, backup longo.
# instance_type mantido em t3.micro (free tier).
# Em produção real: t3.medium com multi_az = true.
# ------------------------------------------------------------

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment   = "prod"
  instance_type = "t3.micro"
}

terraform {
  source = "../../modules/aws-ec2-instance"
}

inputs = {
  environment          = local.environment
  instance_type        = local.instance_type
  instance_name        = "hands-on-satubinha-prod"
  iam_instance_profile = null
}

