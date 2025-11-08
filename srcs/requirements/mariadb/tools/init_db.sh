#!/bin/bash
set -e

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "🧱 Initializing MariaDB database..."

    mysqld_safe --skip-networking &
    until mysqladmin ping --silent; do
    	sleep 1
    done

    DB_ROOT_PASS=$(cat "${MYSQL_ROOT_PASSWORD_FILE}")
    DB_USER_PASS=$(cat "${MYSQL_PASSWORD_FILE}")

    mysql -u root --skip-password -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

    mysql -u root --skip-password -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';"
    mysql -u root --skip-password -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"

    mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"

    mysql -u root -p"${DB_ROOT_PASS}" -e "FLUSH PRIVILEGES;"

    mysqladmin shutdown -p"${DB_ROOT_PASS}"

    echo "✅ Database initialized successfully."
fi

exec mysqld_safe
