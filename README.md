<div align="center">
☁️ High-Availability Status Page Platform
Production-ready, self-healing AWS infrastructure with automated CI/CD, security-first design, and one-click Telegram approvals.
.github/workflows/ci.yml
.github/workflows/cd.yml
infra/
infra/
app/
app/Dockerfile
app/
LICENSE
</div>
🖼️ Visual Preview
Table
Status Page UI	Architecture Overview
Dark-themed real-time dashboard with Tailwind CSS	Modular Terraform with multi-AZ fault tolerance
<details>
<summary>📸 Status Page Features</summary>

    Real-time uptime counter (JavaScript-driven)
    Service health indicators with animated pulse dots
    Environment & version metadata
    Direct links to /metrics (Prometheus) and /api/status

</details>
🚀 Key Features
Table
Feature	Description
🏗️ Modular Terraform	10 reusable modules: network, security, compute, ALB, RDS, WAF, Lambda, IAM, monitoring, endpoints
🔒 Security-First	WAFv2 with AWS Managed Rules, encrypted EBS/RDS, private subnets, least-privilege IAM, VPC Flow Logs
📊 Observability	Prometheus metrics endpoint, CloudWatch auto-scaling alarms, Grafana/Prometheus local stack
🤖 GitOps Approval Flow	Telegram Lambda bot for manual approve/reject of Terraform apply/destroy plans
🚀 Zero-Downtime Deploys	Rolling replacement via ASG + ALB health checks, HTTPS redirect when ACM cert is provided
🧪 Quality Gates	flake8 → black → isort → pytest → docker build → checkov → tflint
💰 Cost Optimized	Graviton-ready, NAT Gateway per AZ, S3 lifecycle policies
🛠️ Tech Stack
Table
Layer	Technology
App	Flask 3.1 · Gunicorn · SQLAlchemy 2.0 · Alembic · Prometheus Client
Frontend	Tailwind CSS (CDN) · Vanilla JS
Container	Docker (multi-stage) · Docker Compose
Cloud	AWS EC2 · ALB · WAFv2 · RDS PostgreSQL · Lambda · API Gateway · ECR · S3 · DynamoDB · Secrets Manager · CloudWatch
IaC	Terraform 1.7+ · TFLint · Checkov
CI/CD	GitHub Actions (OIDC to AWS)
Local Monitoring	Prometheus · Grafana · Node Exporter
⚡ Quick Start
1. Local Development
bash
Copy

git clone https://github.com/max-dev-loreal/High-Availability-Cloud-Architecture-IaC-.git
cd High-Availability-Cloud-Architecture-IaC-
make up

Visit: http://localhost
bash
Copy

# Or manually
docker-compose up -d --build

# Run tests & linting
make test
make lint

2. Bootstrap Remote State (One-Time)
bash
Copy

cd bootstrap/
terraform init
terraform apply

Creates:

    S3 state bucket: tfstate-platform-prod-<account_id>
    S3 plans bucket: tfplans-platform-prod-<account_id>
    DynamoDB lock table: platform-prod-tflock

3. Deploy Infrastructure
bash
Copy

cd infra/
terraform init
terraform workspace select prod || terraform workspace new prod
terraform plan -out=tfplan
terraform apply tfplan

4. Deploy Application Image
After CI/CD pushes to ECR, trigger rolling replacement:
bash
Copy

cd infra/
terraform apply -var="app_image_tag=$(git rev-parse --short HEAD)"

🏛️ Architecture
<details>
<summary>Click to expand architecture diagram & flow</summary>
plain
Copy

┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│   GitHub    │────▶│   Actions   │────▶│   Amazon ECR    │
│   (Push)    │     │  CI / CD    │     │  webapp-prod    │
└─────────────┘     └─────────────┘     └─────────────────┘
                                                │
                                                ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│  Telegram   │◀────│   Lambda    │◀────│   ALB + WAF     │
│   (Bot)     │     │   (Bot)     │     │  (HTTPS/HTTP)   │
└─────────────┘     └─────────────┘     └─────────────────┘
                                                │
                       ┌────────────────────────┘
                       ▼
              ┌─────────────────┐
              │   EC2 ASG       │
              │  (2-4 instances)│
              │  Private Subnets│
              └─────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   ┌─────────┐   ┌─────────┐   ┌──────────┐
   │  NAT    │   │  RDS    │   │ Secrets  │
   │Gateway  │   │PostgreSQL│   │ Manager  │
   └─────────┘   │ Multi-AZ │   └──────────┘
                 └─────────┘

Traffic Flow:

    User → Route 53 (optional) → ALB (80/443) → WAF inspection
    ALB → Target Group → EC2 instances (private subnets, port 80)
    EC2 pulls image from ECR via VPC Endpoint + IAM instance profile
    App connects to RDS PostgreSQL via DB security group
    Secrets Manager accessed via VPC Interface Endpoint

</details>
📁 Project Structure
Text
Copy

