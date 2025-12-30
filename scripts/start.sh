#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Ensure submodules are present (fast, idempotent)
if [[ ! -d "$ROOT_DIR/backend" || ! -d "$ROOT_DIR/frontend" ]]; then
  echo "backend/ or frontend/ directory missing. Run ./scripts/setup.sh first." >&2
  exit 1
fi

# If directories exist but are empty, it's likely submodules weren't initialized.
if [[ -z "$(ls -A "$ROOT_DIR/backend" 2>/dev/null || true)" || -z "$(ls -A "$ROOT_DIR/frontend" 2>/dev/null || true)" ]]; then
  echo "backend/ or frontend/ looks empty. Initializing submodules..."
  git submodule update --init --recursive
fi

echo "Starting JAICA stack (build + detach)..."
docker compose up -d --build

echo "Waiting for backend health endpoint..."
# Health endpoint exposed on host:8000. Compose also has its own healthcheck, but this gives quick feedback.
for i in {1..60}; do
  if curl -fsS "http://localhost:8000/api/status" >/dev/null 2>&1; then
    echo "Backend is up. Frontend: http://localhost:3000"
    exit 0
  fi
  sleep 2
done

echo "Backend did not become ready in time." >&2
echo "Try: ./scripts/logs.sh jaica-backend" >&2
exit 1
