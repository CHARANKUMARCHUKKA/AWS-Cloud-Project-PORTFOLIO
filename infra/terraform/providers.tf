provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "aws-production-task-api"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
