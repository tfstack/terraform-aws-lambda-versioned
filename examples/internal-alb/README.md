# Internal ALB Lambda Example

Example demonstrating Lambda deployment within a VPC using an internal Application Load Balancer (ALB) with the `terraform-aws-lambda-versioned` module.

## What it creates

- VPC with public and private subnets across 3 AZs
- NAT Gateway for outbound internet access
- Internal Application Load Balancer (ALB) in private subnets
- Lambda function deployed in private subnets
- Lambda function accessible only via internal ALB
- Jumphost for VPC connectivity testing

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Testing

```bash
# Get ALB DNS name
terraform output

# Test via internal ALB (requires VPC access)
curl internal-cltest1-<suffix>-<random>.ap-southeast-2.elb.amazonaws.com

# Access via jumphost (SSM Session Manager)
aws ssm start-session --target <instance-id>
```

## VPC Access

- **Internal ALB**: Private subnets only, not internet-accessible
- **Lambda in VPC**: Private subnets, internet via NAT Gateway
- **Access via Jumphost**: SSM Session Manager to jumphost, then curl ALB endpoint
- **No Function URL**: Lambda is not directly accessible from internet

## Security Features

- Lambda function is completely isolated from internet
- Only accessible through internal ALB
- ALB restricted to VPC CIDR blocks only
- Jumphost provides secure access to test Lambda functionality

## Cleanup

```bash
terraform destroy
```
