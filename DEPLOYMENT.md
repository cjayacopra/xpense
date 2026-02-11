# Xpense Deployment Guide

This guide explains how to deploy the Xpense application using Docker with FrankenPHP and SQLite.

## Prerequisites

Before deploying, ensure you have the following installed:

- Docker
- Docker Compose
- Git
- PHP CLI (for key generation)

## Deployment Options

### 1. One-liner Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash
```

This script will:

1. Clone the repository
2. Generate an application key
3. Create necessary environment filoose the appropriate JSONes
4. Build and start Docker containers
5. Run database migrations
6. Optimize the Laravel application

### 2. Manual Deployment

1. Clone the repository:

    ```bash
    git clone https://github.com/cjayacopra/xpense.git
    cd xpense
    ```

2. Generate an application key and add it to your `.env` file:

    ```bash
    echo "APP_KEY=$(php -r "echo 'base64:' . base64_encode(random_bytes(32));")" >> .env
    ```

3. Build and start the services:

    ```bash
    docker-compose up -d --build
    ```

4. Run database migrations:

    ```bash
    docker-compose exec app php artisan migrate --force
    ```

5. Optimize the Laravel application:
    ```bash
    docker-compose exec app php artisan config:cache
    docker-compose exec app php artisan route:cache
    docker-compose exec app php artisan view:cache
    ```

## Accessing the Application

After deployment, the application will be available at: http://localhost:8000

## Managing the Application

- To stop the application: `docker-compose down`
- To view logs: `docker-compose logs -f`
- To rebuild the application: `docker-compose up -d --build`

## CI/CD Pipeline

This project includes a GitHub Actions workflow that:

1. Runs tests on every push and pull request
2. Builds and pushes Docker images to Docker Hub on pushes to the main branch

To use the CI/CD pipeline, you'll need to set up the following secrets in your GitHub repository:

- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Your Docker Hub access token

## Troubleshooting

If you encounter issues:

1. Check Docker container logs: `docker-compose logs`
2. Ensure all prerequisites are installed
3. Verify that ports 8000 is available on your system
