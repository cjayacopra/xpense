# Xpense - Laravel Expense Tracker

A modern expense tracking application built with Laravel, Vue.js, and Inertia.js.

## Deployment

This application can be deployed using Docker with FrankenPHP and SQLite. All deployment files have been prepared:

1. **Dockerfile** - Defines the application container using FrankenPHP
2. **docker-compose.yml** - Orchestrates the application services
3. **install.sh** - One-liner installation script
4. **.github/workflows/ci-cd.yml** - GitHub Actions CI/CD pipeline

## Prerequisites

- Docker
- Docker Compose

## Quick Deployment

1. Clone the repository:

    ```bash
    git clone <repository-url>
    cd xpense
    ```

2. Build and start the application:

    ```bash
    docker compose up -d --build
    ```

3. Run database migrations:

    ```bash
    docker compose exec app php artisan migrate --force
    ```

4. Access the application at http://localhost:8000

## One-liner Installation

```bash
curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash
```

## CI/CD Pipeline

The project includes a GitHub Actions workflow that:

- Runs tests on every push and pull request
- Builds and pushes Docker images to Docker Hub on pushes to the main branch

## Managing the Application

- Stop the application: `docker-compose down`
- View logs: `docker-compose logs -f`
- Rebuild: `docker-compose up -d --build`
