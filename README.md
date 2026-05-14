# System Status Page — DevOps Portfolio

Production-ready status page with automated CI/CD, Docker, and Telegram notifications.

## Tech Stack
- **Backend:** Flask + Gunicorn + Prometheus metrics
- **Infra:** AWS (VPC, ALB, EC2, RDS, Lambda), Terraform
- **CI/CD:** GitHub Actions (lint → test → build → push to GHCR → notify)
- **Containers:** Docker multi-stage, Docker Compose

## Endpoints
| Path | Description |
|------|-------------|
| `/` | Status page UI |
| `/health` | Health check JSON |
| `/metrics` | Prometheus metrics |

## CI/CD Pipeline
feature/* → PR → CI (lint/test/build) → Merge → CD (deploy to GHCR) → Telegram

## Demo
📺 [Video demo](https://youtu.be/YOUR_VIDEO_ID)
