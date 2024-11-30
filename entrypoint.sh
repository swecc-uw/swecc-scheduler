#!/bin/bash
set -e

echo "ENTRYPOINT RUNNING..."

# copy appropriate env file based on ENV variable
if [ "$ENV" = "prod" ]; then
    cp /app/.env.prod /app/.env
else
    cp /app/.env.local /app/.env
fi
cat /app/.env.secret >> /app/.env

# export all
source /app/.env

# start crond in the background
crond -f -d 8 &

# exec passed command
exec "$@"