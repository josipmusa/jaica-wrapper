#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Usage:
#   ./scripts/logs.sh           # all services
#   ./scripts/logs.sh SERVICE   # one service

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [service]" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  docker compose logs -f --tail=200 "$1"
else
  docker compose logs -f --tail=200
fi
