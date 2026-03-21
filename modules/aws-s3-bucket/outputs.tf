output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "logs_bucket_id" {
  value = aws_s3_bucket.logs.id
}