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
    if [ "$DRY_RUN" = false ]; then
        if [ ! -d "$install_dir" ]; then
            log "Creating installation directory at ${install_dir}"
            mkdir -p "$install_dir"
        fi
        cd "$install_dir"
    else
        log "Would create installation directory at ${install_dir}"
    fi
    
    # Clone the repository
    log "Preparing repository..."
    if [ "$DRY_RUN" = false ]; then
        if [ -d ".git" ]; then
            warn "Repository already exists, pulling latest changes..."
            git pull
        else
            git clone https://github.com/cjayacopra/xpense.git .
        fi
    fi

    # Create .env file
    log "Configuring environment..."
    if [ "$DRY_RUN" = false ]; then
        if [ ! -f ".env" ]; then
            cp .env.example .env
            # Generate a unique valid 32-byte key on the host
            log "Generating unique application key..."
            if command -v openssl >/dev/null; then
                GEN_KEY=$(openssl rand -base64 32)
            else
                GEN_KEY=$(head -c 32 /dev/urandom | base64 | tr -d '\n')
            fi
            sed -i "s|APP_KEY=|APP_KEY=base64:$GEN_KEY|" .env
        fi
    fi
    
    # Create database directory and file
    log "Setting up database file..."
    if [ "$DRY_RUN" = false ]; then
        mkdir -p database
        touch database/database.sqlite
        # Ensure it is writable by the container user (UID 1000 usually)
        chmod 666 database/database.sqlite
    fi
    
    # Build and start containers
    log "Building and starting Docker containers..."
    if [ "$DRY_RUN" = false ]; then
        docker compose up -d --build
    fi
    
    # Wait for the application to be ready
    log "Waiting for application to start..."
    if [ "$DRY_RUN" = false ]; then
        local max_attempts=12
        local attempt=1
        while [ $attempt -le $max_attempts ]; do
            status=$(docker inspect -f '{{.State.Health.Status}}' xpense-app 2>/dev/null || echo "starting")
            if [ "$status" == "healthy" ]; then
                log "Application is healthy!"
                break
            fi
            warn "Waiting for application to be healthy... (Attempt $attempt/$max_attempts)"
            sleep 5
            attempt=$((attempt + 1))
        done
    fi
    
    # Generate application key
    log "Generating final application key..."
    if [ "$DRY_RUN" = false ]; then
        # Use -T to avoid "input device is not a TTY" error
        docker compose exec -T app php artisan key:generate --force
        # Clear config cache to ensure the new key is picked up
        docker compose exec -T app php artisan config:clear
    fi
    
    # Run database migrations
    log "Running database migrations..."
    if [ "$DRY_RUN" = false ]; then
        docker compose exec -T app php artisan migrate --force
    fi
    
    log "Installation completed successfully!"
    echo
    echo -e "${GREEN}================================================================${NC}"
    log "Your Xpense application is now running at: http://localhost:8000"
    log "To stop the application, run: docker compose down"
    log "To view logs, run: docker compose logs -f"
    echo -e "${GREEN}================================================================${NC}"
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

# Run main function
main "$@"
