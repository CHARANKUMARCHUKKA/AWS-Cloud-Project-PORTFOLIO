# AWS Production-Style Task Management API

A cloud engineering portfolio project built with Python, FastAPI,
Docker, Terraform, and AWS.

## Features
- REST API for task management
- Automated tests using pytest
- Docker containerization
- Planned AWS deployment using ECS Fargate
- Planned infrastructure automation using Terraform
- Planned CI/CD and CloudWatch monitoring

## Local development

Create and activate a virtual environment, then install dependencies:

    python -m venv .venv
    .\.venv\Scripts\Activate.ps1
    pip install -r requirements.txt

Run tests:

    python -m pytest -v

Run the API:

    uvicorn app.main:app --reload

API documentation: http://127.0.0.1:8000/docs

## Project status

Local API tests pass. Docker deployment and AWS infrastructure
are still being verified or implemented.

## Security
Never commit AWS credentials, environment secrets, private keys,
or Terraform state files.
