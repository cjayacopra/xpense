# Xpense - Laravel Expense Tracker

A modern expense tracking application built with Laravel, Vue.js, Inertia.js, and Octane (FrankenPHP).

## Development Environment (Docker)

This application is designed to work on every system with Docker. It uses **Laravel Octane** with **FrankenPHP** for high performance and **Vite** for a seamless frontend development experience.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Quick Start

The easiest way to get started is with our automated installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/cjayacopra/xpense/main/install.sh | bash
```

Alternatively, if you have already cloned the repository:

```bash
chmod +x install.sh
./install.sh
```

This will:
1. Create your `.env` file.
2. Prepare the SQLite database.
3. Build and start the Docker containers.
4. Install all PHP and Node dependencies.
5. Generate application keys and run migrations.

### Accessing the Application

- **Web Application**: [http://localhost:8000](http://localhost:8000)
- **Vite Dev Server (HMR)**: [http://localhost:5173](http://localhost:5173)

### Common Commands

- **Start the environment**: `docker compose up -d`
- **Stop the environment**: `docker compose down`
- **View logs**: `docker compose logs -f`
- **Run Artisan commands**: `docker compose exec app php artisan ...`
- **Run Composer commands**: `docker compose exec app composer ...`
- **Run NPM commands**: `docker compose exec app npm ...`

## Features

- **Laravel Octane**: Powered by FrankenPHP for supersonic performance.
- **Inertia.js v2**: Build single-page apps using classic server-side routing.
- **Vue.js 3**: Modern, reactive frontend components.
- **Tailwind CSS v4**: Utility-first CSS framework for rapid styling.
- **SQLite**: Zero-configuration database for easy portability.

## Production Build (Standalone Binary)

This project also supports building a standalone FrankenPHP binary. See `static-build.Dockerfile` for details.
