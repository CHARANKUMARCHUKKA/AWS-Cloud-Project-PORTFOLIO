output "vpc_id" {
  description = "ID of the project VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private database subnets."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "alb_security_group_id" {
  description = "Security group ID for the load balancer."
  value       = aws_security_group.alb.id
}

output "api_security_group_id" {
  description = "Security group ID for the API."
  value       = aws_security_group.api.id
}

output "database_security_group_id" {
  description = "Security group ID for the database."
  value       = aws_security_group.database.id
}
output "ecr_repository_url" {
  description = "URL of the ECR repository for the API image."
  value       = aws_ecr_repository.api.repository_url
}