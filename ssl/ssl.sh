#!/bin/bash

# Check if domains and email are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: ./ssl.sh your_email your_domain1 [your_domain2 ...]"
    exit 1
fi

EMAIL=$1
shift
DOMAINS=("$@")

# Step 1: Generate the ssl.conf file with the provided domains
SSL_CONF_FILE="nginx.conf"

echo "Generating nginx.conf with the provided domains..."
cat > "$SSL_CONF_FILE" <<EOF
server {
    listen 80;
    server_name $(echo "${DOMAINS[@]}" | xargs);

    location /check {
        default_type text/plain;
        return 200 'OK';
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
EOF

echo "ssl.conf has been generated with the provided domains."

# Step 2: Start the dummy nginx and certbot containers
# Docker version 25.0.3
docker compose up --build -d

# Step 3: Check if the server is responding by making HTTP requests to the specified URL
for DOMAIN in "${DOMAINS[@]}"; do
    url="http://$DOMAIN/check"
    max_attempts=50
    count=0

    while [ $count -lt $max_attempts ]
    do
        response=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "$url")
        if [ "$response" -eq 200 ]; then
            echo "Received 200 OK response for $DOMAIN."
            break
        else
            echo "Did not receive 200 OK response for $DOMAIN. Received $response instead. Retrying...($(($count + 1)))"
            count=$((count+1))
            sleep 2
        fi
    done

    if [ $count -eq $max_attempts ]; then
        echo "Server is not responding for $DOMAIN after $max_attempts attempts."
        exit 1
    else
        echo "Successfully connected to the server for $DOMAIN after $count attempts."
    fi
done

sleep 2

# Step 4: Download recommended TLS parameters and save them to the certbot configuration directory
sudo mkdir -p /var/data/certbot/conf
sudo curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > /var/data/certbot/conf/options-ssl-nginx.conf
sudo curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > /var/data/certbot/conf/ssl-dhparams.pem

read -p "Do you want to issue the SSL certificate? [y/n]: " choice

case "$choice" in
  y|Y) 
    echo "Yes, continuing..."
    ;;
  *)
    echo "No, exiting..."
    docker compose down
    exit 0
    ;;
esac

# Step 5: Request the SSL certificate
domains_args=()
for DOMAIN in "${DOMAINS[@]}"; do
    domains_args+=("-d" "$DOMAIN")
done

docker compose run dummy-certbot certonly --webroot -w /var/www/certbot "${domains_args[@]}" --email $EMAIL --agree-tos --no-eff-email --force-renewal

# Step 6: Stop and remove the dummy nginx and certbot containers
docker compose down

echo "SSL certificate has been issued and the containers have been stopped and removed."