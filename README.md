# Messaging System with CI/CD Pipeline

A secure messaging application with user authentication and a complete CI/CD pipeline using Jenkins, Docker, and AWS EC2.

## Features

- Secure user registration and authentication with JWT
- Message sending and receiving
- Message reading status tracking
- RESTful API for messaging operations
- Complete CI/CD pipeline with Jenkins
- Containerized deployment with Docker
- AWS EC2 deployment support

## Prerequisites

- Ubuntu server (local or cloud-based)
- AWS account with EC2 instances
- Docker Hub account
- Git repository

## Quick Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/messaging-system.git
   cd messaging-system
   ```

2. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Follow the prompts to configure your environment.

## Manual Setup

If you prefer manual setup, follow these steps:

### 1. Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git awscli
```

### 2. Install Docker

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
```

### 3. Install Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 4. Set Up SSH Keys

```bash
# Create .ssh directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create or copy your private key
# Example: copy from existing key
# cp /path/to/your/key.pem ~/.ssh/private_key.pem
# chmod 600 ~/.ssh/private_key.pem
```

### 5. Configure AWS Credentials

```bash
mkdir -p ~/.aws
touch ~/.aws/credentials
touch ~/.aws/config

# Edit credentials file with your AWS access keys
# ~/.aws/credentials:
# [default]
# aws_access_key_id = YOUR_ACCESS_KEY
# aws_secret_access_key = YOUR_SECRET_KEY

# ~/.aws/config:
# [default]
# region = us-east-1
# output = json

chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config
```

### 6. Start Jenkins

```bash
docker-compose -f docker-compose.jenkins.yml up -d
```

### 7. Configure Jenkins

- Access Jenkins at http://localhost:8080
- Get the initial admin password:
  ```bash
  docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
  ```
- Complete the setup wizard
- Install recommended plugins
- Create the following credentials:
  - AWS_ACCESS_KEY_ID (Secret text)
  - AWS_SECRET_ACCESS_KEY (Secret text)
  - DOCKER_HUB_TOKEN (Secret text)
  - MY_SSH_KEY (SSH Username with private key)
  - root_password (Secret text - if needed)
- Create a new pipeline job using the Jenkinsfile in this repository

### 8. Run the Flask Application Locally (Optional)

```bash
docker-compose -f docker-compose.flask.yml up -d
```

## API Endpoints

- **POST /register**: Register a new user
- **POST /login**: Log in and get JWT token
- **GET /messages**: Get all messages for current user
- **POST /messages**: Send a new message
- **GET /messages/<id>**: Get a specific message
- **DELETE /messages/<id>**: Delete a message

## CI/CD Pipeline

The Jenkins pipeline includes the following stages:
1. Set AWS Credentials
2. Check AWS Identity
3. Start EC2 Instance
4. Clone Repository
5. Login to Docker Hub
6. Build Flask Docker Image
7. Push Flask Image to Docker Hub
8. Deploy Flask on EC2 with Private IP

## License

MIT License
