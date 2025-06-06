pipeline {
    agent any

    environment {
        DOCKER_IMAGE   = "meitarturgeman/messages-api"
        IMAGE_TAG      = "latest"
        K8S_NAMESPACE  = "default"
        DEPLOYMENT_NAME = "myapp-deployment"
    }

    stages {
        stage('Test') {
            agent {
                docker {
                    image 'python:3.11'
                    args '-v $HOME/.cache/pip:/root/.cache/pip'
                }
            }
            steps {
                echo "Installing dependencies and running tests..."
                sh "pip install --no-cache-dir -r requirements.txt"
                sh "pip install pytest"
                sh "pytest tests/"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                        sh "docker logout"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        withEnv(["KUBECONFIG=$KUBECONFIG_FILE"]) {
                            echo "Deploying to Kubernetes..."
                            sh """
                            kubectl set image deployment/${DEPLOYMENT_NAME} messages-api=${DOCKER_IMAGE}:${IMAGE_TAG} -n ${K8S_NAMESPACE}
                            kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${K8S_NAMESPACE}
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! Flask app deployed to Kubernetes."
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
        always {
            cleanWs()
        }
    }
}