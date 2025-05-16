terraform {
  required_version = ">= 1.0"
}

# Generate a random suffix for uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
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
}

resource "aws_s3_object" "hello" {
  bucket = module.s3_bucket.bucket_id
  key    = "hello.zip"
  source = data.archive_file.hello.output_path
  etag   = data.archive_file.hello.output_md5
}


# Output suffix for use in tests
output "suffix" {
  value = random_string.suffix.result
}

output "s3_bucket" {
  value = module.s3_bucket.bucket_id
}

output "s3_key" {
  value = aws_s3_object.hello.key
}

output "s3_object_version" {
  value = aws_s3_object.hello.version_id
}
