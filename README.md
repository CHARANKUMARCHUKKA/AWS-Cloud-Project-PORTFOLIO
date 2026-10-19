# AWS CLOUD ENGINEERING PROJECT

## TASK MANAGEMENT REST API

A cloud engineering portfolio project built with FastAPI, MySQL, Docker, Terraform, and AWS.

**Project status:** Local application working; AWS infrastructure is defined but deployment remains opt-in.

## TECHNOLOGIES

- Python
- FastAPI
- MySQL
- SQLAlchemy
- Docker
- Docker Compose
- Terraform
- Amazon Web Services (AWS)

## PROJECT GOAL

Build and deploy a secure, monitored, and cost-conscious task management API using cloud engineering practices.

## CURRENT STATUS

- Local API and database integration
- Docker-based development environment
- Automated application tests
- Terraform infrastructure setup in progress
- AWS deployment planned

## DEPLOYMENT SAFETY AND COSTS

Terraform defaults to `enable_ecs_service = false`, so an infrastructure-only
validation does not create a running Fargate service or Application Load
Balancer. Enabling the service requires an immutable ECR image tag, an ACM
certificate ARN, a MySQL endpoint, and a Secrets Manager secret with
`username` and `password` JSON keys. Secrets are referenced by ARN only and
are not stored in Terraform variables or source control.

The production-style public entry point uses an ALB with HTTPS and a single
Fargate task. An ALB's monthly cost alone is normally above a $10/month
budget, before compute, logging, database, and data-transfer charges. Keep
`enable_ecs_service` disabled outside short portfolio demonstrations, and
destroy approved demo resources promptly. No `terraform apply` is run by this
repository workflow.

## FUTURE WORK

- AWS networking and security
- Amazon ECR and ECS Fargate
- Amazon RDS for MySQL
- GitHub Actions CI/CD with AWS OIDC
- Amazon CloudWatch monitoring
- Infrastructure cost and security review
