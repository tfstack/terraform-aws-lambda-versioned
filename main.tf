data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  # Validate package type specific requirements
  validate_zip_package = var.package_type == "Zip" ? (
    var.handler != null &&
    var.runtime != null &&
    var.s3_bucket != null &&
    var.s3_key != null &&
    var.s3_object_version != null
  ) : true

  validate_image_package = var.package_type == "Image" ? (
    var.image_uri != null
  ) : true

  # Generate VPC policy IDs when VPC config is provided (EC2 condition keys expect raw IDs, not ARNs)
  vpc_policy_subnet_ids         = var.vpc_config != null ? var.vpc_config.subnet_ids : []
  vpc_policy_security_group_ids = var.vpc_config != null ? var.vpc_config.security_group_ids : []

  vpc_arn = var.vpc_config != null ? "arn:aws:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:vpc/${var.vpc_config.vpc_id}" : null
}

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_policies" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count = var.vpc_config != null ? 1 : 0

  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  publish       = true

  # Package type specific configuration
  package_type = var.package_type
  handler      = var.handler
  runtime      = var.runtime
  image_uri    = var.image_uri

  # S3 configuration for zip package
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  # Common configuration
  description                    = var.description
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [var.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config != null ? [var.tracing_config] : []
    content {
      mode = tracing_config.value.mode
    }
  }

  kms_key_arn = var.kms_key_arn

  tags = var.tags

  # Ensure proper cleanup of VPC resources
  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_access
  ]

  lifecycle {
    # Validate package type specific requirements
    precondition {
      condition     = local.validate_zip_package
      error_message = "For Zip package type, handler, runtime, s3_bucket, s3_key, and s3_object_version are required."
    }
    precondition {
      condition     = local.validate_image_package
      error_message = "For Image package type, image_uri is required."
    }
  }
}

# Function URL for HTTP access
resource "aws_lambda_function_url" "this" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_authorization_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_origins     = cors.value.allow_origins
      allow_methods     = cors.value.allow_methods
      allow_headers     = cors.value.allow_headers
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
    }
  }
}
