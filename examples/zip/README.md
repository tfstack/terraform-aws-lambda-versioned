# Terraform AWS Lambda Zip Deployment Example

This example demonstrates how to deploy an AWS Lambda function using a zip package from S3, with versioning support.

## Features

- **S3 Deployment**: Deploys Lambda function code from an S3 bucket
- **Versioning**: Supports S3 object versioning for rollback capabilities
- **IAM Roles**: Configures execution role with basic Lambda permissions
- **Environment Variables**: Supports custom environment variables
- **Resource Limits**: Configurable timeout and memory settings
- **Tagging**: Supports custom resource tagging

## Usage

### **Initialize and Apply**

```bash
terraform init
terraform plan
terraform apply
```

### **Destroy Resources**

```bash
terraform destroy
```

> **Warning:** Running this example creates AWS resources that incur costs.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `function_name` | Name of the Lambda function | `string` | Required |
| `handler` | Function entrypoint | `string` | Required |
| `runtime` | Lambda runtime | `string` | Required |
| `s3_bucket` | S3 bucket containing function code | `string` | Required |
| `s3_key` | S3 key of function code | `string` | Required |
| `s3_object_version` | Version ID of S3 object | `string` | Required |
| `policy_arns` | List of IAM policy ARNs to attach | `list(string)` | `[]` |
| `timeout` | Function timeout in seconds | `number` | `3` |
| `memory_size` | Function memory in MB | `number` | `128` |
| `environment_variables` | Environment variables for function | `map(string)` | `{}` |
| `tags` | Resource tags | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Name of the Lambda function |
| `function_arn` | ARN of the Lambda function |
| `function_invoke_arn` | Invoke ARN of the Lambda function |
| `role_arn` | ARN of the Lambda execution role |

## Resources Created

- **Lambda Function** with zip package deployment
- **IAM Role** for Lambda execution
- **IAM Policy Attachments** for Lambda permissions
- **CloudWatch Log Group** for function logs

This example provides a **complete Lambda deployment** with versioning support using S3.
