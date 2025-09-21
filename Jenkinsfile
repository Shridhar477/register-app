pipeline {
    agent any

    tools {
        jdk 'Java'
        maven 'Maven'
    }

    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout from SCM") {
            steps {
                git url: "https://github.com/rohitrawat891997/register-app", branch: "main"
            }
        }

        stage("SonarQube Quality Analysis") {
            steps {
                withSonarQubeEnv("Sonar") {
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectName=register-app \
                        -Dsonar.projectKey=register-app
                    '''
                }
            }
        }

        stage("Sonar Quality Gate Scan") {
            steps {
                timeout(time: 2, unit: "MINUTES") {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage("Docker Build") {
            steps {
                withCredentials([usernamePassword(credentialsId: "DockerHub", usernameVariable: "DOCKER_USER", passwordVariable: "DOCKER_PASS")]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t register-app:latest .
                    """
                }
            }
        }

        stage("Docker Push") {
            steps {
                withCredentials([usernamePassword(credentialsId: "DockerHub", usernameVariable: "DOCKER_USER", passwordVariable: "DOCKER_PASS")]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag register-app:latest $DOCKER_USER/register-app:latest
                        docker push $DOCKER_USER/register-app:latest
                        docker logout
                    """
                }
            }
        }

        stage("Trivy Scan") {
            steps {
                withCredentials([usernamePassword(credentialsId: "DockerHub", usernameVariable: "DOCKER_USER", passwordVariable: "DOCKER_PASS")]) {
                    sh '''
                        trivy image --severity HIGH,CRITICAL "$DOCKER_USER"/register-app:latest \
                        --no-progress --scanners vuln \
                        --exit-code 0 \
                        --format table
                    '''
                }
            }
        }

        stage("Deploy using Docker compose") {
            steps {
                sh " docker-compose up -d"
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "✅ Build, SonarQube scan, and Docker push completed successfully."
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}
