# External Zip Example

This example demonstrates the new `zip_source_url` functionality of the terraform-aws-lambda-versioned module.

## What This Example Shows

The `zip_source_url` feature allows you to deploy Lambda functions directly from HTTP URLs without manually managing S3 buckets and uploads. When you provide a `zip_source_url`, the module automatically:

1. **Downloads the zip file** from the HTTP URL
2. **Creates an S3 bucket** with versioning enabled
3. **Uploads the zip** to S3
4. **Deploys the Lambda** using the uploaded S3 details

## Key Benefits

- **Simplified deployment** - no need to manage S3 buckets manually
- **Direct from source** - deploy from GitHub releases, artifact repositories, etc.
- **Automatic versioning** - S3 bucket versioning ensures deployment consistency
- **Zero configuration** - just provide the URL and let the module handle the rest

## Examples Included

### 1. Rust HTTP Lambda Function

```hcl
module "lambda_rust_http" {
  source = "../../"

  function_name = "rust-http-${random_string.suffix.result}"
  package_type  = "Zip"

  # Download from GitHub releases
  zip_source_url = "https://github.com/serverlessia/lambda-rust-http/archive/refs/tags/latest.zip"

  handler = "bootstrap"  # Rust Lambda handler
  runtime = "provided.al2"  # Custom runtime for Rust

  memory_size = 512
  timeout     = 30
}
```

### 2. Generic External Function

```hcl
module "lambda_another_external" {
  source = "../../"

  function_name = "another-external-${random_string.suffix.result}"
  package_type  = "Zip"

  # Any HTTP URL serving a zip file
  zip_source_url = "https://example.com/another-function.zip"

  handler = "index.handler"
  runtime = "nodejs20.x"
}
```

## How It Works

When `zip_source_url` is provided:

1. **HTTP Download**: Uses Terraform's `http` data source to download the zip
2. **S3 Creation**: Creates a unique S3 bucket with versioning enabled
3. **Direct Upload**: Uploads the zip content directly to S3 (no temporary files)
4. **Lambda Deployment**: Uses the uploaded S3 details for the Lambda function

## Supported Sources

- **GitHub Releases**: `https://github.com/user/repo/archive/refs/tags/v1.0.0.zip`
- **Artifact Repositories**: `https://repo.company.com/artifacts/function.zip`
- **CDN URLs**: `https://cdn.example.com/lambda-functions/app.zip`
- **Any HTTP endpoint** serving zip files

## Important Notes

- **Supersedes manual S3 config**: When `zip_source_url` is provided, it takes precedence over `s3_bucket`, `s3_key`, and `s3_object_version`
- **Automatic bucket naming**: S3 buckets are named `lambda-zips-{random-suffix}` for uniqueness
- **Versioning enabled**: All S3 buckets have versioning enabled for deployment consistency
- **No temporary files**: Zip content is uploaded directly to S3 from memory
- **⚠️ Real URLs required**: Always use real, valid zip file URLs. Placeholder URLs like `https://example.com/function.zip` will cause deployment failures

## Running This Example

```bash
cd examples/external-zip
terraform init
terraform plan
```

## Outputs

The example provides detailed outputs showing:

- Function details (name, ARN, version)
- Automatically created S3 resources (bucket, key, object version)

This demonstrates how the module handles all the complexity of S3 management when using external zip sources.
