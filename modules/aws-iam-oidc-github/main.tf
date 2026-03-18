# OIDC Provider  registra o GitHub como IdP confiável na conta AWS

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # "sts.amazonaws.com" é o audience que o GitHub envia no JWT
  # A AWS valida esse valor contra o campo "aud" do token
  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint do certificado TLS do endpoint do GitHub
  # Usado pela AWS para validar a cadeia de confiança do OIDC
  thumbprint_list = var.thumbprint_list

  tags = {
    Name = "github-actions-oidc-provider"
  }

  lifecycle {
    prevent_destroy = true  # ← impede destroy acidental
  }
}


# IAM Role  assumida pelo GitHub Actions via OIDC

resource "aws_iam_role" "github_actions" {
  name        = var.role_name
  description = "Role assumida pelo GitHub Actions via OIDC  repo: ${var.github_repo}"
  path        = "/ci/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubOIDC"
        Effect = "Allow"
        Principal = {
          # Referência direta ao provider criado acima
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # "aud"  valida que o token foi emitido para a AWS
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # "sub"  restringe ao repo e ref configurados
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:${var.github_ref}"
          }
        }
      }
    ]
  })

  tags = {
    Name = var.role_name
  }
}

# -----------------------------------------------------------------------------
# Policy Attachments  permissões que o GitHub Actions terá na AWS
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "extra_policies" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}
