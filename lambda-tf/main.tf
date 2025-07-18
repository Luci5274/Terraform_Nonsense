terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Tells Terraform to use the official AWS provider
      version = "~> 6.0"        # Locks the provider to 6.x versions
    }
  }
  required_version = ">= 1.3.0" # Minimum Terraform version
}

provider "aws" {
  region = "us-east-1" # The AWS region to deploy the Lambda function in
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "MyTerraformLambda"                  # Name of the Lambda in AWS Console
  role          = aws_iam_role.lambda_exec_role.arn    # IAM Role ARN for Lambda to assume
  handler       = "lambda_function.lambda_handler"     # File and function name to call
  runtime       = "python3.9"                          # Language runtime to use
  filename      = "${path.module}/lambda_function.zip" # Path to the ZIP package

  # This ensures Terraform knows when the zip file has changed and should redeploy
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  tags = {
    Environment = "dev" # Optional metadata
    Owner       = "you"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4  # Generates 8 hex characters
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "my-terraform-bucket${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Environment = "dev" # Optional metadata
    Owner       = "you"
  }
}