locals {
  # Validate package type specific requirements
  validate_zip_package = var.package_type == "Zip" ? (
    var.handler != null &&
    var.runtime != null &&
    (
      (var.zip_source_url != null) ||
      (var.s3_bucket != null && var.s3_key != null && var.s3_object_version != null)
    )
  ) : true

  validate_image_package = var.package_type == "Image" ? (
    var.image_uri != null
  ) : true

  # Check if using zip source URL (supersedes manual S3 config)
  use_zip_source_url = var.package_type == "Zip" && var.zip_source_url != null

  # Generate unique suffix for S3 bucket when using zip source URL
  s3_bucket_suffix = var.package_type == "Zip" && var.zip_source_url != null ? random_string.s3_suffix[0].result : ""
}

# Random string for S3 bucket suffix when using zip source URL
resource "random_string" "s3_suffix" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  length  = 8
  special = false
  upper   = false
}

# S3 bucket for zip source URL downloads
resource "aws_s3_bucket" "zip_source" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  bucket = "lambda-zips-${local.s3_bucket_suffix}"

  tags = var.tags
}

# S3 bucket versioning for zip source URL downloads
resource "aws_s3_bucket_versioning" "zip_source" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  bucket = aws_s3_bucket.zip_source[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# HTTP data source to download zip
data "http" "zip" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  url = var.zip_source_url
  # request_headers = { Authorization = "Bearer ${var.token}" } # if needed
}

# Create cache directory
resource "null_resource" "cache_dir" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/.cache"
  }
}

# Stable on disk, changes when content/ETag changes
resource "local_file" "zip" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  content_base64 = data.http.zip[0].response_body_base64
  filename       = "${path.module}/.cache/pkg-${sha256(data.http.zip[0].response_body)}.zip"

  depends_on = [null_resource.cache_dir]
}

# Local file data source for the downloaded zip
data "local_file" "zip_data" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  filename = local_file.zip[0].filename
}

# External zip source object (download from URL, cache locally, then upload to S3)
resource "aws_s3_object" "external_zip_source" {
  count = var.package_type == "Zip" && var.zip_source_url != null ? 1 : 0

  bucket = aws_s3_bucket.zip_source[0].id
  key    = "function.zip"
  source = local_file.zip[0].filename
  etag   = md5(data.http.zip[0].response_body)
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
  s3_bucket         = local.use_zip_source_url ? try(aws_s3_bucket.zip_source[0].id, null) : var.s3_bucket
  s3_key            = local.use_zip_source_url ? try(aws_s3_object.external_zip_source[0].key, null) : var.s3_key
  s3_object_version = local.use_zip_source_url ? try(aws_s3_object.external_zip_source[0].version_id, null) : var.s3_object_version

  # Common configuration
  description                    = var.description
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  architectures                  = var.architectures

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

  # Validate package type specific requirements
  lifecycle {
    precondition {
      condition     = local.validate_zip_package
      error_message = "For Zip package type, handler and runtime are required, and either zip_source_url OR (s3_bucket, s3_key, and s3_object_version) must be provided."
    }
    precondition {
      condition     = local.validate_image_package
      error_message = "For Image package type, image_uri is required."
    }
  }
}
