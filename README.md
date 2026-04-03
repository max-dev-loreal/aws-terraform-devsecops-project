# ⚡️ Production-Ready AWS Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Infrastructure-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Security](https://img.shields.io/badge/Security-DevSecOps_Focused-green?logo=checkmarx)](https://github.com/max-dev-loreal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📖 Overview

This project serves as a **Reference Architecture** for a fault-tolerant and secure cloud environment on AWS. The primary objective is not just resource provisioning, but demonstrating the principles of **Self-Healing Infrastructure**, **Network Isolation**, and **Least Privilege Access**.

The project implements a full Three-Tier design, ready for production-level workloads and aligned with the **AWS Well-Architected Framework** standards.

---

## 🏗 Architecture & Design

### High-Level Diagram
```mermaid
graph TD
    User((User)) --> ALB[ALB - Public Subnet]
    subgraph VPC [VPC: 10.0.0.0/16]
        subgraph Public_Subnets [Public Subnets - Multi-AZ]
            ALB
            Bastion[Bastion Host]
        end
        subgraph Private_App_Subnets [Private App Subnets - Multi-AZ]
            ASG[Auto Scaling Group]
            ASG --> EC2[EC2 Instances]
        end
        subgraph Private_DB_Subnets [Private DB Subnets - Multi-AZ]
            RDS[(RDS PostgreSQL Multi-AZ)]
        end
    end
    EC2 --> RDS
    EC2 -.-> S3[S3 via Gateway Endpoint]
    EC2 -.-> SM[Secrets Manager via Interface Endpoint]
```

### Key Engineering Decisions
* **Zero Public Exposure:** All compute resources (EC2) and databases (RDS) are located in isolated private subnets. External access is strictly controlled via the ALB (HTTP/HTTPS) or the Bastion Host (SSH).
* **High Availability (Multi-AZ):** The infrastructure is distributed across two Availability Zones. In the event of an AWS data center failure, the system maintains continuity.
* **Scalability:** Implemented dynamic auto-scaling based on CPU utilization to handle fluctuating traffic demands.
* **Security First:** * No secrets are stored in the codebase; AWS Secrets Manager is utilized for dynamic credential retrieval.
    * Use of IAM Roles & Instance Profiles instead of static access keys.
    * Network Isolation: Inter-component traffic is restricted at the Security Group level.

---

## 🛠 Tech Stack

* **IaC:** Terraform (Modular structure)
* **Cloud:** AWS (VPC, EC2, ASG, ALB, RDS, CloudWatch, IAM)
* **OS/Web:** Amazon Linux 2, Apache (httpd)
* **Database:** PostgreSQL (RDS)
* **Security:** AWS Secrets Manager, VPC Endpoints

---

## 🚀 Deployment Guide

### Prerequisites
* Terraform v1.5.0+
* AWS CLI configured with appropriate permissions
* S3 Bucket for Terraform State storage (created during the Bootstrap phase)

### 1. Provisioning Remote State
Deploy the backend (S3 & DynamoDB) to securely store the state and enable state locking.
```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

### 2. Main Infrastructure
```bash
cd ../infra
terraform init
terraform apply -auto-approve
```

---

## 🔐 Security Controls

| Feature | Implementation |
| :--- | :--- |
| **Network Security** | Custom VPC, Public/Private subnets, NAT Gateways |
| **Access Control** | Bastion Host (Jump Box) + Security Groups |
| **Identity** | IAM Roles with Principle of Least Privilege |
| **Data Protection** | RDS Multi-AZ Failover + Encrypted Storage |
| **Secrets Management** | AWS Secrets Manager with dynamic fetching |

---

## 📈 Observability & Reliability

* **Self-Healing:** The ASG automatically replaces unhealthy instances based on ALB health checks.
* **Monitoring:** CloudWatch Alarms are configured for critical resource thresholds.
* **Scaling Policy:**
    * **Scale-Out:** +1 instance when CPU > 70% for 2 minutes.
    * **Scale-In:** -1 instance when CPU < 30%.

---

## 🗺 Roadmap

- [ ] Integrate **AWS WAF** for SQLi and XSS protection.
- [ ] Transition to **Amazon EKS (Kubernetes)** for container orchestration.
- [ ] Implement **GitHub Actions** (CI/CD) for automated Terraform Plan/Apply workflows.
- [ ] Set up advanced monitoring with **Prometheus + Grafana**.

---

## 👤 Author

**Max Dev** — Cloud & DevSecOps Enthusiast.

[![GitHub](https://img.shields.io/badge/GitHub-Profile-181717?logo=github)](https://github.com/max-dev-loreal)
[![YouTube](https://img.shields.io/badge/YouTube-Watch_Demo-FF0000?logo=youtube)](https://youtu.be/pV7I0Aw345I)

---
*This project is built for educational purposes to demonstrate distributed systems behavior.*
