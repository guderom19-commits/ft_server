FROM debian:buster

# Fix repos Debian Buster (EOL) -> archive.debian.org
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    php-fpm \
    php-mysql \
    mariadb-server \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Page test PHP
RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php

# Config nginx + supervisor
COPY conf/nginx-site.conf /etc/nginx/sites-available/default
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
