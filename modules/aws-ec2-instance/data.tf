# data.tf
# ------------------------------------------------------------
# Lê configuração de infraestrutura do SSM Parameter Store.
# Evita hardcode de IDs específicos de conta/região.
# ------------------------------------------------------------

data "aws_ssm_parameter" "ami_id" {
  name = "/hands-on-satubinha/common/ami_id"
}

data "aws_ssm_parameter" "subnet_id" {
  name = "/hands-on-satubinha/common/subnet_id"
}

data "aws_ssm_parameter" "security_group_id" {
  name = "/hands-on-satubinha/common/security_group_id"
}

data "aws_ssm_parameter" "key_name" {
  name = "/hands-on-satubinha/common/key_name"
}