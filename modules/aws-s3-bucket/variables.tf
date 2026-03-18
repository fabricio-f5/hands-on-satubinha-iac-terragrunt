variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "acl" {
  description = "ACL do bucket"
  type        = string
  default     = "private"
}
