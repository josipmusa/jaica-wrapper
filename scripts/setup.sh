#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_cmd git
require_cmd docker

# Docker Compose v2 is `docker compose`
docker compose version >/dev/null 2>&1 || {
  echo "Docker Compose v2 not found (expected: 'docker compose')." >&2
  exit 1
}

echo "Initializing git submodules..."
git submodule update --init --recursive

# Optional: scaffold .env if repo provides an example
if [[ ! -f "$ROOT_DIR/.env" && -f "$ROOT_DIR/.env.example" ]]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  echo "Created .env from .env.example"
fi

echo "Setup complete."
