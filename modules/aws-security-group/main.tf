resource "aws_security_group" "this" {
  name        = var.name
  description = "Security group for EC2 with SSH and internal TLS"
  vpc_id      = var.vpc_id
  tags = {
    Name = var.name
  }

  #checkov:skip=CKV_AWS_24:SSH aberto necessário - IP dinâmico 5G impede restrição por CIDR
  ingress {
    description      = "SSH access from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Entrada TLS interno VPC IPv4
  ingress {
    description      = "TLS from VPC IPv4"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
  }

  # Entrada TLS interno VPC IPv6
  ingress {
    description      = "TLS from VPC IPv6"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
  }

  #checkov:skip=CKV_AWS_382:Egress total necessário - ambiente de estudo com IP dinâmico (5G), restrição por destino não é viável
  egress {
    description = "All outbound IPv4 traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #checkov:skip=CKV_AWS_382:Egress total necessário - ambiente de estudo com IP dinâmico (5G), restrição por destino não é viável
  egress {
    description      = "All outbound IPv6 traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}
