#!/bin/bash
set -e

# Ensure runtime directories exist with correct permissions
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Retrieve passwords from secret files or env variables
if [ -n "$MYSQL_ROOT_PASSWORD_FILE" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
    DB_ROOT_PASS=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
elif [ -f "/run/secrets/db_root_password" ]; then
    DB_ROOT_PASS=$(cat "/run/secrets/db_root_password")
else
    DB_ROOT_PASS="$MYSQL_ROOT_PASSWORD"
fi

if [ -n "$MYSQL_PASSWORD_FILE" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
    DB_USER_PASS=$(cat "$MYSQL_PASSWORD_FILE")
elif [ -f "/run/secrets/db_password" ]; then
    DB_USER_PASS=$(cat "/run/secrets/db_password")
else
    DB_USER_PASS="$MYSQL_PASSWORD"
fi

# Initialize system database if not present (handles empty bind mount volumes)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🧱 Initializing MariaDB system tables..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null
fi

# If target database directory does not exist, initialize DB, user and passwords
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "🧱 Initializing application database and users..."

    mysqld_safe --skip-networking &
    pid="$!"

    until mysqladmin ping --silent; do
        sleep 1
    done

    mysql -u root --skip-password -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -u root --skip-password -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';"
    mysql -u root --skip-password -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -u root -p"${DB_ROOT_PASS}" -e "FLUSH PRIVILEGES;"

    mysqladmin shutdown -p"${DB_ROOT_PASS}"
    wait "$pid"

    echo "✅ MariaDB initialized successfully."
fi

echo "🚀 Starting MariaDB in foreground..."
exec mysqld_safe
