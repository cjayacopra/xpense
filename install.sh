#!/bin/bash

# Xpense - One-liner installation script
# Usage: curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if required tools are installed
check_dependencies() {
    local deps=("git" "docker")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        error "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Main installation function
install_xpense() {
    log "Starting Xpense installation..."
    
    # Create installation directory
    local install_dir="${HOME}/xpense"
    log "Creating installation directory at ${install_dir}"
    mkdir -p "$install_dir"
    cd "$install_dir"
    
    # Clone the repository
    log "Cloning repository..."
    git clone https://github.com/cjayacopra/xpense.git .
    
    # Create database directory
    log "Creating database directory..."
    mkdir -p database
    
    # Create SQLite database file
    log "Creating SQLite database file..."
    touch database/database.sqlite
    
    # Set proper permissions
    log "Setting database permissions..."
    chmod 664 database/database.sqlite
    
    # Create a simple docker-compose.override.yml for development
    log "Creating docker-compose override file..."
    cat > docker-compose.override.yml << EOF
services:
  app:
    volumes:
      - .:/app
      - ./database:/app/database
EOF
    
    # Pull the latest images
    log "Pulling Docker images..."
    docker compose pull
    
    # Start Docker containers
    log "Starting Docker containers..."
    docker compose up -d
    
    # Wait for the application to be ready
    log "Waiting for application to start..."
    sleep 15
    
    # Generate application key
    log "Generating application key..."
    docker compose exec app php artisan key:generate --force
    
    # Run database migrations
    log "Running database migrations..."
    docker compose exec app php artisan migrate --force
    
    log "Installation completed successfully!"
    echo
    log "Your Xpense application is now running at: http://localhost:8000"
    log "To stop the application, run: docker compose down"
    log "To view logs, run: docker compose logs -f"
}

# Main execution
main() {
    log "Xpense Installation Script"
    echo "================================"
    
    check_dependencies
    install_xpense
    
    log "Enjoy your Xpense application!"
}

# Run main function if script is executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi