output "key_name" {
  description = "Nome da key pair criada"
  value       = aws_key_pair.this.key_name
}
