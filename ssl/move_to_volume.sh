#!/bin/bash

# Get the absolute path of the current directory
current_dir=$(pwd)

# NFS server IP address
nfs_server="climateprediction.xyz"

# NFS server path for certbot_conf volume
nfs_path_conf="$current_dir/../data/certbot/conf"

# NFS server path for certbot_www volume
nfs_path_www="$current_dir/../data/certbot/www"

# Create certbot_conf volume (if it doesn't exist) with NFS options
docker volume create --driver local --opt type=nfs --opt o=addr=$nfs_server,rw --opt device=:$nfs_path_conf certbot_conf

# Create certbot_www volume (if it doesn't exist) with NFS options
docker volume create --driver local --opt type=nfs --opt o=addr=$nfs_server,rw --opt device=:$nfs_path_www certbot_www

echo "NFS volumes created successfully (overwritten if already existed)!"