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

## DATABASE MIGRATIONS

The API never creates or alters database tables at startup. Apply schema
changes through Alembic as a controlled deployment step before rolling out new
application tasks:

```powershell
# Load local, non-committed environment values before running this command.
alembic upgrade head
```

For a new schema change, create and review a migration before committing it:

```powershell
alembic revision --autogenerate -m "describe the schema change"
alembic upgrade head
```

In deployment, run `alembic upgrade head` from a one-off, network-authorized
release task that can reach the private database. Do not run migrations from
every API task at startup; doing so risks concurrent schema changes during a
rollout.

## CONTAINER BUILDS

The default image is a small, non-root API runtime. It installs only the
runtime dependency set; test and migration packages are excluded. Dependencies
are constrained to the exact versions in `requirements/constraints.txt` for
repeatable builds. Refresh that file deliberately after testing dependency
updates.

```powershell
# API runtime image
docker build --tag task-api:local .

# Controlled migration image; it does not run as part of the API image startup.
docker build --target migration --tag task-api-migrations:local .
```

The build context excludes `.env`, virtual environments, tests, Git metadata,
and Terraform artifacts. Pass credentials only at container runtime through
your secret-management mechanism; never bake them into an image or build
argument. Run the migration image as a one-off release step with database
network access before deploying new API tasks.

## FUTURE WORK

- AWS networking and security
- Amazon ECR and ECS Fargate
- Amazon RDS for MySQL
- GitHub Actions CI/CD with AWS OIDC
- Amazon CloudWatch monitoring
- Infrastructure cost and security review
