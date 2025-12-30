#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ "${1:-}" == "--volumes" ]]; then
  echo "Stopping stack and removing volumes (DATA WILL BE LOST)..."
  docker compose down --volumes
else
  echo "Stopping stack..."
  docker compose down
fi
