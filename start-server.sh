#!/bin/sh
set -e

# Start PHP-FPM (background)
mkdir -p /run/php
php-fpm${PHP_VERSION} --daemonize --allow-to-run-as-root

# Start nginx
nginx -g 'daemon off;'
