output "instance_id" {
  description = "ID da instância EC2 criada"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "IP privado da instância EC2"
  value       = aws_instance.main.private_ip
}

