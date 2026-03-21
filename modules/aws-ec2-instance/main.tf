resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.ami_id.value
  instance_type          = var.instance_type
  key_name               = data.aws_ssm_parameter.key_name.value
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  monitoring             = true # CKV_AWS_126 — detailed monitoring
  ebs_optimized          = true # CKV_AWS_135 — EBS optimized
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  root_block_device {
    encrypted = true
  }
  tags = {
    Name = var.instance_name
  }
}
