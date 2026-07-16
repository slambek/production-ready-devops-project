#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.prod.yml"
ENV_FILE="${SCRIPT_DIR}/.env"
HEALTH_URL="http://127.0.0.1:8080/health"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <previous-image-tag>"
  echo "Example: $0 sha-abc123"
  exit 1
fi

IMAGE_TAG="$1"
IMAGE_REPOSITORY="ghcr.io/slambek/production-ready-devops-project"
ROLLBACK_IMAGE="${IMAGE_REPOSITORY}:${IMAGE_TAG}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Error: ${ENV_FILE} does not exist."
  exit 1
fi

echo "Rolling back to ${ROLLBACK_IMAGE}"

APP_IMAGE="${ROLLBACK_IMAGE}" docker compose \
  --env-file "${ENV_FILE}" \
  -f "${COMPOSE_FILE}" \
  pull app

APP_IMAGE="${ROLLBACK_IMAGE}" docker compose \
  --env-file "${ENV_FILE}" \
  -f "${COMPOSE_FILE}" \
  up -d app nginx

sleep 10

if curl --silent --fail "${HEALTH_URL}" > /dev/null; then
  echo "Rollback completed successfully."
else
  echo "Rollback failed health check."
  exit 1
fi
