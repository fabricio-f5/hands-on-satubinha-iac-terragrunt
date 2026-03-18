
module "github_oidc" {
  source = "../modules/aws-iam-oidc-github"

  github_repo     = var.github_repo
  github_ref      = var.github_ref
  role_name       = var.role_name
  policy_arns     = var.policy_arns
  thumbprint_list = var.thumbprint_list
}
