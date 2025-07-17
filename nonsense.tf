# Specify the Terraform version and required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"    # The official AWS provider maintained by HashiCorp
      version = "~> 6.0"           # Use AWS provider version 6.x (any patch version)
      # 🔧 You may change this if a different AWS provider version is required by your organization
    }
  }
  required_version = ">= 1.3.0"    # This configuration requires Terraform 1.3.0 or newer
  # 🔧 Raise this version if you use newer Terraform language features
}

# Define the AWS provider region and credentials (assumes env vars or profile)
provider "aws" {
  region = "us-east-1"             # Sets the AWS region to deploy resources (change as needed)
  # 🔧 Change to your desired AWS region (e.g., "us-west-2", "eu-central-1", etc.)
}

# Generate a unique suffix to avoid naming collisions (optional)
resource "random_id" "suffix" {
  byte_length = 4                  # The number of random bytes to generate (produces 8 hex chars)
  # 🔧 You can increase this for a longer suffix, but 4 is usually sufficient for uniqueness
}

# Create an S3 bucket for storing Lambda code or other data
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "prnakl6-lambda-bucket-${random_id.suffix.hex}"  # Bucket name with a random suffix to avoid global name conflicts
  # 🔧 You can change the prefix "prnakl6-lambda-bucket" to better match your naming standards

  tags = {
    Project = "PRNAKL-6"           # Tags are used for metadata — helpful for cost tracking
    Purpose = "Store Lambda Function Code"
    # 🔧 Add more tags if needed for compliance, billing, or automation
  }
}

# Archive the Lambda function code from a local folder
data "archive_file" "lambda_zip" {
  type        = "zip"                                     # Specifies the archive format as ZIP
  source_dir  = "${path.module}/lambda"                   # Path to the folder containing Lambda code (e.g., index.js or main.py)
  output_path = "${path.module}/lambda_function.zip"      # Where to output the zipped file
  # 🔧 Change `source_dir` if your Lambda source code is in a different folder name or structure
  # 🔧 Change `output_path` if you want the zip to be named differently
}

# Upload the zipped Lambda function code to S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id                 # ID of the target S3 bucket
  key    = "lambda_function.zip"                          # S3 object key (name of the uploaded file)
  source = data.archive_file.lambda_zip.output_path       # Path to the zip file generated earlier
  etag   = filemd5(data.archive_file.lambda_zip.output_path) # Ensures file is only uploaded if contents change
  # 🔧 Change `key` if you want to store the Lambda code under a different name or folder in S3
}

# Create the IAM role for Lambda to execute
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_prnakl6"                       # Name of the IAM role
  # 🔧 Change the name to match your organization’s IAM role naming standards

  assume_role_policy = jsonencode({                       # Inline policy document written in JSON
    Version = "2012-10-17",                               # IAM policy version format
    Statement = [{
      Action    = "sts:AssumeRole",                       # Allows the Lambda service to assume this role
      Effect    = "Allow",                                # Explicitly allows the action
      Principal = {
        Service = "lambda.amazonaws.com"                  # Specifies that Lambda can assume the role
        # 🔧 Add additional services here if you need to reuse this role across other services
      }
    }]
  })
}

# Attach AWSLambdaBasicExecutionRole for CloudWatch logs
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec_role.name         # The IAM role to attach the policy to
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  # 🔧 You can attach additional policies if your Lambda function requires more permissions
}

# Create the Lambda function
resource "aws_lambda_function" "example" {
  function_name = "prnakl6_lambda"                        # Name of the Lambda functi
