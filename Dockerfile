FROM dunglas/frankenphp:latest-alpine

# Install PHP extensions required by Laravel and Octane
RUN install-php-extensions \
    pcntl \
    intl \
    pdo_sqlite \
    zip \
    bcmath \
    gd \
    redis

# Install Node.js and npm (needed for Octane --watch and Vite)
RUN apk add --no-cache nodejs npm

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy application files (optional if using volumes, but good for initial build)
COPY . .

# Expose ports
EXPOSE 80 5173

# Entrypoint for Octane in dev mode
ENTRYPOINT ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=80", "--admin-port=2019", "--watch"]
