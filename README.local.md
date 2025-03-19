# Messaging System: Local Ubuntu Setup

This guide helps you set up the messaging system on your local Ubuntu machine with CI/CD using Jenkins.

## Prerequisites

- Ubuntu (tested on Ubuntu 20.04 LTS or newer)
- Docker and Docker Compose
- Git
- Minikube (for Kubernetes deployment)

## Quick Setup

1. Clone this repository:
   ```bash
   git clone <your-repository-url>
   cd messaging_system
   ```

2. Make the setup script executable and run it:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. This script will:
   - Install Docker, Docker Compose, kubectl, and Minikube if not already installed
   - Start Minikube
   - Set up Jenkins in a Docker container
   - Build and start the Flask application

## Manual Setup

If you prefer to set things up manually:

### 1. Install Docker and Docker Compose

```bash
# Install Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
# Log out and log back in to apply group changes

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Install Minikube and kubectl

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Start Minikube
minikube start
```

### 3. Start Jenkins

```bash
docker-compose -f docker-compose.jenkins.yml up -d
```

Access Jenkins at http://localhost:8080 and complete the setup:
- Get the initial admin password:
  ```bash
  docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
  ```
- Install recommended plugins
- Create an admin user

### 4. Configure Jenkins

1. Create a new Pipeline job
2. Configure the pipeline to use the `Jenkinsfile.local` from your repository
3. Run the pipeline

### 5. Run the Application

```bash
# Run using Docker Compose
docker-compose -f docker-compose.flask.yml up -d

# Or run the entire stack (Jenkins + Flask)
docker-compose -f docker-compose.app.yml up -d
```

### 6. Deploy to Kubernetes (Local)

```bash
# Build the image
docker build -t local/flask-app:latest .

# Apply Kubernetes configurations
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Get the service URL
minikube service flask-app --url
```

## Testing the Application

1. Register a user: POST http://localhost:5000/register
2. Login: POST http://localhost:5000/login
3. Send a message: POST http://localhost:5000/messages
4. View messages: GET http://localhost:5000/messages

## CI/CD Pipeline

The Jenkinsfile.local pipeline includes:
1. Source code checkout
2. Docker image build
3. Local Docker deployment
4. Kubernetes deployment

## Troubleshooting

1. **Docker permission issues**
   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

2. **Jenkins container not starting**
   ```bash
   docker logs jenkins-server
   ```

3. **Minikube issues**
   ```bash
   minikube delete
   minikube start
   ``` 