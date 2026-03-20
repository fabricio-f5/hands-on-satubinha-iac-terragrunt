include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = "staging"
}

terraform {
  source = "../../../modules/aws-security-group"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  name        = "hands-on-satubinha-staging"
  environment = local.environment
  vpc_id      = dependency.network.outputs.vpc_id
}
