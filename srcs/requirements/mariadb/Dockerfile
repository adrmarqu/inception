FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instalar MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copiar configuración personalizada si tienes
# COPY conf/my.cnf /etc/mysql/my.cnf

# Exponer puerto 3306 solo en red de Docker
EXPOSE 3306

# Iniciar MariaDB en primer plano
CMD ["mysqld_safe"]

