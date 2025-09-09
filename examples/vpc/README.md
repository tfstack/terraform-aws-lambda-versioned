# VPC Lambda Example

Example demonstrating Lambda deployment within a VPC using the `terraform-aws-lambda-versioned` module.

## What it creates

- VPC with public and private subnets across 3 AZs
- NAT Gateway for outbound internet access
- Lambda function deployed in private subnets
- Function URL for HTTP access
- Jumphost for VPC connectivity testing

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Testing

```bash
# Get Lambda Function URL
terraform output lambda

# Test via Function URL
curl $(terraform output -raw lambda_function_url)
```

## VPC Access

- **Function URL**: Internet-accessible (public)
- **Lambda in VPC**: Private subnets, internet via NAT Gateway
- **VPC-only access**: Set `create_function_url = false`

## Cleanup

```bash
terraform destroy
```
