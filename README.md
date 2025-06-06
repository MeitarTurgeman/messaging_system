# Messaging System with DevOps Pipeline

A production-ready, secure messaging API built with Python Flask, featuring JWT authentication, message status tracking, and a full modern DevOps pipeline: Jenkins CI/CD, Docker, and Kubernetes.

---

## 🚀 Overview

This project demonstrates robust Python backend skills and advanced DevOps workflow design:

- **Secure messaging API** — users send and receive messages, with real-time status updates.
- **JWT-based authentication** for strong user security.
- **CI/CD pipeline with Jenkins** — build, test, and deploy automatically.
- **Docker containerization** — consistent, portable builds for any environment.
- **Kubernetes orchestration** — scalable, resilient deployment on local clusters and the cloud.

---

## 🛠️ Stack

- **Backend:** Python 3 + Flask + SQLAlchemy + Marshmallow
- **Authentication:** Flask-JWT-Extended (JWT)
- **Database:** PostgreSQL (containerized)
- **CI/CD:** Jenkins (with scripted Jenkinsfile pipeline)
- **Containerization:** Docker
- **Orchestration:** Kubernetes (compatible with Minikube, EKS, GKE, AKS)
- **Testing:** Pytest

---

## 📂 Project Structure

<pre>
```
├── app/                   # Flask application (routes, models, auth)
├── tests/                 # Pytest unit & API tests
├── kubernetes/            # YAML manifests (Deployment, Service, Postgres, Jenkins)
├── run.py                 # App entrypoint
├── Dockerfile             # App Docker build config
├── requirements.txt       # Python dependencies
├── Jenkinsfile            # CI/CD pipeline definition
├── .env.example           # Example environment variables
└── README.md
```
</pre>

---

## 🖥️ Local Development

1. **Clone the repo:**
   <pre>
   ```bash
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
   # Edit DATABASE_URL and SECRET_KEY as needed
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
   ```bash
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
   kubectl apply -f kubernetes/postgres.yaml
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   </pre>

Access the service:
# For Minikube
   <pre>
   minikube service flask-app --url
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
	-	DATABASE_URL — Postgres connection string (e.g., postgresql://user:pass@host:5432/db)
	-	SECRET_KEY — strong JWT secret for production

---

## 🛡️ Security & Best Practices

	-	JWT for all sensitive routes
	-	CI enforces passing tests before deploy
	-	Docker images built fresh for every release
	-	Environment variables never hardcoded

---

## 📜 License

MIT License
Built by Meitar Turgeman