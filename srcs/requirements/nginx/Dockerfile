FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y nginx openssl gettext-base && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y net-tools iproute2

ARG DOMAIN_NAME
ENV DOMAIN_NAME=${DOMAIN_NAME}

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
      -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${DOMAIN_NAME}" \
      -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/server.key \
      -out /etc/nginx/ssl/server.crt

COPY conf/default.conf /etc/nginx/sites-enabled/default

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
