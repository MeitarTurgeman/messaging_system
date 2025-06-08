# Messaging System with DevOps Pipeline

A production-ready, secure messaging API built with Python Flask, featuring JWT authentication, message status tracking, and a full modern DevOps pipeline: Jenkins CI/CD, Docker, Kubernetes, and Infrastructure as Code with Terraform on AWS.

![Architecture Diagram](./Diagram.drawio.svg)
---

## 🚀 Overview

This project demonstrates robust Python backend skills and advanced DevOps workflow design:

- **Secure messaging API** — users send and receive messages, with real-time status updates.
- **JWT-based authentication** for strong user security.
- **CI/CD pipeline with Jenkins** — build, test, and deploy automatically.
- **Docker containerization** — consistent, portable builds for any environment.
- **Kubernetes orchestration** — scalable, resilient deployment on local clusters and the cloud.
- **Infrastructure as Code** - with Terraform: EKS cluster, RDS database, VPC, and more.
- **AWS Native Services** - ECR, S3, Route 53, Load Balancer, CloudWatch, Auto Scaling Groups.

---

## 🛠️ Stack

- **Backend:** Python 3 + Flask + SQLAlchemy + Marshmallow
- **Authentication:** Flask-JWT-Extended (JWT)
- **Database:** PostgreSQL (containerized)
- **CI/CD:** Jenkins (with scripted Jenkinsfile pipeline)
- **Containerization:** Docker
- **Orchestration:** Kubernetes (compatible with Minikube, EKS, GKE, AKS)
- **Testing:** Pytest
- **Infrastructure as Code:** Terraform (AWS modules) Testing: Pytest
- **Registry:** ECR (AWS Elastic Container Registry)
- **Object Storage:** S3 Bucket
- **DNS Management:** Route 53
- **Monitoring & Logs:** CloudWatch
- **Autoscaling:** Auto Scaling Groups (EKS nodegroups & ALB target groups)

---

## 📂 Project Structure

<pre>
```
├── app/                   # Flask application (routes, models, auth)
├── tests/                 # Pytest unit & API tests
├── kubernetes/            # YAML manifests (Deployment, Service, Postgres, Jenkins)
├── terraform/             # Terraform modules: EKS, VPC, RDS, Security groups variables
│   ├── main.tf
|   ├── main.tf
|   ├── variables.tf
|   ├── outputs.tf
|   ├── provider.tf
|   ├── versions.tf
├── run.py                 # App entrypoint
├── Dockerfile             # App Docker build config
├── requirements.txt       # Python dependencies
├── Jenkinsfile            # CI/CD pipeline definition
├── .env.example           # Example environment variables
└── README.md
```
</pre>

---

## ☁️ Cloud Infrastructure (Terraform)

Terraform modules are included to provision all AWS infrastructure automatically:

   - VPC - Network isolation for your cluster & database
   - EKS (Kubernetes) - Managed cluster for your workloads
   - RDS (PostgreSQL) - Managed database service for production
   - ECR (Elastic Container Registry) – Private Docker image storage
   - S3 Bucket – Store user data or backups
   - Route 53 – DNS management for your app domain
   - Application Load Balancer – Distribute traffic to app pods
   - CloudWatch – Centralized logging & monitoring
   - Autoscaling – NodeGroups & app scaling
   - Security Groups - Controlled access between components

   Deploy infrastructure in AWS:
   <pre>
   ```
   export TF_VAR_rds_db_name=yourdbname
   export TF_VAR_rds_username=yourdbuser
   export TF_VAR_rds_password=yourdbpassword

   cd terraform/
   terraform init
   terraform plan
   terraform apply
   ```
   </pre>

## 🖥️ Local Development

1. **Clone the repo:**
   <pre>
   ```
   bash
   docker build -t meitarturgeman/messages-api:latest .
   docker run -p 5000:5000 --env-file .env meitarturgeman/messages-api:latest
   ```
   </pre>

2. **Setup virtualenv and install dependencies:**
   <pre>
   ```
   bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
   </pre>

3. **Copy & edit environment variables:**
   <pre>
   ```
   bash
   cp .env.example .env
   # Edit DATABASE_URL and SECRET_KEY as needed for the application
   ```
   </pre>

4. **Run the app locally:**
   <pre>
   ```
   bash
   export FLASK_APP=run.py
   flask run
   ```
   </pre>

---

## 🧪 Testing

Run unit and API tests (with [pytest](https://docs.pytest.org/)):
   <pre>
   ```
   bash
   pytest tests/
   </pre>

---

## 🐳 Docker Usage

Build & run the Flask app locally:
   <pre>
   docker build -t meitarturgeman/messages-api:latest .
   docker run -p 5000:5000 --env-file .env meitarturgeman/messages-api:latest
   </pre>

---

## 🤖 CI/CD with Jenkins

The pipeline automates:
	-	Running tests (pytest)
	-	Building Docker image
	-	Pushing to Docker Hub
	-	Deploying to Kubernetes

Quick Jenkins setup:
	1.	Start Jenkins (jenkins/jenkins:lts), mapped to port 8080.
	2.	Install recommended plugins.
	3.	Add credentials for Docker Hub and (if used) Kubernetes.
	4.	Configure a Pipeline project pointing to this repo and use the provided Jenkinsfile.

---

## ☸️ Kubernetes Deployment

Supports any K8s cluster (Minikube, EKS, etc):

Deploy with kubectl:
   <pre>
   kubectl apply -f kubernetes/postgres-deployment.yaml
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/jenkins-deployment.yaml
   kubectl apply -f kubernetes/app-secret.yaml
   kubectl apply -f kubernetes/postgres-secret.yaml
   </pre>

Access the service:
# For Minikube
   change the port for the application to 5000:
   <pre>
   kubectl port-forward svc/myapp-service 5000:5000
   </pre>

---

## 🔑 API Endpoints

<pre>
| Endpoint         | Method | Auth | Description         |
|------------------|--------|------|---------------------|
| /register        | POST   | No   | Register new user   |
| /login           | POST   | No   | Obtain JWT token    |
| /messages        | GET    | Yes  | Get user messages   |
| /messages        | POST   | Yes  | Send message        |
| /messages/&lt;id&gt; | GET    | Yes  | Get specific message|
| /messages/&lt;id&gt; | DELETE | Yes  | Delete a message    |
</pre>


---

## 📝 Environment Variables

See .env.example. Main variables:
   
   Flask app:
   -  DATABASE_URL
   -  SECRET_KEY
   -  CLOUD_DATABASE_URL (for RDS)

   Postgres:
   -  POSTGRES_USER
   -  POSTGRES_PASSWORD
   -  POSTGRES_DB

---

## 🛡️ Security & Best Practices

	-  JWT for all sensitive routes
	-  CI enforces passing tests before deploy
	-  Docker images built fresh for every release
	-  Environment variables never hardcoded
	-  No sensitive credentials in code or YAML

---

## ✨ Cloud AWS Resources Used

VPC, EKS, RDS, ECR, S3, Route53, CloudWatch, ALB, Autoscaling, Security Groups

## 📜 License

MIT License
Built by Meitar Turgeman