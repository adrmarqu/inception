#!/bin/sh
set -e

echo "🚀 Starting WordPress container..."

# Retrieve Database password
if [ -n "$WORDPRESS_DB_PASSWORD_FILE" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    DB_PASS=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
elif [ -n "$MYSQL_PASSWORD_FILE" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
    DB_PASS=$(cat "$MYSQL_PASSWORD_FILE")
elif [ -f "/run/secrets/db_password" ]; then
    DB_PASS=$(cat "/run/secrets/db_password")
else
    DB_PASS="${WORDPRESS_DB_PASSWORD:-$MYSQL_PASSWORD}"
fi

# Retrieve WordPress Admin password
if [ -n "$WORDPRESS_ADMIN_PASS_FILE" ] && [ -f "$WORDPRESS_ADMIN_PASS_FILE" ]; then
    WP_ADMIN_PASS=$(cat "$WORDPRESS_ADMIN_PASS_FILE")
elif [ -f "/run/secrets/wp_admin_password" ]; then
    WP_ADMIN_PASS=$(cat "/run/secrets/wp_admin_password")
else
    WP_ADMIN_PASS="${WORDPRESS_ADMIN_PASSWORD:-$DB_PASS}"
fi

# Retrieve WordPress Regular User password
if [ -n "$WORDPRESS_USER_PASS_FILE" ] && [ -f "$WORDPRESS_USER_PASS_FILE" ]; then
    WP_USER_PASS=$(cat "$WORDPRESS_USER_PASS_FILE")
elif [ -f "/run/secrets/wp_user_password" ]; then
    WP_USER_PASS=$(cat "/run/secrets/wp_user_password")
else
    WP_USER_PASS="${WORDPRESS_USER_PASSWORD:-$DB_PASS}"
fi

# Ensure PHP socket directory exists
mkdir -p /run/php
chown -R www-data:www-data /run/php

# Wait for MariaDB to become ready
DB_HOST=$(echo "${WORDPRESS_DB_HOST:-mariadb:3306}" | cut -d: -f1)
DB_PORT=$(echo "${WORDPRESS_DB_HOST:-mariadb:3306}" | cut -d: -f2)

echo "⏳ Waiting for MariaDB at ${DB_HOST}:${DB_PORT}..."
until mariadb-admin ping -h "$DB_HOST" -P "$DB_PORT" -u"${WORDPRESS_DB_USER:-$MYSQL_USER}" -p"$DB_PASS" --silent 2>/dev/null; do
    sleep 2
done
echo "✅ MariaDB connection established."

# Install and configure WordPress if not already present
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "🔧 Downloading WordPress core..."
    wp core download --path=/var/www/html --allow-root

    echo "⚙️ Generating wp-config.php..."
    wp config create \
        --path=/var/www/html \
        --dbname="${WORDPRESS_DB_NAME:-$MYSQL_DATABASE}" \
        --dbuser="${WORDPRESS_DB_USER:-$MYSQL_USER}" \
        --dbpass="$DB_PASS" \
        --dbhost="${WORDPRESS_DB_HOST:-mariadb:3306}" \
        --skip-check \
        --allow-root

    echo "🛠 Installing WordPress site..."
    ADMIN_USER="${WORDPRESS_ADMIN_USER:-${WORDPRESS_ADMIN:-superuser42}}"
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE:-Inception Site}" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "👤 Creating regular user..."
    if [ -n "$WORDPRESS_USER" ] && [ -n "$WORDPRESS_USER_EMAIL" ]; then
        wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
            --path=/var/www/html \
            --role=author \
            --user_pass="$WP_USER_PASS" \
            --allow-root || true
    fi

    echo "🎨 Installing and activating default theme..."
    wp theme install twentytwentytwo --activate --path=/var/www/html --allow-root || true

    echo "🔒 Setting proper ownership and permissions..."
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
fi

echo "✅ Starting PHP-FPM..."
PHP_FPM_BIN=$(which php-fpm8.2 || which php-fpm || which php-fpm7.4)
exec "$PHP_FPM_BIN" -F
