#!/bin/bash

# Get the absolute path of the current directory
current_dir=$(pwd)

# Create certbot_conf volume (if it doesn't exist) and copy contents from ./data/certbot/conf
docker volume create certbot_conf
docker run --rm -v "$current_dir/../data/certbot/conf":/src -v certbot_conf:/dest busybox sh -c "rm -rf /dest/* && cp -r /src/. /dest/"

# Create certbot_www volume (if it doesn't exist) and copy contents from ./data/certbot/www
docker volume create certbot_www
docker run --rm -v "$current_dir/../data/certbot/www":/src -v certbot_www:/dest busybox sh -c "rm -rf /dest/* && cp -r /src/. /dest/"

echo "Volumes created and data copied successfully (overwritten if already existed)!"