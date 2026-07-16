#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.prod.yml"
ENV_FILE="${SCRIPT_DIR}/.env"
HEALTH_URL="http://127.0.0.1:8080/health"
MAX_ATTEMPTS=30
SLEEP_SECONDS=2

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Error: ${ENV_FILE} does not exist."
  echo "Create it from deploy/.env.example."
  exit 1
fi

echo "=================================="
echo "Production deployment"
echo "=================================="

docker compose \
  --env-file "${ENV_FILE}" \
  -f "${COMPOSE_FILE}" \
  pull

docker compose \
  --env-file "${ENV_FILE}" \
  -f "${COMPOSE_FILE}" \
  up -d --remove-orphans

echo "Waiting for the application health check..."

for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
  if curl --silent --fail "${HEALTH_URL}" > /dev/null; then
    echo "Application is healthy."
    echo "Deployment completed successfully."
    exit 0
  fi

  echo "Health check attempt ${attempt}/${MAX_ATTEMPTS} failed."
  sleep "${SLEEP_SECONDS}"
done

echo "Deployment failed: application did not become healthy."

docker compose \
  --env-file "${ENV_FILE}" \
  -f "${COMPOSE_FILE}" \
  ps

docker compose \
  --env-file "${ENV_FILE}" \
  -f "${COMPOSE_FILE}" \
  logs --tail=100 app nginx

exit 1
