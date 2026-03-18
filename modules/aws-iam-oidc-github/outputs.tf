
# Outputs do módulo aws-iam-oidc-github

output "role_arn" {
  description = "ARN da IAM Role — usado no campo 'role-to-assume' do workflow"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "Nome da IAM Role criada"
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "ARN do OIDC Provider registrado na conta AWS"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "oidc_provider_url" {
  description = "URL do OIDC Provider"
  value       = aws_iam_openid_connect_provider.github.url
}
