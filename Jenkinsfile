pipeline {
    agent any

    parameters {
        booleanParam(name: 'FORCE_BUILD', defaultValue: false)
    }

    environment {
        GITEA_URL = "http://gitea:3000"
        GITEA_TOKEN = credentials('gitea-token')
        TELEGRAM_TOKEN = credentials('telegram-token')
        TELEGRAM_CHAT_ID = "YOUR_CHAT_ID"
        APP_NAME = "hello-world"
        APP_PORT = "5000"
    }

    stages {
        stage('Check PR') {
            steps {
                script {
                    if (env.CHANGE_ID == null) {
                        error("Not a PR build. Exiting.")
                    }

                    def prData = sh(
                        script: "curl -s -H 'Authorization: token ${GITEA_TOKEN}' ${GITEA_URL}/api/v1/repos/admin/hello-world/pulls/${env.CHANGE_ID} || echo '{}'",
                        returnStdout: true
                    )

                    def prTitle = jq -r '.title' <<< "${prData}"
                    if (prTitle.contains("[WIP]") && !params.FORCE_BUILD) {
                        currentBuild.result = 'NOT_BUILT'
                        
                        sh """
                            curl -X POST -H "Authorization: token ${GITEA_TOKEN}" \
                            ${GITEA_URL}/api/v1/repos/admin/hello-world/issues/${env.CHANGE_ID}/comments \
                            -d '{"body": "🚫 Сборка заблокирована: WIP-статус"}'
                        """
                        error("Сборка пропущена из-за WIP-статуса")
                    }
                }
            }
        }

        stage('Build') {
            steps {
                sh """
                    docker build -t ${APP_NAME} ./app
                    docker tag ${APP_NAME} ${APP_NAME}:\$(date +%Y%m%d%H%M)
                """
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                        if docker ps -a | grep ${APP_NAME}; then
                            docker stop ${APP_NAME} || true
                            docker rm ${APP_NAME} || true
                        fi
                    """

                    sh """
                        docker run -d \
                            --name ${APP_NAME} \
                            -p ${APP_PORT}:5000 \
                            --restart unless-stopped \
                            ${APP_NAME}
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                def status = currentBuild.result ?: 'SUCCESS'
                sh """
                    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
                    -d "chat_id=${TELEGRAM_CHAT_ID}&text=Build status: ${status}"
                """
            }
        }
    }
}
