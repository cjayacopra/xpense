#!/bin/bash

# Xpense - Standalone Binary Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "Starting Xpense standalone installation..."

# Check dependencies
for dep in git docker; do
    command -v "$dep" >/dev/null 2>&1 || error "Missing dependency: $dep"
done

# Prepare directory
INSTALL_DIR="${HOME}/xpense"
if [ ! -d "$INSTALL_DIR" ]; then
    log "Creating installation directory at ${INSTALL_DIR}"
    mkdir -p "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"

# Clone or pull
log "Preparing repository..."
if [ -d ".git" ]; then
    git pull
else
    git clone https://github.com/cjayacopra/xpense.git .
fi

# Configure .env
log "Configuring environment..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    log "Generating unique application key..."
    GEN_KEY=$(openssl rand -base64 32)
    sed -i "s|APP_KEY=|APP_KEY=base64:$GEN_KEY|" .env
fi

# Setup database
log "Setting up database..."
mkdir -p database
touch database/database.sqlite
chmod 666 database/database.sqlite

# Build and start
log "Building standalone binary (this will take several minutes)..."
docker compose up -d --build

# Wait for the application to be ready
log "Waiting for application to start..."
local max_attempts=30
local attempt=1
while [ $attempt -le $max_attempts ]; do
    status=$(docker inspect -f '{{.State.Health.Status}}' xpense-app 2>/dev/null || echo "starting")
    if [ "$status" == "healthy" ]; then
        log "Application is healthy!"
        break
    fi
    warn "Waiting for application to be healthy... (Attempt $attempt/$max_attempts)"
    sleep 10
    attempt=$((attempt + 1))
done

# Run migrations using the standalone binary
log "Running database migrations..."
docker compose exec -T app /xpense php-cli artisan migrate --force

log "Installation completed successfully!"
echo -e "${GREEN}================================================================${NC}"
log "Xpense is running at: http://localhost:8000"
log "Architecture: Standalone FrankenPHP Binary"
echo -e "${GREEN}================================================================${NC}"
