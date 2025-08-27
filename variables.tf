variable "function_name" {
  description = "Name of the Lambda function"
  type        = string

  validation {
    condition     = length(var.function_name) > 0
    error_message = "Function name must not be empty."
  }
}

variable "handler" {
  description = "Lambda function handler (required for zip package type)"
  type        = string
  default     = null
}

variable "runtime" {
  description = "Lambda function runtime (required for zip package type)"
  type        = string
  default     = null
}

variable "package_type" {
  description = "Lambda deployment package type. Valid values are Zip and Image"
  type        = string
  default     = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "Package type must be either 'Zip' or 'Image'."
  }
}

# Zip package configuration
variable "s3_bucket" {
  description = "S3 bucket containing the Lambda function code (required for zip package type)"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the Lambda function code (required for zip package type)"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the Lambda function code (required for zip package type)"
  type        = string
  default     = null
}

variable "zip_source_url" {
  description = "HTTP URL to download the zip file from. If provided, supersedes manual S3 configuration for zip package type"
  type        = string
  default     = null
}

# Image package configuration
variable "image_uri" {
  description = "ECR image URI containing the function's deployment package (required for image package type)"
  type        = string
  default     = null
}

# Common Lambda configuration
variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = null
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128

  validation {
    condition     = contains([128, 256, 512, 1024, 2048, 3008], var.memory_size)
    error_message = "Memory size must be one of the supported values: 128, 256, 512, 1024, 2048, 3008."
  }
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt environment variables"
  type        = string
  default     = null
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "file_system_config" {
  description = "File system configuration for the Lambda function"
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

variable "tracing_config" {
  description = "Tracing configuration for the Lambda function"
  type = object({
    mode = string
  })
  default = null

  validation {
    condition     = var.tracing_config == null ? true : contains(["Active", "PassThrough", "Disabled"], var.tracing_config.mode)
    error_message = "If provided, tracing_config.mode must be one of: Active, PassThrough, Disabled."
  }
}

variable "reserved_concurrent_executions" {
  description = "Number of reserved concurrent executions for the Lambda function (-1 disables)"
  type        = number
  default     = -1
  validation {
    condition     = var.reserved_concurrent_executions >= -1
    error_message = "Reserved concurrency must be -1 (disabled) or a non-negative number."
  }
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the Lambda function role"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.policy_arns :
      can(regex("^arn:aws:iam::(aws|\\d{12}):policy/", arn))
    ])
    error_message = "Each policy ARN must be a valid AWS or account-scoped IAM policy ARN."
  }
}

variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}
