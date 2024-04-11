#!/bin/bash

# Create certbot_conf volume (if it doesn't exist) and copy contents from ./data/certbot/conf
docker volume create certbot_conf
docker run --rm -v ../data/certbot/conf:/src -v certbot_conf:/dest busybox sh -c "rm -rf /dest/* && cp -r /src/. /dest/"

# Create certbot_www volume (if it doesn't exist) and copy contents from ./data/certbot/www
docker volume create certbot_www
docker run --rm -v ../data/certbot/www:/src -v certbot_www:/dest busybox sh -c "rm -rf /dest/* && cp -r /src/. /dest/"

echo "Volumes created and data copied successfully (overwritten if already existed)!"