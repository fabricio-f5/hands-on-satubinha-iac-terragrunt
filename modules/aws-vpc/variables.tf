variable "name" {
  type        = string
  description = "Nome base dos recursos"
}

variable "environment" {
  type        = string
  description = "Ambiente: dev, staging ou prod"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block da VPC (ex: 10.0.0.0/16)"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block da subnet pública (ex: 10.0.1.0/24)"
}

variable "availability_zone" {
  type        = string
  description = "AZ onde a subnet será criada (ex: us-east-1a)"
}
