# Messaging System with DevOps Pipeline

A secure messaging application with user authentication deployed using modern DevOps practices including Jenkins, Docker, and Kubernetes.

## Features

- Secure user authentication with JWT
- Message sending and receiving between users
- Message reading status tracking
- RESTful API for messaging operations
- CI/CD pipeline with Jenkins
- Containerized deployment with Docker
- Kubernetes orchestration for container management

## Project Components

- **Flask Application**: Backend API for the messaging system
- **Jenkins Server**: CI/CD automation server
- **Docker**: Containerization platform
- **Minikube**: Local Kubernetes cluster for orchestration

## Prerequisites

- Linux/Ubuntu system
- Docker and Docker Compose
- Minikube for local Kubernetes deployment
- Git repository

## Quick Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/messaging-system.git
   cd messaging-system
   ```

2. Start Jenkins server:
   ```bash
   cd app
   docker-compose -f docker-compose.jenkins.yml up -d
   ```

3. Start Flask application:
   ```bash
   cd app
   docker-compose -f docker-compose.flask.yml up -d
   ```

## Jenkins Setup

1. Access Jenkins at http://localhost:8080
2. Get the initial admin password:
   ```bash
   docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Install suggested plugins during setup
4. Create a Docker Hub credential with ID 'dockerhub'
5. Create a pipeline pointing to your repository with the Jenkinsfile

## API Endpoints

- **POST /login**: Authenticate and receive JWT token
- **GET /messages**: Get all messages for the current user
- **POST /messages**: Send a new message
- **GET /messages/<id>**: Get a specific message
- **DELETE /messages/<id>**: Delete a message

## CI/CD Pipeline

The Jenkins pipeline includes the following stages:
1. Setup Environment (checks Kubernetes connectivity)
2. Clone Repository
3. Login to Docker Hub
4. Build Flask Docker Image
5. Push to Docker Hub
6. Deploy to Kubernetes (if available)
7. Verify Kubernetes Deployment
8. Deploy Locally (Docker container)

## Kubernetes Deployment

The application is deployed to Kubernetes using:
- Deployment configuration (kubernetes/deployment.yaml)
- Service configuration (kubernetes/service.yaml)

You can access the Kubernetes-deployed application using:
```bash
minikube service flask-app --url
```

## Docker Images

- **jenkins/jenkins:lts**: Jenkins CI/CD server
- **meitarturgeman/messages-api:latest**: Flask messaging application

## Local Development

To run the Flask application locally without Docker:
```bash
pip install -r requirements.txt
export FLASK_APP=run.py
export FLASK_ENV=development
flask run
```

## License

MIT License
