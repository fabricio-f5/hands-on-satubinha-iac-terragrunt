
# Variáveis do módulo aws-iam-ec2

variable "instance_name" {
  description = "Nome da instância EC2 — usado como prefixo nos recursos IAM"
  type        = string

}

variable "policy_arns" {
  description = <<-EOT
    Lista de ARNs de policies gerenciadas a anexar à Role da EC2.
    Padrão mínimo: ECRReadOnly (apenas pull de imagens).
    Adicione outras policies conforme necessidade da aplicação.
  EOT
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]

  # Exemplos de policies comuns para EC2:
  # "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"  → acesso via SSM Session Manager (sem SSH)
  # "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"   → envio de métricas/logs pro CloudWatch
  # "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"        → leitura de buckets S3
}
