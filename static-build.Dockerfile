# Stage 1: Asset Builder
FROM node:20-alpine AS asset-builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: PHP Optimizer
FROM php:8.4-alpine AS php-optimizer
WORKDIR /app

# Install system dependencies for composer and extensions
RUN apk add --no-cache 
    zip 
    unzip 
    libzip-dev 
    libpng-dev 
    libjpeg-turbo-dev 
    freetype-dev 
    sqlite-dev

# Install PHP extensions needed for optimization
RUN docker-php-ext-configure gd --with-freetype --with-jpeg 
    && docker-php-ext-install gd pdo pdo_sqlite zip bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application
COPY . .
COPY --from=asset-builder /app/public/build ./public/build

# Install production dependencies
RUN composer install --no-dev -a --ignore-platform-reqs

# Prepare .env for build (we'll use .env.example as a base)
RUN cp .env.example .env && 
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=\/data\/database.sqlite/" .env && 
    php artisan key:generate

# Optimize Laravel
RUN php artisan optimize && 
    php artisan view:cache

# Remove unneeded files
RUN rm -rf tests node_modules .git .github

# Stage 3: Static Binary Builder
FROM dunglas/frankenphp:static-builder-musl AS static-builder
WORKDIR /go/src/app

# Copy the prepared app
COPY --from=php-optimizer /app ./dist/app

# Build the static binary
# Extensions list matches standard Laravel requirements
ENV PHP_EXTENSIONS="bcmath,ctype,curl,dom,fileinfo,filter,gd,hash,iconv,intl,json,libxml,mbstring,openssl,pcre,pdo,pdo_sqlite,phar,posix,readline,session,simplexml,sqlite3,tokenizer,xml,xmlreader,xmlwriter,zlib"

RUN EMBED=dist/app/ ./build-static.sh
