#!/bin/bash
set -e

REMOTE_HOST="${1:?Usage: ./deploy.sh <user@host> [image-registry]}"
REGISTRY="${2:-}"
IMAGE_NAME="geminabox:latest"

PLATFORM="${PLATFORM:-linux/amd64}"

echo "==> Building image for ${PLATFORM}..."
docker build --platform "$PLATFORM" -t "$IMAGE_NAME" .

if [ -n "$REGISTRY" ]; then
  REMOTE_IMAGE="${REGISTRY}/${IMAGE_NAME}"
  echo "==> Pushing to registry ${REGISTRY}..."
  docker tag "$IMAGE_NAME" "$REMOTE_IMAGE"
  docker push "$REMOTE_IMAGE"

  echo "==> Deploying on ${REMOTE_HOST}..."
  scp docker-compose.yml "${REMOTE_HOST}:~/geminabox/"
  ssh "$REMOTE_HOST" "cd ~/geminabox && \
    sed -i 's|image: geminabox:latest|image: ${REMOTE_IMAGE}|' docker-compose.yml && \
    docker compose pull && \
    docker compose up -d"
else
  echo "==> Saving image to tarball..."
  docker save "$IMAGE_NAME" -o geminabox.tar

  echo "==> Uploading to ${REMOTE_HOST}..."
  ssh "$REMOTE_HOST" "mkdir -p ~/geminabox"
  scp geminabox.tar docker-compose.yml "${REMOTE_HOST}:~/geminabox/"
  rm -f geminabox.tar

  echo "==> Loading image and starting on ${REMOTE_HOST}..."
  ssh "$REMOTE_HOST" "cd ~/geminabox && \
    docker load -i geminabox.tar && \
    rm -f geminabox.tar && \
    docker compose up -d"
fi

echo "==> Done. Geminabox is running at http://${REMOTE_HOST##*@}:9292"
