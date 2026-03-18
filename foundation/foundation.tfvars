environment = "foundation"
region      = "us-east-1"
github_repo = "fabricio-f5/hands-on-satubinha-iac-terragrunt"
github_ref  = "ref:refs/heads/main"
role_name   = "github-actions-oidc-role"
policy_arns = [
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  "arn:aws:iam::aws:policy/IAMFullAccess",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
]
