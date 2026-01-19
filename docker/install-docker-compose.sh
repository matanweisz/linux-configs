#!/usr/bin/env bash
set -euo pipefail

# Install Docker Compose standalone binary
# Note: If you installed Docker using install-docker.sh, the compose plugin is already included.
# This script installs the standalone 'docker-compose' command for compatibility with older scripts.

DOCKER_CONFIG="${DOCKER_CONFIG:-$HOME/.docker}"
COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64"

# Create CLI plugins directory
mkdir -p "$DOCKER_CONFIG/cli-plugins"

# Download Docker Compose
echo "Downloading Docker Compose..."
curl -SL "$COMPOSE_URL" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"

# Make executable
chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"

# Verify installation
docker compose version

echo ""
echo "Docker Compose installed successfully."
