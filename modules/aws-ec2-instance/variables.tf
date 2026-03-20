variable "instance_type" {
  description = "Tipo da instância EC2. Ex: t3.micro, t3.small"
  type        = string
  default     = "t3.micro"
}
variable "instance_name" {
  description = "Nome da instância — aplicado na tag Name"
  type        = string
}
variable "iam_instance_profile" {
  description = "Nome do Instance Profile a associar à EC2. Recebido do módulo aws-iam-ec2. Null = sem role IAM."
  type        = string
  default     = null
}
variable "environment" {
  description = "Nome do ambiente. Ex: dev, staging, prod"
  type        = string
}
variable "subnet_id" {
  description = "ID da subnet onde a instância será criada. Injectado pelo dependency block do Terragrunt."
  type        = string
}
variable "security_group_id" {
  description = "ID do Security Group a associar à instância. Injectado pelo dependency block do Terragrunt."
  type        = string
}
