#!/bin/sh
set -e

mkdir -p /run/nginx

exec /usr/bin/supervisord -n
