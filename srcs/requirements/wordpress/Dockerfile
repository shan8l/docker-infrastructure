FROM debian:bookworm

#install PHP-FPM and dependencies
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-soap \
    php8.2-xml \
    php8.2-zip \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

#download WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

#create run directory for php-fpm
RUN mkdir -p /run/php

# the working derectory inside the container
WORKDIR /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/

COPY tools/set_wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/set_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/set_wordpress.sh"]
