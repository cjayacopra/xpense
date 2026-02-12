#!/bin/bash

# Xpense - Docker Development Environment Setup
# Usage: ./install.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "Starting Xpense Docker development setup..."

# Check dependencies
for dep in git docker; do
    command -v "$dep" >/dev/null 2>&1 || error "Missing dependency: $dep"
done

# Configure .env
log "Configuring environment..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    log "Environment file created from .env.example"
fi

# Setup database file
log "Preparing SQLite database..."
mkdir -p database
touch database/database.sqlite
chmod 666 database/database.sqlite

# Build and start containers
log "Building and starting Docker containers..."
docker compose up -d --build

# Install dependencies inside container
log "Installing PHP dependencies..."
docker compose exec app composer install

log "Installing Node dependencies..."
docker compose exec app npm install

log "Generating application key..."
docker compose exec app php artisan key:generate --ansi

log "Running database migrations..."
docker compose exec app php artisan migrate --force --ansi

log "Setup completed successfully!"
echo -e "${GREEN}================================================================${NC}"
log "Xpense is running at: http://localhost:8000"
log "Vite Dev Server (HMR): http://localhost:5173"
log ""
log "To see logs: docker compose logs -f"
log "To stop: docker compose down"
echo -e "${GREEN}================================================================${NC}"
