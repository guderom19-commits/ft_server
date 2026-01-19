#!/bin/sh
set -e

mkdir -p /run/nginx
mkdir -p /run/php
mkdir -p /var/log/supervisor

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
