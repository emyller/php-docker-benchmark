###
# Versions
###
ARG PHP_VERSION=8.1-cli
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
FROM php:8.1-apache AS php-apache

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
