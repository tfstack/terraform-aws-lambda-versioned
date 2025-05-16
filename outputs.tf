output "arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "latest_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda.arn
}
