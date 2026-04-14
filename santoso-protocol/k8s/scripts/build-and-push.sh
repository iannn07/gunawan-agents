#!/usr/bin/env bash
# Builds and pushes both images to Docker Hub.
# Assumes `docker login` has already been done (or will prompt interactively).
set -euo pipefail

REPO_USER="iannn07"
PAPERCLIP_TAG="2026.403.0-patched"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
K8S_DIR="${PROJECT_ROOT}/k8s"

cd "${PROJECT_ROOT}"

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: docker daemon is not reachable. Install/start Docker first." >&2
  exit 1
fi

# Ensure we're logged in
if ! docker info 2>/dev/null | grep -q "Username: ${REPO_USER}"; then
  echo "==> docker login (Docker Hub) — interactive"
  docker login
fi

echo "==> Building paperclip image"
docker build \
  -t "docker.io/${REPO_USER}/paperclip-gunawan:${PAPERCLIP_TAG}" \
  -t "docker.io/${REPO_USER}/paperclip-gunawan:latest" \
  -f "${K8S_DIR}/docker/paperclip/Dockerfile" \
  "${K8S_DIR}/docker/paperclip"

echo "==> Building telegram-bridge image"
docker build \
  -t "docker.io/${REPO_USER}/santoso-telegram-bridge:latest" \
  -f "${PROJECT_ROOT}/telegram-bridge/Dockerfile.bridge" \
  "${PROJECT_ROOT}/telegram-bridge"

echo "==> Pushing paperclip"
docker push "docker.io/${REPO_USER}/paperclip-gunawan:${PAPERCLIP_TAG}"
docker push "docker.io/${REPO_USER}/paperclip-gunawan:latest"

echo "==> Pushing telegram-bridge"
docker push "docker.io/${REPO_USER}/santoso-telegram-bridge:latest"

echo
echo "==> Done. Tags pushed:"
echo "    docker.io/${REPO_USER}/paperclip-gunawan:${PAPERCLIP_TAG}"
echo "    docker.io/${REPO_USER}/paperclip-gunawan:latest"
echo "    docker.io/${REPO_USER}/santoso-telegram-bridge:latest"
