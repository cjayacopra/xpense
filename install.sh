#!/bin/bash

# Xpense - One-liner installation script
# Usage: curl -fsSL https://raw.githubusercontent.com/your-username/your-repo/main/install.sh | bash

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
    local deps=("git" "docker" "docker-compose")
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
    git clone https://github.com/your-username/your-repo.git .
    
    # Generate application key
    log "Generating application key..."
    local app_key=$(php -r "echo 'base64:' . base64_encode(random_bytes(32));" 2>/dev/null || echo "base64:your-generated-key-here")
    
    # Create .env file
    log "Creating environment file..."
    cat > .env << EOF
APP_NAME=Xpense
APP_ENV=production
APP_KEY=${app_key}
APP_DEBUG=false
APP_URL=http://localhost:8000

DB_CONNECTION=sqlite
DB_DATABASE=/app/database/database.sqlite

SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database
EOF
    
    # Build and start Docker containers
    log "Building and starting Docker containers..."
    docker-compose up -d --build
    
    # Wait for the application to be ready
    log "Waiting for application to start..."
    sleep 10
    
    # Run database migrations
    log "Running database migrations..."
    docker-compose exec app php artisan migrate --force
    
    # Optimize Laravel
    log "Optimizing Laravel..."
    docker-compose exec app php artisan config:cache
    docker-compose exec app php artisan route:cache
    docker-compose exec app php artisan view:cache
    
    log "Installation completed successfully!"
    echo
    log "Your Xpense application is now running at: http://localhost:8000"
    log "To stop the application, run: docker-compose down"
    log "To view logs, run: docker-compose logs -f"
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