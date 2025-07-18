# This creates a new IAM role that Lambda will assume
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  # IAM policy document defining trust relationship (who can assume the role)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # Allows the service to assume this role
        Principal = {
          Service = "lambda.amazonaws.com" # Specifies that Lambda can assume the role
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

# Attach a managed policy to allow CloudWatch logging from Lambda
resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs"
  roles      = [aws_iam_role.lambda_exec_role.name] # Attach to the IAM role above
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}