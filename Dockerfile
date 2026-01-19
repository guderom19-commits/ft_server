FROM debian:buster

# Fix repos Debian Buster (EOL) -> archive.debian.org
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    mariadb-server \
    openssl \
    curl \
    wget \
    unzip \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-json \
    php-cli \
    && rm -rf /var/lib/apt/lists/*

# WordPress
RUN mkdir -p /var/www/html/wordpress && \
    curl -L https://wordpress.org/latest.tar.gz | tar -xz --strip-components=1 -C /var/www/html/wordpress

# phpMyAdmin
RUN mkdir -p /var/www/html/phpmyadmin && \
    curl -L https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -o /tmp/pma.zip && \
    unzip /tmp/pma.zip -d /tmp && \
    mv /tmp/phpMyAdmin-*-all-languages/* /var/www/html/phpmyadmin/ && \
    rm -rf /tmp/pma.zip /tmp/phpMyAdmin-*-all-languages

# Page d'accueil (liens relatifs)
RUN printf '%s\n' \
'<h1>ft_server</h1>' \
'<ul>' \
'  <li><a href="/wordpress/">WordPress</a></li>' \
'  <li><a href="/phpmyadmin/">phpMyAdmin</a></li>' \
'</ul>' \
> /var/www/html/index.html

COPY conf/nginx-site.conf /etc/nginx/sites-available/default
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
