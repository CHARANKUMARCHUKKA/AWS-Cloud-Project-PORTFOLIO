variable "aws_region" {
  description = "AWS region for the project."
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used for local Terraform operations."
  type        = string
  default     = "project1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}
variable "project_name" {
  description = "Short name used for project resources."
  type        = string
  default     = "aws-cloud-project-portfolio"
}
