#!/bin/sh
set -e

mkdir -p /run/nginx
mkdir -p /run/php
mkdir -p /var/log/supervisor
mkdir -p /var/run/mysqld

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Initialisation DB si pas déjà faite
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[i] Initializing MariaDB..."
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# Démarre MariaDB temporairement pour faire les commandes SQL
echo "[i] Starting MariaDB for init..."
mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
sleep 3

# Création DB + user + droits (idempotent)
echo "[i] Creating WordPress database and user..."
mysql -u root --socket=/var/run/mysqld/mysqld.sock << EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Stop le mysqld temporaire
mysqladmin -u root --socket=/var/run/mysqld/mysqld.sock shutdown

# Lance supervisor (nginx + php-fpm + mariadb)
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
