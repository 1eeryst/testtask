#!/bin/bash
set -e

until curl -s http://localhost:3000 >/dev/null; do 
  sleep 1
done

gitea admin create-user \
  --username admin \
  --password admin123 \
  --email admin@devops.local \
  --admin

gitea admin create-user \
  --username devops \
  --password devops123 \
  --email devops@local \
  --must-change-password=false
