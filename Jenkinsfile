pipeline {
    agent any

    environment {
        DOCKER_USER = "meitarturgeman"
        FLASK_CONTAINER_NAME = "flask-app"
        FLASK_IMAGE_NAME = "meitarturgeman/messages-api:latest"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_HUB_CRED = credentials('dockerhub')
        K8S_ENABLED = false  // Set to false to disable Kubernetes stages
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    sh '''
                    echo "Setting up environment..."
                    echo "Kubernetes stages disabled for now."
                    '''
                }
            }
        }

        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    sh 'echo $DOCKER_HUB_CRED_PSW | docker login -u $DOCKER_HUB_CRED_USR --password-stdin || true'
                }
            }
        }

        stage('Build Flask Docker Image') {
            steps {
                script {
                    sh "docker build -t ${FLASK_IMAGE_NAME} -f app/Dockerfile-flask ."
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "docker push ${FLASK_IMAGE_NAME}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression {
                    return K8S_ENABLED
                }
            }
            steps {
                script {
                    echo "Kubernetes deployment stage skipped"
                }
            }
        }
        
        stage('Verify Kubernetes Deployment') {
            when {
                expression {
                    return K8S_ENABLED
                }
            }
            steps {
                script {
                    echo "Kubernetes verification stage skipped"
                }
            }
        }
        
        stage('Deploy Locally') {
            steps {
                script {
                    sh '''
                    # Stop and remove existing container if it exists
                    docker stop ${FLASK_CONTAINER_NAME} || true
                    docker rm ${FLASK_CONTAINER_NAME} || true
                    
                    # Run the container locally
                    docker run -d --name ${FLASK_CONTAINER_NAME} -p 5000:5000 ${FLASK_IMAGE_NAME}
                    
                    # Verify container is running
                    docker ps | grep ${FLASK_CONTAINER_NAME}
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully!"
            echo "Flask app deployed in Docker container."
            echo "Access the app at: http://localhost:5000 (Docker)"
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
    }
}
