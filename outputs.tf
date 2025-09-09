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

output "function_url" {
  description = "Function URL for HTTP access"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}