.
├── app/                      # Flask application
│   ├── app/
│   │   ├── templates/        # Jinja2 + Tailwind UI
│   │   ├── __init__.py       # App factory (SQLAlchemy, config)
│   │   └── routes.py         # Health, metrics, status, home
│   ├── migrations/           # Alembic DB migrations
│   ├── tests/                # Pytest suite
│   ├── Dockerfile            # Multi-stage, non-root user
│   ├── gunicorn.conf.py      # Worker hooks & logging
│   └── requirements.txt
├── infra/                    # Terraform root module
│   ├── modules/              # 10 reusable modules
│   │   ├── network/          # VPC, 6 subnets, dual NAT, flow logs
│   │   ├── security/         # Bastion, ALB, App, DB security groups
│   │   ├── alb/              # ALB, target group, HTTPS/HTTP listeners
│   │   ├── waf/              # WAFv2 ACL + managed rule sets
│   │   ├── compute/          # Launch template, ASG, bastion host
│   │   ├── rds/              # PostgreSQL Multi-AZ instance
│   │   ├── secrets/          # Secrets Manager (DB creds)
│   │   ├── iam/              # EC2 instance profile + ECR pull
│   │   ├── monitoring/       # CloudWatch alarms + scaling policies
│   │   ├── endpoints/        # VPC endpoints (S3, Secrets Manager)
│   │   └── lambda_bot/       # Telegram approval bot (API GW + Lambda + DynamoDB)
│   ├── main.tf               # Root composition
│   ├── variables.tf
│   ├── outputs.tf
│   ├── locals.tf
│   ├── providers.tf
│   └── backend.tf            # S3 remote state + DynamoDB lock
├── bot/                      # Lambda source (Terraform approval bot)
├── bootstrap/                # One-time S3 + DynamoDB bootstrap
├── nginx/                    # Reverse proxy config
├── monitoring/               # Local Prometheus + Grafana stack
├── .github/workflows/        # CI, CD, Terraform CI
├── docker-compose.yml        # Local development
├── docker-compose.prod.yml   # Production compose reference
└── Makefile                  # Dev shortcuts

⚙️ Configuration
Application Environment
Table
Variable	Default	Description
APP_VERSION	dev	Release tag shown in UI
DEPLOY_TIME	unknown	ISO timestamp of deployment
ENVIRONMENT	local	Runtime environment label
DATABASE_URL	sqlite:////tmp/statuspage.db	SQLAlchemy URI (PostgreSQL in prod)
LOG_LEVEL	info	Gunicorn log level
Terraform Variables
Table
Variable	Default	Description
region	eu-north-1	AWS region
instance_type	t3.micro	EC2 instance type
db_instance_class	db.t3.micro	RDS instance class
ami_id	ami-0c1ac8a41498c1a9c	Ubuntu AMI for EC2
key_name	stockholm-max-key	EC2 key pair for bastion SSH
db_password	required	RDS master password
certificate_arn	""	ACM certificate ARN for HTTPS ALB
telegram_bot_token	""	Telegram bot token (Lambda)
github_pat_secret_arn	required	Secrets Manager ARN for GitHub PAT
🔌 API Reference
Table
Endpoint	Method	Description
/	GET	Status page UI (HTML)
/health	GET	Liveness probe — process health
/ready	GET	Readiness probe — database connectivity
/metrics	GET	Prometheus metrics (requests, duration)
/api/status	GET	JSON service status overview
🔄 CI/CD Pipelines
<details>
<summary><b>CI Pipeline</b> (feature/* → PR)</summary>
Text
Copy

Lint (flake8/black/isort) → Test (pytest) → Build (Docker) → PR Comment

    Triggered on: push to non-main branches, pull_request to main
    Outputs: coverage XML, PR comment with status

</details>
<details>
<summary><b>CD Pipeline</b> (main → Production)</summary>
Text
Copy

Lint → Test → Build & Push to ECR → Telegram Notification

    Uses OIDC to AWS (no long-lived credentials)
    Tags: github.sha + latest
    Telegram notification on success/failure with run links

</details>
<details>
<summary><b>Terraform CI</b> (infra/* changes)</summary>
Text
Copy

terraform fmt → terraform validate → tflint → checkov

    Enforces HCL formatting, validates modules, scans security with Checkov

</details>
🔐 Security Highlights

    ✅ Zero public exposure — App instances live in private subnets with no public IPs
    ✅ Encryption at rest — EBS volumes (gp3), RDS storage, S3 buckets (AES256)
    ✅ Encryption in transit — ALB HTTPS listener with TLS 1.3 policy, Secrets Manager via VPC endpoint
    ✅ WAF protection — AWS Managed Rules (Common, SQLi, Bad Inputs) + IP-based rate limiting (2000 req/5min)
    ✅ Least privilege IAM — EC2 reads only its designated secret; Lambda has scoped S3/DynamoDB/Secrets access
    ✅ Bastion host — Single SSH entry point, CIDR-restricted
    ✅ IaC scanning — Checkov + TFLint in CI pipeline
    ✅ Container hardening — Non-root user, multi-stage build, healthchecks, distroless-ready base

🤝 Contributing

    Fork the repository
    Create your feature branch (git checkout -b feature/amazing-feature)
    Run quality gates (make lint && make test)
    Commit your changes (git commit -m 'feat: add amazing feature')
    Push to the branch (git push origin feature/amazing-feature)
    Open a Pull Request

CI will automatically validate formatting, run tests, build the container, and post a status comment.
📄 License
Distributed under the MIT License. See LICENSE for more information.
<div align="center">
Built with ☁️ on AWS · Maintained by max-dev-loreal
</div>
