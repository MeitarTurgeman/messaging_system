pipeline {
    agent any
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh '''
                    FILE=app/__init__.py
                    OLD_VERSION=$(grep -oP '__version__ = "\\K[0-9]+\\.[0-9]+\\.[0-9]+' $FILE)
                    IFS='.' read -r MAJOR MINOR PATCH <<< "$OLD_VERSION"
                    NEW_PATCH=$((PATCH + 1))
                    NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
                    sed -i.bak "s/__version__ = \\".*\\"/__version__ = \\"$NEW_VERSION\\"/" $FILE
                    echo $NEW_VERSION > version.tmp
                    '''

                    def version = readFile('version.tmp').trim()
                    env.IMAGE_NAME = "${version}-${BUILD_NUMBER}"
                }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t meitarturgeman/messages-api:${IMAGE_NAME} ."
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push meitarturgeman/messages-api:${IMAGE_NAME}"
                    }
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    // def dockerCmd = 'docker run -d -p 5000:5000 meitarturgeman/messages-api:${IMAGE_NAME}'
                    // def dockerComposeCmd = "docker-compose -f docker-compose.yml up --detach"
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@18.184.54.160"
                    sshagent(['ec2-server-key']) {
                        sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    } 
                }
            }
        }
        stage('commit version update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'gitlab-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        // git config here for the first time run
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/meitarturgeman/messaging_system.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:main'
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully!"
            echo "Flask app deployed in Docker container."
        }
        failure {
            echo "Pipeline failed. Please check the logs for details."
        }
    }
}
