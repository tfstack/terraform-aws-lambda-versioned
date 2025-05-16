# Terraform AWS Lambda Container Image Deployment Example

This example demonstrates how to deploy an AWS Lambda function using a container image from ECR, with versioning support.

## Features

- **Container Deployment**: Deploys Lambda function using container images
- **ECR Integration**: Uses ECR for container image storage
- **IAM Roles**: Configures execution role with Lambda and ECR permissions
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
| `package_type` | Lambda package type | `string` | `"Image"` |
| `image_uri` | URI of the container image | `string` | Required |
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

- **Lambda Function** with container image deployment
- **IAM Role** for Lambda execution
- **IAM Policy Attachments** for Lambda and ECR permissions
- **CloudWatch Log Group** for function logs

This example provides a **complete Lambda deployment** using container images from ECR.
