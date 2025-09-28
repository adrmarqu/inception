# Usamos Debian estable (penúltima versión)
FROM debian:bookworm-slim

# Evitar preguntas interactivas al instalar paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar NGINX y herramientas necesarias
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Copiar configuración personalizada de NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/ssl /etc/nginx/ssl

# Exponer solo el puerto 443
EXPOSE 443

# Comando por defecto: iniciar NGINX en primer plano
CMD ["nginx", "-g", "daemon off;"]
