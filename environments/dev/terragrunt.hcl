# environments/dev/terragrunt.hcl
# ------------------------------------------------------------
# Ambiente de desenvolvimento — recursos mínimos, sem protecções.
# instance_type mantido em t3.micro (free tier).
# ------------------------------------------------------------

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment   = "dev"
  instance_type = "t3.micro"
}

terraform {
  source = "../../modules/aws-ec2-instance"
}

inputs = {
  environment          = local.environment
  instance_type        = local.instance_type
  instance_name        = "hands-on-satubinha-dev"
  iam_instance_profile = null
}