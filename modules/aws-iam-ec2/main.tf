# IAM Role — assumida pela EC2 via Instance Profile

resource "aws_iam_role" "ec2" {
  name        = "${var.instance_name}-ec2-role"
  description = "Role da EC2 ${var.instance_name}  permite pull de imagens no ECR"
  path        = "/ec2/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.instance_name}-ec2-role"
  }
}


# Policy Attachments  permissões da EC2

resource "aws_iam_role_policy_attachment" "policies" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.ec2.name
  policy_arn = each.value
}


# Instance Profile  wrapper obrigatório para associar a Role à EC2
# A EC2 não referencia a Role diretamente  sempre via Instance Profile

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.instance_name}-instance-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name = "${var.instance_name}-instance-profile"
  }
}
