FROM php:8.3-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
    libzip-dev unzip git \
    && docker-php-ext-install pdo_mysql zip opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html

RUN composer install --no-interaction --prefer-dist --optimize-autoloader || true

RUN chown -R www-data:www-data /var/www/html
