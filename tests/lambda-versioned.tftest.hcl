run "test_lambda_versioned" {
  variables {
    function_name = "test-lambda-versioned"
    handler       = "hello.handler"
    runtime       = "nodejs20.x"

    s3_bucket         = "test-bucket"
    s3_key            = "test-function.zip"
    s3_object_version = "test-version"

    policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]

    tags = {
      Environment = "test"
      Project     = "test"
    }
  }

  command = plan

  # Assertions for Lambda Function
  assert {
    condition     = aws_lambda_function.this.function_name == "test-lambda-versioned"
    error_message = "Lambda function name does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.handler == "hello.handler"
    error_message = "Lambda handler does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.runtime == "nodejs20.x"
    error_message = "Lambda runtime does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.s3_bucket == "test-bucket"
    error_message = "Lambda S3 bucket does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.s3_key == "test-function.zip"
    error_message = "Lambda S3 key does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.s3_object_version == "test-version"
    error_message = "Lambda S3 object version does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.timeout == 3
    error_message = "Lambda timeout should be 3 seconds."
  }

  assert {
    condition     = aws_lambda_function.this.memory_size == 128
    error_message = "Lambda memory size should be 128 MB."
  }

  assert {
    condition     = aws_lambda_function.this.reserved_concurrent_executions == -1
    error_message = "Lambda reserved concurrent executions should be -1."
  }
}
