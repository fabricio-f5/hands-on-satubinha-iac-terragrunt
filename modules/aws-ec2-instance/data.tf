# data.tf
# ------------------------------------------------------------
# Lê configuração global do SSM Parameter Store.
# subnet_id e security_group_id passaram a vir dos inputs
# injectados pelo dependency block no terragrunt.hcl.
# ------------------------------------------------------------
data "aws_ssm_parameter" "ami_id" {
  name = "/hands-on-satubinha/common/ami_id"
}
data "aws_ssm_parameter" "key_name" {
  name = "/hands-on-satubinha/common/key_name"
}
