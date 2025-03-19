pipeline {
    agent any

    environment {
        DOCKER_USER = "meitarturgeman"
        FLASK_CONTAINER_NAME = "flask-app"
        FLASK_IMAGE_NAME = "meitarturgeman/messages-api:latest"
        DOCKER_REGISTRY = "docker.io"
        MINIKUBE_IP = sh(script: 'minikube ip', returnStdout: true).trim()
        DOCKER_HUB_TOKEN = credentials('DOCKER_HUB_TOKEN')
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'DOCKER_HUB_TOKEN', variable: 'DOCKER_HUB_TOKEN')]) {
                        sh """
                        echo "\$DOCKER_HUB_TOKEN" | docker login -u ${DOCKER_USER} --password-stdin || true
                        """
                    }
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
        
        stage('Push Image to Docker Hub (Optional)') {
            steps {
                script {
                    sh """
                    docker push ${FLASK_IMAGE_NAME} || echo "Skipping push to Docker Hub"
                    """
                }
            }
        }

        stage('Load Image to Minikube') {
            steps {
                script {
                    sh """
                    minikube image load ${FLASK_IMAGE_NAME} || true
                    """
                }
            }
        }

        stage('Deploy Flask Locally') {
            steps {
                script {
                    sh """
                    docker stop ${FLASK_CONTAINER_NAME} || true
                    docker rm ${FLASK_CONTAINER_NAME} || true
                    docker run -d --name ${FLASK_CONTAINER_NAME} -p 5000:5000 ${FLASK_IMAGE_NAME}
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    # Connect to Kubernetes using certificates
                    kubectl --server=https://${MINIKUBE_IP}:8443 \
                           --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                           --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                           --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                           apply -f kubernetes/deployment.yaml
                           
                    kubectl --server=https://${MINIKUBE_IP}:8443 \
                           --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                           --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                           --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                           apply -f kubernetes/service.yaml
                    
                    # Check deployment status
                    echo "Deployment status:"
                    kubectl --server=https://${MINIKUBE_IP}:8443 \
                           --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                           --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                           --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                           get pods
                           
                    # Get service info
                    echo "Service details:"
                    kubectl --server=https://${MINIKUBE_IP}:8443 \
                           --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                           --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                           --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                           get services
                    
                    # Display access URL
                    echo "Getting NodePort..."
                    NODE_PORT=\$(kubectl --server=https://${MINIKUBE_IP}:8443 \
                                       --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                                       --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                                       --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                                       get service flask-app -o jsonpath='{.spec.ports[0].nodePort}')
                    
                    echo "Your application is accessible at: http://${MINIKUBE_IP}:\${NODE_PORT}"
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh """
                    # Wait for deployment to be ready
                    kubectl --server=https://${MINIKUBE_IP}:8443 \
                           --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                           --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                           --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                           rollout status deployment/flask-app --timeout=60s
                    
                    # Get pod name
                    POD_NAME=\$(kubectl --server=https://${MINIKUBE_IP}:8443 \
                                      --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                                      --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                                      --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                                      get pods -l app=flask-app -o jsonpath='{.items[0].metadata.name}')
                    
                    # Check pod logs
                    echo "Pod logs:"
                    kubectl --server=https://${MINIKUBE_IP}:8443 \
                           --certificate-authority=/var/jenkins_home/.minikube/ca.crt \
                           --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
                           --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key \
                           logs \${POD_NAME}
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "CI/CD Pipeline completed successfully!"
            echo "Flask application is running in Docker container and Kubernetes."
        }
        failure {
            echo "CI/CD Pipeline failed. Please check the logs for details."
        }
    }
}