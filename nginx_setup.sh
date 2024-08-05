#!/bin/bash

# Load environment variables from .env file
set -o allexport
source .env
set -o allexport

# Define paths
PROJECT_DIR=$(dirname "$(realpath "$0")")
NGINX_CONF_TEMPLATE="$PROJECT_DIR/nginx_conf_template.conf"
NGINX_CONF="/etc/nginx/sites-available/my_web_app"
NGINX_CONF_LINK="/etc/nginx/sites-enabled/my_web_app"

# Substitute environment variables in the template and create the actual config file
envsubst < $NGINX_CONF_TEMPLATE > $NGINX_CONF

# Enable the Nginx site by creating a symlink if it doesn't exist
if [[ ! -L "$NGINX_CONF_LINK" ]]; then
    echo "Enabling the Nginx site..."
    sudo ln -s $NGINX_CONF $NGINX_CONF_LINK
fi

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx to apply the new configuration
echo "Reloading Nginx..."
sudo systemctl reload nginx

# Ensure PHP-FPM is installed and running
echo "Checking PHP-FPM status..."
if ! systemctl is-active --quiet php8.1-fpm; then
    echo "PHP-FPM is not running. Starting PHP-FPM..."
    sudo systemctl start php8.1-fpm
    sudo systemctl enable php8.1-fpm
else
    echo "PHP-FPM is already running."
fi

# Check PHP-FPM status
sudo systemctl status php8.1-fpm
