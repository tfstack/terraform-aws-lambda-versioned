# terraform-aws-lambda-versioned

Terraform module for versioned AWS Lambda deployments supporting both zip packages from S3 and container images from ECR.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_function_url"></a> [create\_function\_url](#input\_create\_function\_url) | Whether to create a Function URL for HTTP access | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Lambda function | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_file_system_config"></a> [file\_system\_config](#input\_file\_system\_config) | File system configuration for the Lambda function | <pre>object({<br/>    arn              = string<br/>    local_mount_path = string<br/>  })</pre> | `null` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_function_url_authorization_type"></a> [function\_url\_authorization\_type](#input\_function\_url\_authorization\_type) | Authorization type for Function URL | `string` | `"NONE"` | no |
| <a name="input_function_url_cors"></a> [function\_url\_cors](#input\_function\_url\_cors) | CORS configuration for Function URL | <pre>object({<br/>    allow_credentials = optional(bool, false)<br/>    allow_origins     = optional(list(string), ["*"])<br/>    allow_methods     = optional(list(string), ["*"])<br/>    allow_headers     = optional(list(string), ["date", "keep-alive"])<br/>    expose_headers    = optional(list(string), ["date", "keep-alive"])<br/>    max_age           = optional(number, 86400)<br/>  })</pre> | `null` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Lambda function handler (required for zip package type) | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR image URI containing the function's deployment package (required for image package type) | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used to encrypt environment variables | `string` | `null` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory size in MB | `number` | `128` | no |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | Lambda deployment package type. Valid values are Zip and Image | `string` | `"Zip"` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of IAM policy ARNs to attach to the Lambda function role | `list(string)` | `[]` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Number of reserved concurrent executions for the Lambda function (-1 disables) | `number` | `-1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda function runtime (required for zip package type) | `string` | `null` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket containing the Lambda function code (required for zip package type) | `string` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key of the Lambda function code (required for zip package type) | `string` | `null` | no |
| <a name="input_s3_object_version"></a> [s3\_object\_version](#input\_s3\_object\_version) | S3 object version of the Lambda function code (required for zip package type) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Lambda function | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout in seconds | `number` | `3` | no |
| <a name="input_tracing_config"></a> [tracing\_config](#input\_tracing\_config) | Tracing configuration for the Lambda function | <pre>object({<br/>    mode = string<br/>  })</pre> | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for the Lambda function | <pre>object({<br/>    vpc_id             = string<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | Invoke ARN of the Lambda function |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | Function URL for HTTP access |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the Lambda IAM role |
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | Latest published version of the Lambda function |
| <a name="output_name"></a> [name](#output\_name) | Name of the Lambda function |
<!-- END_TF_DOCS -->
