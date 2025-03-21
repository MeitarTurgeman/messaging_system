pipeline {
    agent any

    environment {
        DOCKER_USER = "meitarturgeman"
        FLASK_CONTAINER_NAME = "flask-app"
        FLASK_IMAGE_NAME = "meitarturgeman/messages-api:latest"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_HUB_CRED = credentials('dockerhub')
        K8S_AVAILABLE = false
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    sh '''
                    echo "Setting up environment..."
                    
                    # Test if we can connect to Kubernetes with a timeout
                    if timeout 5 kubectl get nodes &>/dev/null; then
                        echo "Kubernetes is accessible"
                        export K8S_AVAILABLE=true
                    else
                        echo "Kubernetes is not accessible, will use Docker only"
                        export K8S_AVAILABLE=false
                    fi
                    '''
                    
                    // Set the K8S_AVAILABLE environment variable for the pipeline
                    K8S_AVAILABLE = sh(script: 'timeout 5 kubectl get nodes &>/dev/null && echo true || echo false', returnStdout: true).trim() == 'true'
                    echo "Kubernetes available: ${K8S_AVAILABLE}"
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
                    return K8S_AVAILABLE
                }
            }
            steps {
                script {
                    echo "Attempting to deploy to Kubernetes - this may fail if connectivity issues persist"
                    try {
                        sh '''
                        # Deploy to Kubernetes
                        kubectl apply -f kubernetes/deployment.yaml --validate=false
                        kubectl apply -f kubernetes/service.yaml --validate=false
                        
                        # Check deployment status
                        kubectl rollout status deployment/flask-app --timeout=60s
                        '''
                    } catch (Exception e) {
                        echo "Kubernetes deployment failed: ${e.message}"
                        echo "Continuing with pipeline..."
                    }
                }
            }
        }
        
        stage('Verify Kubernetes Deployment') {
            when {
                expression {
                    return K8S_AVAILABLE
                }
            }
            steps {
                script {
                    try {
                        sh '''
                        # Get pod name
                        POD_NAME=$(kubectl get pods -l app=flask-app -o jsonpath='{.items[0].metadata.name}')
                        
                        # Check pod logs
                        echo "Pod logs:"
                        kubectl logs ${POD_NAME}
                        
                        # Get service details
                        echo "Service details:"
                        kubectl get svc flask-app
                        '''
                    } catch (Exception e) {
                        echo "Kubernetes verification failed: ${e.message}"
                        echo "Continuing with pipeline..."
                    }
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
            
            script {
                if (K8S_AVAILABLE) {
                    echo "Also deployed to Kubernetes (if available)"
                } else {
                    echo "Kubernetes deployment was skipped due to connectivity issues"
                }
            }
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
    }
}
