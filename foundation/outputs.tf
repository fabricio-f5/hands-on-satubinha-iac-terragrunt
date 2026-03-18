output "github_actions_role_arn" {
  description = "ARN da IAM Role do GitHub Actions — adicione como secret AWS_ROLE_ARN no repositório GitHub"
  value       = module.github_oidc.role_arn
}

output "oidc_provider_arn" {
  description = "ARN do OIDC Provider registrado na conta AWS"
  value       = module.github_oidc.oidc_provider_arn
}