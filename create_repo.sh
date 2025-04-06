#!/bin/bash
set -e

GITEA_URL="http://gitea:3000"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin123"
REPO_NAME="hello-world"
WEBHOOK_URL="http://jenkins:8080/generic-webhook-trigger/invoke?token=SECRET_TOKEN"

# Генерация токена
ADMIN_TOKEN=$(curl -s -X POST "${GITEA_URL}/api/v1/users/${ADMIN_USER}/tokens" \
  -H "Content-Type: application/json" \
  -u "${ADMIN_USER}:${ADMIN_PASSWORD}" \
  -d '{"name": "jenkins"}' | jq -r .sha1)

# Создание репозитория
curl -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Authorization: token ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": true}"

# Настройка вебхука
curl -X POST "${GITEA_URL}/api/v1/repos/${ADMIN_USER}/${REPO_NAME}/hooks" \
  -H "Authorization: token ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"type\": \"gitea\", \"config\": {\"url\": \"${WEBHOOK_URL}\"}, \"active\": true}"

echo "✅ Репозиторий ${REPO_NAME} создан!"
