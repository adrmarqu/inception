# Usamos Debian estable (penúltima versión)
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instalar PHP y extensiones necesarias
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql php-xml php-gd php-curl unzip curl && \
    rm -rf /var/lib/apt/lists/*

# Crear carpeta de WordPress
WORKDIR /var/www/html

# Copiar archivos de WordPress si los tienes localmente
# COPY ./wordpress/ /var/www/html/

# Cambiar permisos para php-fpm
RUN chown -R www-data:www-data /var/www/html

# Configurar PHP-FPM para correr en foreground
CMD ["php-fpm7.4", "-F"]
