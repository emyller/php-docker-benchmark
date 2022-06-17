###
# Versions
###
ARG PHP_VERSION=8.1
ARG PHP_EXTENSION_INSTALLER_VERSION=1.5
ARG COMPOSER_VERSION=2.3
ARG LARAVEL_VERSION=9.1.10


###
# External tools
###

# Composer
FROM composer:${COMPOSER_VERSION} AS composer

# PHP Extension Installer
FROM mlocati/php-extension-installer:${PHP_EXTENSION_INSTALLER_VERSION} AS php-extension-installer


###
# PHP + Apache
###
FROM php:${PHP_VERSION}-apache AS php-apache

# External tools
COPY --from=composer /usr/bin/composer /usr/local/bin/
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# PHP extensions
RUN install-php-extensions zip

# Point Apache to /app
RUN sed -ri -e 's!/var/www/html!/app/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/app/!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Initialize and run the application
USER www-data:www-data
WORKDIR /app
RUN composer create-project laravel/laravel . ${LARAVEL_VERSION}


###
# PHP-FPM (official)
###
FROM php:${PHP_VERSION}-fpm AS php-fpm

# External tools
COPY --from=composer /usr/bin/composer /usr/local/bin/
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# PHP extensions
RUN install-php-extensions zip

# Initialize and run the application
USER www-data:www-data
WORKDIR /app
RUN composer create-project laravel/laravel . ${LARAVEL_VERSION}


###
# PHP-FPM + nginx (custom image)
###
FROM ubuntu:jammy AS php-fpm-nginx-custom
ENV DEBIAN_FRONTEND noninteractive

# External tools
COPY --from=composer /usr/bin/composer /usr/local/bin/

# Add extra OS package repositories
RUN apt update && apt install -y software-properties-common && \
  apt-add-repository ppa:nginx/stable -y && \
  apt-add-repository ppa:ondrej/php -y && \
apt clean

# Install nginx
RUN apt install -y nginx && apt clean

# Install PHP
ARG PHP_VERSION
ENV PHP_VERSION ${PHP_VERSION}
RUN apt install -y \
  php${PHP_VERSION} \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-fpm \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-zip \
&& apt clean

# Run PHP-FPM
RUN sed -ri -e 's!^listen =[^$]*!listen = php-fpm:9000!g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY start-server.sh /
CMD ["sh", "/start-server.sh"]

# Initialize and run the application
USER www-data:www-data
WORKDIR /app
RUN composer create-project laravel/laravel . ${LARAVEL_VERSION}

# Run containers as root
USER root


###
# PHP + Octane
###
FROM php:${PHP_VERSION}-cli AS php-octane

# External tools
COPY --from=composer /usr/bin/composer /usr/local/bin/
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# PHP extensions
RUN install-php-extensions pcntl swoole zip

# Initialize and run the application
WORKDIR /app
RUN composer create-project laravel/laravel . ${LARAVEL_VERSION}
RUN composer require laravel/octane
RUN php artisan octane:install --server=swoole
CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8000"]


###
# PHP + Octane
###
FROM php:${PHP_VERSION}-cli-alpine AS php-octane-alpine

# External tools
COPY --from=composer /usr/bin/composer /usr/local/bin/
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# PHP extensions
RUN install-php-extensions pcntl swoole zip

# Initialize and run the application
WORKDIR /app
RUN composer create-project laravel/laravel . ${LARAVEL_VERSION}
RUN composer require laravel/octane
RUN php artisan octane:install --server=swoole
CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8000"]
