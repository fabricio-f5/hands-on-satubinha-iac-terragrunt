variable "name" {
  type        = string
  description = "Name of the security group"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID to create SG in"
}
variable "environment" {
  type        = string
  description = "Nome do ambiente. Ex: dev, staging, prod"
}
