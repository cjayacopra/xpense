#!/bin/bash

# Xpense - One-liner installation script
# Usage: curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash

set -e

# Global variables
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log() { 
    if [ "$DRY_RUN" = false ]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    else
        echo -e "${GREEN}[DRY-RUN]${NC} $1"
    fi
}

warn() { 
    if [ "$DRY_RUN" = false ]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    else
        echo -e "${YELLOW}[DRY-RUN]${NC} $1"
    fi
}

error() { 
    if [ "$DRY_RUN" = false ]; then
        echo -e "${RED}[ERROR]${NC} $1"
    else
        echo -e "${RED}[DRY-RUN]${NC} $1"
    fi
}

# Show help
show_help() {
    echo "Xpense Installation Script"
    echo "=========================="
    echo "Installs Xpense application using Docker"
    echo ""
    echo "Usage:"
    echo "  curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash"
    echo "  curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash -s -- --dry-run"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without actually doing it"
    echo "  --help       Show this help message"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

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
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$install_dir"
        cd "$install_dir"
    fi
    
    # Clone the repository
    log "Cloning repository..."
    if [ "$DRY_RUN" = false ]; then
        git clone https://github.com/cjayacopra/xpense.git .
    fi
    
    # Create database directory
    log "Creating database directory..."
    if [ "$DRY_RUN" = false ]; then
        mkdir -p database
    fi
    
    # Create SQLite database file
    log "Creating SQLite database file..."
    if [ "$DRY_RUN" = false ]; then
        touch database/database.sqlite
    fi
    
    # Set proper permissions
    log "Setting database permissions..."
    if [ "$DRY_RUN" = false ]; then
        chmod 664 database/database.sqlite
    fi
    
    # Create a simple docker-compose.override.yml for development
    log "Creating docker-compose override file..."
    if [ "$DRY_RUN" = false ]; then
        cat > docker-compose.override.yml << EOF
services:
  app:
    volumes:
      - .:/app
      - ./database:/app/database
EOF
    fi
    
    # Pull the latest images
    log "Pulling Docker images..."
    if [ "$DRY_RUN" = false ]; then
        docker compose pull
    fi
    
    # Start Docker containers
    log "Starting Docker containers..."
    if [ "$DRY_RUN" = false ]; then
        docker compose up -d
    fi
    
    # Wait for the application to be ready
    log "Waiting for application to start..."
    if [ "$DRY_RUN" = false ]; then
        sleep 15
    fi
    
    # Generate application key
    log "Generating application key..."
    if [ "$DRY_RUN" = false ]; then
        docker compose exec app php artisan key:generate --force
    fi
    
    # Run database migrations
    log "Running database migrations..."
    if [ "$DRY_RUN" = false ]; then
        docker compose exec app php artisan migrate --force
    fi
    
    log "Installation completed successfully!"
    echo
    log "Your Xpense application is now running at: http://localhost:8000"
    log "To stop the application, run: docker compose down"
    log "To view logs, run: docker compose logs -f"
}

# Main execution
main() {
    parse_args "$@"
    
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