FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-gd \
    php7.4-xml \
    php7.4-curl \
    php7.4-zip \
    php7.4-mbstring \
    mariadb-client curl less wget tar unzip && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php /var/www/html && \
    chown -R www-data:www-data /run/php /var/www/html && \
    chmod -R 755 /var/www/html

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

