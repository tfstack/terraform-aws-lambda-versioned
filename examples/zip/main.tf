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
  }
}

# Convert code to zip file
data "archive_file" "hello" {
  type        = "zip"
  output_path = "${path.module}/external/hello.zip"

  source {
    content  = file("${path.module}/external/lambda/hello.js")
    filename = "hello.js"
  }
}

module "s3_bucket" {
  source = "tfstack/s3/aws"

  bucket_name       = "lambda-zips"
  bucket_suffix     = random_string.suffix.result
  enable_versioning = true

  tags = local.tags
}

resource "aws_s3_object" "hello" {
  bucket = module.s3_bucket.bucket_id
  key    = "hello.zip"
  source = data.archive_file.hello.output_path
  etag   = data.archive_file.hello.output_md5
}

module "lambda" {
  source = "../../"

  function_name = "hello-${random_string.suffix.result}"
  handler       = "hello.handler"
  runtime       = "nodejs20.x"

  s3_bucket         = module.s3_bucket.bucket_id
  s3_key            = aws_s3_object.hello.key
  s3_object_version = aws_s3_object.hello.version_id

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  environment_variables = {
    ENVIRONMENT = local.tags.Environment
  }

  tags = local.tags
}

output "lambda" {
  value = module.lambda
}
