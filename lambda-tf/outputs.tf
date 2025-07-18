# Outputs the name of the Lambda function
output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}

# Outputs the ARN (Amazon Resource Name) for use in other modules or services
output "lambda_arn" {
  value = aws_lambda_function.my_lambda.arn
}
