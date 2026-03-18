resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.ami_id.value
  instance_type          = var.instance_type
  key_name               = data.aws_ssm_parameter.key_name.value
  subnet_id              = data.aws_ssm_parameter.subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.security_group_id.value]
  iam_instance_profile   = var.iam_instance_profile

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name  = var.instance_name
  }
}
