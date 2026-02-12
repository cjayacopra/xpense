# Stage 1: Build frontend assets
FROM node:20-alpine AS asset-builder
WORKDIR /app

# Install PHP and extensions required for Laravel/Wayfinder during asset build
RUN apk add --no-cache \
    php83 \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-mbstring \
    php83-openssl \
    php83-pdo \
    php83-pdo_sqlite \
    php83-session \
    php83-tokenizer \
    php83-xml \
    php83-xmlwriter \
    php83-phar \
    php83-iconv

# Ensure 'php' points to 'php83'
RUN ln -sf /usr/bin/php83 /usr/bin/php

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Install PHP dependencies
FROM composer:latest AS vendor-builder
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-progress --prefer-dist --optimize-autoloader
COPY . .
# Remove node_modules to keep the binary small
RUN rm -rf node_modules

# Stage 3: Build the standalone binary
FROM dunglas/frankenphp:static-builder AS binary-builder

# Copy the entire app from the vendor-builder stage
COPY --from=vendor-builder /app /go/src/app/
# Copy the built assets from the asset-builder stage
COPY --from=asset-builder /app/public/build /go/src/app/public/build

WORKDIR /go/src/app

# Build the static binary
RUN EMBED=/go/src/app/ \
    PHP_EXTENSIONS=pdo_sqlite,mbstring,intl,zip,exif,pcntl,bcmath,gd,redis,opcache \
    ./build-static.sh

# Stage 4: Final minimal image
FROM scratch

# Copy the produced binary from the builder
COPY --from=binary-builder /go/src/app/dist/frankenphp-linux-x86_64 /xpense

# Set the working directory to where the binary expects the app to be (embedded)
WORKDIR /app

# Copy the sqlite database from host if it exists, or let the app create it
COPY database/database.sqlite /app/database/database.sqlite

# Expose the default port
EXPOSE 8080

# Run the standalone binary
ENTRYPOINT ["/xpense", "php-server", "--listen", ":8080"]
