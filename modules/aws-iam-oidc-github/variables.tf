
# Variáveis do módulo aws-iam-oidc-github

variable "github_repo" {
  description = "Repositório GitHub no formato 'org/repo'. Ex: fabricio-f5/hands-on-satubinha-iac"
  type        = string

  validation {
    condition     = can(regex("^[\\w.-]+/[\\w.-]+$", var.github_repo))
    error_message = "O formato deve ser 'org/repo'. Ex: fabricio-f5/meu-repo"
  }
}

variable "github_ref" {
  description = <<-EOT
    Restrição de ref para a Condition do OIDC.
    Use "*" para permitir qualquer branch/tag (ambientes dev/staging).
    Use "ref:refs/heads/main" para travar apenas na main (produção).
  EOT
  type        = string
  default     = "*"

  validation {
    condition     = var.github_ref == "*" || can(regex("^ref:refs/(heads|tags)/[\\w./-]+$", var.github_ref))
    error_message = "Use '*' ou o formato 'ref:refs/heads/<branch>' / 'ref:refs/tags/<tag>'"
  }
}

variable "role_name" {
  description = "Nome da IAM Role criada para o GitHub Actions"
  type        = string
  default     = "github-actions-oidc-role"
}

variable "policy_arns" {
  description = "Lista de ARNs de policies gerenciadas a anexar à Role"
  type        = list(string)
  default     = []

}

variable "thumbprint_list" {
  description = ""
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
