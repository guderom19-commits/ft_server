#!/bin/sh
set -e

mkdir -p /run/nginx
mkdir -p /run/php
mkdir -p /var/log/supervisor
mkdir -p /var/run/mysqld

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Init MariaDB
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[i] Initializing MariaDB..."
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# Start MariaDB for init
echo "[i] Starting MariaDB for init..."
mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
sleep 3

# Create DB + user
echo "[i] Creating WordPress database and user..."
mysql -u root --socket=/var/run/mysqld/mysqld.sock << EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Create wp-config.php if missing
if [ ! -f "/var/www/html/wordpress/wp-config.php" ]; then
    echo "[i] Creating wp-config.php..."
    cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
    sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
    sed -i "s/username_here/wp_user/g" /var/www/html/wordpress/wp-config.php
    sed -i "s/password_here/wp_pass/g" /var/www/html/wordpress/wp-config.php
    sed -i "s/localhost/localhost/g" /var/www/html/wordpress/wp-config.php
fi

# Stop init mysqld
mysqladmin -u root --socket=/var/run/mysqld/mysqld.sock shutdown

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
