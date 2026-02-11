FROM dunglas/frankenphp:latest

# Install additional PHP extensions required by Laravel
RUN install-php-extensions \
    pdo_sqlite \
    pdo_mysql \
    mbstring \
    intl \
    zip \
    exif \
    pcntl \
    bcmath \
    gd \
    redis \
    opcache

# Set working directory
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-progress --prefer-dist --optimize-autoloader

# Copy application files
COPY . .

# Set permissions for Laravel storage and bootstrap/cache directories
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache \
    && chmod -R 755 /app/storage /app/bootstrap/cache

# Expose port 8000
EXPOSE 8000

# Create a non-root user
ARG USER=appuser
RUN useradd ${USER} \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && chown -R ${USER}:${USER} /app/storage /app/bootstrap/cache /data/caddy /config/caddy

USER ${USER}

# Optimize Laravel for production
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php artisan about --json | grep -q '"status":"ok"' || exit 1

# Default command to run FrankenPHP
CMD ["frankenphp", "php-server", "-r", "public/", "--listen", ":8000"]