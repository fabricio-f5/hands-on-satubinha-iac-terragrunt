variable "key_name" {
  description = "Nome do Key Pair na AWS"
  type        = string
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH. Ex: 'ssh-ed25519 AAAA...'"
  type        = string
  sensitive   = true
}
