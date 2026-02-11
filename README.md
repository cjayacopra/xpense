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

## Quick Installation (One-liner)

The easiest way to get started is by running our automated installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash
```

This script will:
1. Clone the repository to `~/xpense`
2. Set up your environment and database
3. Build and start the Docker containers
4. Generate your application security keys
5. Run all necessary migrations

## Manual Deployment

## CI/CD Pipeline

The project includes a GitHub Actions workflow that:

- Runs tests on every push and pull request
- Builds and pushes Docker images to Docker Hub on pushes to the main branch

## Managing the Application

- Stop the application: `docker compose down`
- View logs: `docker compose logs -f`
- Rebuild: `docker compose up -d --build`
