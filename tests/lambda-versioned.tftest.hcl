run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "test_lambda_versioned" {
  variables {
    function_name = "test-${run.setup.suffix}"
    handler       = "hello.handler"
    runtime       = "nodejs20.x"

    s3_bucket         = run.setup.s3_bucket
    s3_key            = run.setup.s3_key
    s3_object_version = run.setup.s3_object_version

    policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]

    tags = {
      Environment = "test"
      Project     = "test"
    }
  }

  # Assertions for Lambda Function
  assert {
    condition     = aws_lambda_function.this.function_name == "test-${run.setup.suffix}"
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
    condition     = aws_lambda_function.this.s3_bucket == run.setup.s3_bucket
    error_message = "Lambda S3 bucket does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.s3_key == run.setup.s3_key
    error_message = "Lambda S3 key does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.s3_object_version == run.setup.s3_object_version
    error_message = "Lambda S3 object version does not match expected value."
  }

  assert {
    condition     = length(aws_lambda_function.this.tags) > 0
    error_message = "Lambda function should have tags."
  }

  assert {
    condition     = aws_lambda_function.this.tags["Environment"] == "test"
    error_message = "Lambda tag 'Environment' does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.this.tags["Project"] == "test"
    error_message = "Lambda tag 'Project' does not match expected value."
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
    condition     = aws_lambda_function.this.role != ""
    error_message = "Lambda function role should not be empty."
  }
}
