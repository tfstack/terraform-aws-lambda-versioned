provider "aws" {
  region = "ap-southeast-2"
}

# Generate a random suffix for uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  repository_name = "demo-test"
  base_name       = "${local.repository_name}-${random_string.suffix.result}"
  app_name        = "hello"

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}

module "ecrbuild" {
  source = "tfstack/ecrbuild/aws"

  # Naming & Resource Identifiers
  repository_name         = local.repository_name
  app_name                = local.app_name
  suffix                  = random_string.suffix.result
  repository_force_delete = true

  # Application & Storage Configuration
  container_source_path  = "${path.module}/external/source"
  container_archive_path = "${path.module}/external"
  log_retention_days     = 30

  # CodeBuild Configuration
  codebuild_timeout          = 10
  codebuild_compute_type     = "BUILD_GENERAL1_SMALL"
  codebuild_image            = "aws/codebuild/standard:5.0"
  codebuild_environment_type = "LINUX_CONTAINER"
  codebuild_buildspec        = "buildspec.yml"

  codebuild_env_vars = {
    ENVIRONMENT = "dev"
    PROJECT     = "example-project"
  }

  # CodePipeline Configuration
  codepipeline_stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "S3-Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "S3"
          version          = "1"
          output_artifacts = ["source-output"]
          configuration = {
            S3Bucket             = local.base_name
            S3ObjectKey          = "${local.app_name}.zip"
            PollForSourceChanges = "true"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name            = "Build-Docker-Image"
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          version         = "1"
          input_artifacts = ["source-output"]
          configuration = {
            ProjectName = local.base_name
          }
        }
      ]
    }
  ]

  # Tags
  tags = local.tags
}

# Create the Lambda function using a pre-built image
module "lambda" {
  source = "../../"

  function_name = "hello-${random_string.suffix.result}"
  package_type  = "Image"
  image_uri     = "${module.ecrbuild.ecr_repository_url}:latest"

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  environment_variables = {
    ENVIRONMENT = local.tags.Environment
  }

  tags = local.tags
}

output "lambda" {
  value = module.lambda
}
