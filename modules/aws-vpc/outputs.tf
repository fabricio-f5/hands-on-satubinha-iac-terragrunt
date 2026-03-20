output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.public.id
}
