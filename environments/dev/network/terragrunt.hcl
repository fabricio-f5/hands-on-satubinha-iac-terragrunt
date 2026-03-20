include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = "dev"
}

terraform {
  source = "../../../modules/aws-vpc"
}

inputs = {
  name              = "hands-on-satubinha"
  environment       = local.environment
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
