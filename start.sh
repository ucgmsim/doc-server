#!/usr/bin/env sh

/update_docs.sh
echo "Starting Cron Daemon"
crond
echo "Starting nginx"
nginx -g "daemon off;"
