# environments/dev/ec2/terragrunt.hcl
# ------------------------------------------------------------
# Provisiona a instância EC2 do ambiente dev.
# Depende de network (subnet_id) e security-group (sg_id).
# ------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment   = "dev"
  instance_type = "t3.micro"
}

terraform {
  source = "../../../modules/aws-ec2-instance"
}

# ------------------------------------------------------------
# Dependency — lê subnet_id do módulo network.
# ------------------------------------------------------------
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnet_id = "subnet-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# ------------------------------------------------------------
# Dependency — lê sg_id do módulo security-group.
# ------------------------------------------------------------
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
  instance_name        = "hands-on-satubinha-dev"
  iam_instance_profile = null
  subnet_id            = dependency.network.outputs.subnet_id
  security_group_id    = dependency.sg.outputs.sg_id
}
