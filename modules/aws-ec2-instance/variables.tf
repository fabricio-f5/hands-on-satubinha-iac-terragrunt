
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
