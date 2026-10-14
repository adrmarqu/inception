#!/bin/sh
set -e

DOMAIN="${DOMAIN_NAME:-localhost}"

# Generate self-signed SSL certificate if it does not already exist
if [ ! -f /etc/nginx/ssl/server.crt ] || [ ! -f /etc/nginx/ssl/server.key ]; then
    echo "🔒 Generating SSL certificate for ${DOMAIN}..."
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=ES/ST=Barcelona/L=Barcelona/O=42/OU=Inception/CN=${DOMAIN}"
fi

# Inject DOMAIN_NAME into Nginx configuration
envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

echo "🌐 Starting Nginx for domain: ${DOMAIN}..."
exec nginx -g "daemon off;"
