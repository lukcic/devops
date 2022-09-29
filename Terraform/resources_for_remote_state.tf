terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.14.0"
    }
  }
  backend "s3" { // this backend is used for storing tf state in s3 bucket
    bucket = "lukcic-terraform-up-and-running-state"
    key    = "global/s3/terrafrom.tfstate"
    region = "eu-central-1"

    dynamodb_table = "terraform-up-and-running-locks" // this table stores information about locks on infrastructure
    encrypt        = true
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "lukcic"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket|

resource "aws_s3_bucket" "terraform_state" {
  bucket = "lukcic-terraform-up-and-running-state" # globally unique bucket name

}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = "lukcic-terraform-up-and-running-state"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = "lukcic-terraform-up-and-running-state"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" { // this is the sample output that shows some informations about created infrastructure
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}