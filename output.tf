output "instance_id" {
  description = "ID of the instance"
  value       = aws_instance.TerraTest_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of EC2 Insatnce"
  value       = aws_instance.TerraTest_instance.public_ip
}

output "S3_bucket" {
  description = "S3 Bucket Domain Name"
  value       = aws_s3_bucket.TerraTestS3.bucket_domain_name
}