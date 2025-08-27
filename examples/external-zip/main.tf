provider "aws" {
  region = "ap-southeast-2"
}

# Generate a random suffix for uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  tags = {
    Environment = "dev"
    Project     = "example-project"
    Example     = "external-zip"
  }
}

# Example 1: Lambda function using zip_source_url to download from GitHub releases
# This demonstrates the new functionality where the module automatically:
# 1. Downloads the zip from the HTTP URL
# 2. Creates an S3 bucket
# 3. Uploads the zip to S3
# 4. Uses the uploaded S3 details for the Lambda function
module "lambda_rust_http" {
  source = "../../"

  function_name = "rust-http-${random_string.suffix.result}"
  package_type  = "Zip"

  # This is the key new feature - provide an HTTP URL to download the zip
  zip_source_url = "https://github.com/serverlessia/lambda-rust-http/archive/refs/tags/latest.zip"

  # For Rust Lambda functions, the handler and runtime are specific
  handler = "bootstrap"    # Rust Lambda functions use "bootstrap" as handler
  runtime = "provided.al2" # Custom runtime for Rust

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  # Rust Lambda functions typically need more memory and timeout
  memory_size = 512
  timeout     = 30

  environment_variables = {
    ENVIRONMENT = local.tags.Environment
    PROJECT     = local.tags.Project
    RUNTIME     = "rust"
  }

  tags = local.tags
}

# Example 2: Another Lambda function using a different external zip source
# This shows how you can easily deploy multiple functions from different sources
# Note: Replace the URL below with a real, valid zip file URL
# module "lambda_another_external" {
#   source = "../../"
#
#   function_name = "another-external-${random_string.suffix.result}"
#   package_type  = "Zip"
#
#   # You can use any HTTP URL that serves a zip file
#   zip_source_url = "https://example.com/another-function.zip"
#
#   handler = "index.handler"
#   runtime = "nodejs20.x"
#
#   policy_arns = [
#     "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   ]
#
#   tags = local.tags
# }

# Outputs to show the created resources
output "lambda" {
  value = module.lambda
}

# output "lambda_another_external" {
#   description = "Another external Lambda function details"
#   value = {
#     function_name     = module.lambda_another_external.name
#     function_arn      = module.lambda_another_external.arn
#     latest_version    = module.lambda_another_external.latest_version
#     s3_bucket         = module.lambda_another_external.zip_source_s3_bucket
#     s3_key            = module.lambda_another_external.zip_source_s3_key
#     s3_object_version = module.lambda_another_external.zip_source_s3_object_version
#   }
# }
