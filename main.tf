# Provider Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Resources Block
resource "aws_instance" "TerraTest_instance" {
  ami             = "ami-0e731c8a588258d0d"
  instance_type   = "t2.micro"
  subnet_id = aws_subnet.TerraTest_subnet.id
  vpc_security_group_ids = [aws_security_group.TerraTest_SG.id]
  associate_public_ip_address = true
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 2" > index.html
              python3 -m http.server 8080 &
              EOF
  tags = {
    Name = "TerraTest_instance"
  }
}

resource "aws_s3_bucket" "TerraTestS3" {
  bucket_prefix = "terra-test-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "TerraTest_bucket_versioning" {
  bucket = aws_s3_bucket.TerraTestS3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "TerraTest_bucket_crypto_conf" {
  bucket = aws_s3_bucket.TerraTestS3.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_vpc" "TerraTest_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraTestTag"
  }
}

resource "aws_subnet" "TerraTest_subnet" {
  vpc_id     = aws_vpc.TerraTest_VPC.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "TerraTestTag"
  }
}

resource "aws_security_group" "TerraTest_SG" {
  name        = "Terratest_SG"
  description = "SG for TerraTest EC2s"
  vpc_id      = aws_vpc.TerraTest_VPC.id
}

resource "aws_security_group_rule" "TerraTest_allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.TerraTest_SG.id

  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "TerraTest_allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.TerraTest_SG.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}