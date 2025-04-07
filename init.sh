#!/bin/bash
docker compose  up -d

mkdir -p ./dl-plugins
wget -P .//plugins https://updates.jenkins.io/download/plugins/gitea/latest/gitea.hpi https://updates.jenkins.io/download/plugins/workflow-aggregator/latest/workflow-aggregator.hpi https://updates.jenkins.io/download/plugins/configuration-as-code/latest/configuration-as-code.hpi https://updates.jenkins.io/download/plugins/docker-workflow/latest/docker-workflow.hpi https://updates.jenkins.io/download/plugins/telegram-notifications/latest/telegram-notifications.hpi https://updates.jenkins.io/download/plugins/generic-webhook-trigger/latest/generic-webhook-trigger.hpi

docker cp ./dl-plugins jenkins:/var/jenkins_home/
docker restart jenkins

rm -rf ./dl-plugins
