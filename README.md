AWS High-Availability Status Page Platform
Production-ready, highly available status page deployed on AWS using Terraform.
Security-first architecture with multi-AZ fault tolerance, zero public exposure for sensitive resources, and automated self-healing capabilities.
Architecture Highlights

    High Availability: Multi-AZ deployment across 2 availability zones with Auto Scaling Group (2-4 instances)
    Networking: VPC with public/private/DB subnet tiers, dual NAT Gateways, VPC Endpoints for S3 and Secrets Manager
    Compute: EC2 Auto Scaling Group behind Application Load Balancer with health checks
    Database: RDS PostgreSQL with Multi-AZ, encryption at rest, deletion protection, automated backups
    Security: Bastion host for SSH access, Secrets Manager for credentials, private subnets for all app workloads, encrypted EBS volumes
    Observability: Prometheus metrics endpoint, CloudWatch alarms with auto-scaling policies
    Approval Flow: Telegram Lambda bot for manual approve/reject of Terraform apply/destroy plans

Tech Stack
Table
Layer	Technology
App	Flask + Gunicorn + Prometheus client
Containers	Docker multi-stage, Docker Compose
CI/CD	GitHub Actions (lint → test → build → push to ECR → notify)
IaC	Terraform (modular: network, security, compute, alb, rds, lambda)
Registry	Amazon ECR
Cloud	AWS (eu-north-1)
Project Structure
plain
Copy

.
├── app/                  # Flask status page application
│   ├── app/              # Routes, templates
│   ├── tests/            # Pytest suite
│   ├── Dockerfile        # Multi-stage build
│   └── requirements.txt
├── infra/                # Terraform infrastructure
│   ├── modules/          # Reusable modules
│   │   ├── network/      # VPC, subnets, NAT, IGW, flow logs
│   │   ├── security/     # Security groups
│   │   ├── alb/          # ALB, target groups, HTTPS/HTTP listeners
│   │   ├── compute/      # Launch template, ASG, bastion host
│   │   ├── rds/          # PostgreSQL Multi-AZ instance
│   │   ├── secrets/      # Secrets Manager (DB credentials)
│   │   ├── iam/          # EC2 instance profile & ECR pull permissions
│   │   ├── monitoring/   # CloudWatch alarms & auto-scaling policies
│   │   ├── endpoints/    # VPC endpoints (Secrets Manager, S3)
│   │   └── lambda_bot/   # Telegram approval bot (API Gateway + Lambda + DynamoDB)
│   ├── main.tf           # Root module composition
│   ├── variables.tf
│   ├── outputs.tf
│   ├── locals.tf
│   ├── providers.tf
│   └── backend.tf        # S3 remote state + DynamoDB lock
├── bot/                  # Lambda source code (Terraform approval bot)
├── nginx/                # Reverse proxy config (Docker Compose)
├── bootstrap/            # One-time S3 state bucket + DynamoDB lock table
├── monitoring/           # Local Prometheus + Grafana stack (development)
├── docker-compose.yml    # Local development environment
├── docker-compose.prod.yml # Production Docker Compose reference
├── Makefile              # Local development shortcuts
└── .github/workflows/    # CI/CD pipelines

Endpoints
Table
Path	Method	Description
/	GET	Status page UI
/health	GET	Health check JSON
/metrics	GET	Prometheus metrics
/api/status	GET	API status overview
CI/CD Pipeline
plain
Copy

feature/* → PR → CI (lint/test/build) → Merge → CD (build → push to ECR) → Telegram notify

    CI (.github/workflows/ci.yml): Lint (flake8/black/isort) → Test (pytest) → Build (Docker) → PR comment
    CD (.github/workflows/cd.yml): Lint → Test → Build & Push to Amazon ECR → Telegram notification

Infrastructure Deployment
Prerequisites

    AWS CLI configured
    Terraform >= 1.5
    Docker

1. Bootstrap Remote State (one-time)
bash
Copy

cd bootstrap/
terraform init
terraform apply

This creates:

    S3 bucket for Terraform state (tfstate-platform-prod-<account_id>)
    S3 bucket for Terraform plans (tfplans-platform-prod-<account_id>)
    DynamoDB table for state locking (platform-prod-tflock)

2. Deploy Infrastructure
bash
Copy

cd ../infra/
terraform init
terraform plan -out=tfplan
terraform apply tfplan

3. Update EC2 Instances
After CD pushes a new image to ECR, trigger a rolling replacement:
bash
Copy

cd infra/
terraform apply -var="app_image_tag=<commit-sha>"
# Or update the default in variables.tf and re-apply

Local Development
bash
Copy

# Start all services locally
make up

# Or manually
docker-compose up -d --build

# Run tests
cd app && pytest -v --cov=app

# View logs
docker-compose logs -f app

Security Notes

    All EC2 instances run in private subnets — no public IPs, internet access via NAT Gateway
    RDS is not publicly accessible — access only through application security group or bastion host
    Secrets Manager stores DB credentials — rotated via Terraform, never hardcoded
    VPC Endpoints for S3 and Secrets Manager — traffic never leaves the AWS network
    EBS volumes and RDS storage are encrypted at rest
    Bastion host is the only entry point for SSH, restricted by CIDR
    ALB supports HTTPS (when certificate ARN provided) with HTTP→HTTPS redirect

Cost Optimization Notes

    ASG min_size=2 ensures HA with 2 AZs; scale down to 2 during low load
    RDS Multi-AZ doubles DB cost — disable for dev/staging
    NAT Gateways are billed hourly — consider NAT instances for non-prod
    Consider AWS Graviton (t4g) instances for 20% cost savings
