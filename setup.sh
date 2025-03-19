#!/bin/bash

# Exit on error
set -e

echo "Setting up Messaging System on Ubuntu..."

# Update and install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker installed successfully. You might need to log out and log back in for group changes to take effect."
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
fi

# Install kubectl if not installed
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "kubectl installed successfully."
fi

# Install Minikube if not installed
if ! command -v minikube &> /dev/null; then
    echo "Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo "Minikube installed successfully."
fi

# Start Minikube if not running
if ! minikube status &> /dev/null; then
    echo "Starting Minikube..."
    minikube start
    echo "Minikube started successfully."
fi

# Setup Jenkins
echo "Setting up Jenkins..."
docker-compose -f docker-compose.jenkins.yml up -d
echo "Jenkins is running at http://localhost:8080"
echo "Initial admin password:"
sleep 10
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword || echo "Could not retrieve Jenkins password yet. Try running: docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword"

# Build and Start Flask App
echo "Building and starting Flask application..."
docker-compose -f docker-compose.flask.yml up -d
echo "Flask app is running at http://localhost:5000"

echo "Setup complete!"
echo "Remember to configure Jenkins with the Jenkinsfile.local pipeline for local CI/CD." 