# Outputs do módulo aws-iam-ec2
# O instance_profile_name é o valor que o módulo aws-ec2-instance precisa

output "instance_profile_name" {
  description = "Nome do Instance Profile — passar para var.iam_instance_profile no módulo aws-ec2-instance"
  value       = aws_iam_instance_profile.ec2.name
}

output "role_arn" {
  description = "ARN da IAM Role da EC2"
  value       = aws_iam_role.ec2.arn
}

output "role_name" {
  description = "Nome da IAM Role da EC2"
  value       = aws_iam_role.ec2.name
}
