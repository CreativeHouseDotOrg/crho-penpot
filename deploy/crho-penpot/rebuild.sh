#!/usr/bin/env bash
# Rebuilds the crho-penpot frontend + MCP images from this checkout and restarts them.
# Usage: deploy/crho-penpot/rebuild.sh [--no-restart]
# Needs: Docker (>= 16 GB memory limit recommended), rsync, git.
# The checkout must live under $HOME (Docker Desktop cannot bind-mount /tmp paths).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STACK_DIR="${CRHO_STACK_DIR:-$HOME/repos/crho-penpot}"   # runtime dir holding .env
cd "$REPO"

case "$REPO" in
  "$HOME"/*) ;;
  *) echo "error: $REPO is not under \$HOME; Docker cannot mount it" >&2; exit 1;;
esac

echo ">> bundles"
./manage.sh build-mcp-bundle
./manage.sh build-frontend-bundle

echo ">> images"
cd "$REPO/docker/images"
rsync -ar --delete "$REPO/bundles/frontend/" ./bundle-frontend/
rsync -ar --delete "$REPO/bundles/mcp/"      ./bundle-mcp/
docker build -t crho-penpot/frontend:2.19.1 --build-arg BUNDLE_PATH=./bundle-frontend/ -f Dockerfile.crho-frontend .
docker build -t crho-penpot/mcp:2.19.1      --build-arg BUNDLE_PATH=./bundle-mcp/      -f Dockerfile.crho-mcp .

echo ">> stack ($STACK_DIR)"
mkdir -p "$STACK_DIR"
[ -f "$STACK_DIR/compose.yaml" ] || cp "$REPO/deploy/crho-penpot/compose.yaml" "$STACK_DIR/compose.yaml"
[ -f "$STACK_DIR/.env" ] || { cp "$REPO/deploy/crho-penpot/.env.example" "$STACK_DIR/.env"; echo "created $STACK_DIR/.env - fill in the secrets, then re-run" >&2; exit 1; }
if [ "${1:-}" != "--no-restart" ]; then
  cd "$STACK_DIR" && docker compose up -d --force-recreate penpot-frontend penpot-mcp
fi
echo ">> done"
