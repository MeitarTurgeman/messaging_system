pipeline {
    agent any

    environment {
        DOCKER_USER = "meitarturgeman"
        FLASK_CONTAINER_NAME = "flask-app"
        FLASK_IMAGE_NAME = "meitarturgeman/messages-api:latest"
        DOCKER_REGISTRY = "docker.io"
        MINIKUBE_IP = sh(script: 'minikube ip', returnStdout: true).trim()
        DOCKER_HUB_CRED = credentials('dockerhub')
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    sh '''
                    echo "Setting up environment..."
                    minikube status || minikube start
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

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh '''
                    # Load the image into Minikube
                    minikube image load ${FLASK_IMAGE_NAME}
                    
                    # Deploy to Kubernetes
                    kubectl apply -f kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/service.yaml
                    
                    # Check deployment status
                    kubectl rollout status deployment/flask-app --timeout=60s
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh '''
                    # Get pod name
                    POD_NAME=$(kubectl get pods -l app=flask-app -o jsonpath='{.items[0].metadata.name}')
                    
                    # Check pod logs
                    echo "Pod logs:"
                    kubectl logs ${POD_NAME}
                    
                    # Get service URL
                    SERVICE_URL=$(minikube service flask-app --url)
                    echo "Service available at: ${SERVICE_URL}"
                    
                    # Test health endpoint
                    echo "Testing health endpoint..."
                    curl -s ${SERVICE_URL}/health || echo "Could not reach health endpoint"
                    '''
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
            echo "Flask app deployed both in Docker container and Kubernetes."
            echo "Access the app at: http://localhost:5000 (Docker) or via Minikube service URL."
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
    }
}
