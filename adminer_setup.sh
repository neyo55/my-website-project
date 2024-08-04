#!/bin/bash

# Set variables
PROJECT_DIR=$(dirname "$(realpath "$0")")
LOG_FILE="$PROJECT_DIR/install.log"
ADMINER_DIR="/usr/share/adminer"
ADMINER_LINK="/var/www/html/adminer.php"
NGINX_CONF="/etc/nginx/sites-available/adminer"
NGINX_CONF_LINK="/etc/nginx/sites-enabled/adminer"
DOMAIN_OR_IP="46.101.11.165"  # Replace with your domain or IP

# Function to log messages
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Ensure the log file exists and truncate it for a new run
echo "Starting new Adminer setup log..." > "$LOG_FILE"

# Check if Adminer is already installed
if [ -d "$ADMINER_DIR" ]; then
    log "Adminer is already installed."
else
    log "Adminer is not installed. Installing Adminer..."

    # Create Adminer directory and download the latest Adminer
    sudo mkdir -p "$ADMINER_DIR" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to create Adminer directory."
        exit 1
    fi

    sudo wget -q "https://github.com/vrana/adminer/releases/latest/download/adminer-4.8.1.php" -O "$ADMINER_DIR/adminer.php" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to download Adminer."
        exit 1
    fi

    # Create a symlink to make Adminer accessible from the web
    sudo ln -s "$ADMINER_DIR/adminer.php" "$ADMINER_LINK" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to create a symlink for Adminer."
        exit 1
    fi

    log "Adminer installed successfully."
fi

# Create the Nginx configuration file for Adminer
log "Creating Nginx configuration file for Adminer..."

sudo bash -c "cat > $NGINX_CONF" <<EOL
server {
    listen 80;
    server_name $DOMAIN_OR_IP;

    location / {
        root /var/www/html;
        index index.html index.htm index.php;
        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
    }

    location /adminer.php {
        root /var/www/html;
        index adminer.php;
        location ~ \.php\$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOL

if [[ $? -ne 0 ]]; then
    log "Failed to create Nginx configuration file for Adminer."
    exit 1
fi

# Enable the Nginx site by creating a symlink
if [ -f "$NGINX_CONF_LINK" ]; then
    log "Nginx configuration for Adminer is already enabled."
else
    sudo ln -s "$NGINX_CONF" "$NGINX_CONF_LINK" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to enable Nginx configuration for Adminer."
        exit 1
    fi
fi

# Test Nginx configuration
log "Testing Nginx configuration..."
sudo nginx -t 2>&1 | tee -a "$LOG_FILE"

if [[ $? -ne 0 ]]; then
    log "Nginx configuration test failed."
    exit 1
fi

# Reload Nginx to apply the new configuration
log "Reloading Nginx..."
sudo systemctl reload nginx 2>&1 | tee -a "$LOG_FILE"

if [[ $? -ne 0 ]]; then
    log "Failed to reload Nginx."
    exit 1
fi

# Check Nginx status
log "Checking Nginx status..."
sudo systemctl status nginx 2>&1 | tee -a "$LOG_FILE"

if [[ $? -ne 0 ]]; then
    log "Nginx service is not running correctly."
    exit 1
fi

log "Adminer setup completed successfully. Access it at http://$DOMAIN_OR_IP/adminer.php"
