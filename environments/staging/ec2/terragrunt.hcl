# environments/staging/ec2/terragrunt.hcl
# ------------------------------------------------------------
# Provisiona a instância EC2 do ambiente staging.
# Depende de network (subnet_id) e security-group (sg_id).
# ------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment   = "staging"
  instance_type = "t3.micro"
}

terraform {
  source = "../../../modules/aws-ec2-instance"
}

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
  environment          = local.environment
  instance_type        = local.instance_type
  instance_name        = "hands-on-satubinha-staging"
  iam_instance_profile = null
  subnet_id            = dependency.network.outputs.subnet_id
  security_group_id    = dependency.sg.outputs.sg_id
}
