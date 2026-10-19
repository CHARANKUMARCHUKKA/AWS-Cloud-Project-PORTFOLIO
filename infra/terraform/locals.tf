locals {
  # ALB and target group names are limited to 32 characters by AWS.
  api_load_balancer_name = substr("${var.project_name}-${var.environment}-api", 0, 32)
}
