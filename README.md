![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Status](https://img.shields.io/badge/status-production--ready-green)



# ⚡ DevSecOps AWS Infrastructure (Terraform)

### Production-style cloud architecture focused on scalability, security, and system behavior

---

## 🧠 Philosophy

This project is not just about provisioning infrastructure.

It is about understanding:
- how systems scale
- how they fail
- how they stay secure under pressure

> I treat infrastructure as a system, not just resources.

---

## 🏗 Architecture Overview

A production-inspired AWS architecture designed for high availability and isolation.

### Core Components

- **VPC** with public & private subnets across 2 AZs  
- **Application Load Balancer (ALB)**  
- **Auto Scaling Group (ASG)**  
- **EC2 instances (private subnets)**  
- **Bastion Host (secure entry point)**  
- **RDS PostgreSQL (Multi-AZ)**  
- **NAT Gateways**  
- **VPC Endpoints (S3, Secrets Manager)**  

---

## 🔄 System Behavior

### Load Handling
Traffic is distributed via ALB across multiple EC2 instances.

### Failure Scenario
If an instance fails:
- it is automatically replaced by ASG  
- traffic is rerouted without downtime  

### Scaling Logic
- Scale up → CPU > 70%  
- Scale down → CPU < 30%  

---

## 🔐 Security Model

- No public access to EC2 or RDS  
- Bastion Host as the only SSH entry point  
- IAM roles instead of hardcoded credentials  
- Secrets stored in AWS Secrets Manager  
- Private networking between all critical components  

---

## 🧱 Infrastructure as Code

Terraform is used to fully describe and reproduce the system.

### Key Design Decisions

- **RDS PostgreSQL** → realistic backend simulation  
- **ALB + ASG** → horizontal scalability  
- **Private subnets** → security-first approach  
- **Amazon Linux 2** → optimized and fast boot  

---

## ⚙️ Application Layer

Each EC2 instance runs a lightweight web app:

- Apache (httpd)  
- Health endpoint: `/health`  
- Secrets fetched dynamically from AWS Secrets Manager  

---

## 📊 Observability

- CloudWatch Alarms (CPU-based scaling)  
- Health checks via ALB  
- Auto Scaling metrics  

---

## 🚀 Deployment

### 1. Bootstrap (remote state)

```bash
cd bootstrap
terraform init
terraform apply
```
2. Main infrastructure
```bash
cd ../infra
terraform init
terraform apply
```
📦 Outputs
1-ALB DNS → application entry point
2-RDS endpoint → database access
🎯 What This Project Demonstrates
1-Real-world AWS architecture
2-Infrastructure as Code (IaC)
3-Secure system design
4-Fault-tolerant infrastructure
5-Scalable cloud patterns
🔮 Next Evolution
1-Kubernetes (EKS)
2-CI/CD (GitHub Actions)
3-Observability (Prometheus + Grafana)
4-AWS WAF
5-Terraform Cloud
🧠 Architecture Principles
1-High Availability → Multi-AZ
2-Fault Tolerance → ASG + ALB
3-Security → Isolation + IAM
4-Scalability → Horizontal scaling
5-Observability → Monitoring & health checks
⚡ Key Idea

This project is not about AWS.
It's about understanding how distributed systems behave.

👤 Author

GitHub: https://github.com/max-dev-loreal

YouTube: https://youtu.be/pV7I0Aw345I

