#!/bin/bash

# Variables
NGINX_CONF="/etc/nginx/sites-available/my_web_app"
NGINX_CONF_LINK="/etc/nginx/sites-enabled/my_web_app"
DOMAIN_OR_IP="46.101.11.165"  # Replace with your domain or IP
ERROR_PAGE="/usr/share/nginx/html/50x.html"

# Function to create or update a file
create_or_update_file() {
    local file_path="$1"
    local file_content="$2"
    if [[ -f "$file_path" ]]; then
        echo "Updating $file_path..."
    else
        echo "Creating $file_path..."
    fi
    sudo bash -c "cat > $file_path" <<< "$file_content"
}

# Custom error page content
ERROR_PAGE_CONTENT='<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Server Error</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
        }
        h1 {
            font-size: 50px;
        }
        p {
            font-size: 20px;
        }
    </style>
</head>
<body>
    <h1>Oops!</h1>
    <p>Something went wrong on our end. Please try again later.</p>
</body>
</html>'

# Nginx configuration content
NGINX_CONF_CONTENT="server {
    listen 80;
    server_name $DOMAIN_OR_IP;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}"

# Create or update the custom error page
create_or_update_file "$ERROR_PAGE" "$ERROR_PAGE_CONTENT"

# Create or update the Nginx configuration file
create_or_update_file "$NGINX_CONF" "$NGINX_CONF_CONTENT"

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

# Check Nginx status
echo "Checking Nginx status..."
sudo systemctl status nginx









# #!/bin/bash

# # Variables
# NGINX_CONF="/etc/nginx/sites-available/my_web_app"
# NGINX_CONF_LINK="/etc/nginx/sites-enabled/my_web_app"
# PROJECT_DIR="$HOME/my-website-project"
# DOMAIN_OR_IP="46.101.11.165"  # Replace with your domain or IP
# ERROR_PAGE="/usr/share/nginx/html/50x.html"

# # Function to create or update a file
# create_or_update_file() {
#     local file_path="$1"
#     local file_content="$2"
#     if [[ -f "$file_path" ]]; then
#         echo "Updating $file_path..."
#     else
#         echo "Creating $file_path..."
#     fi
#     sudo bash -c "cat > $file_path" <<< "$file_content"
# }

# # Custom error page content
# ERROR_PAGE_CONTENT='<!DOCTYPE html>
# <html lang="en">
# <head>
#     <meta charset="UTF-8">
#     <title>Server Error</title>
#     <style>
#         body {
#             font-family: Arial, sans-serif;
#             text-align: center;
#             padding: 50px;
#         }
#         h1 {
#             font-size: 50px;
#         }
#         p {
#             font-size: 20px;
#         }
#     </style>
# </head>
# <body>
#     <h1>Oops!</h1>
#     <p>Something went wrong on our end. Please try again later.</p>
# </body>
# </html>'

# # Nginx configuration content
# NGINX_CONF_CONTENT="server {
#     listen 80;
#     server_name $DOMAIN_OR_IP;

#     location / {
#         proxy_pass http://127.0.0.1:5000;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }

#     error_page 500 502 503 504 /50x.html;
#     location = /50x.html {
#         root /usr/share/nginx/html;
#     }
# }"

# # Create or update the custom error page
# create_or_update_file "$ERROR_PAGE" "$ERROR_PAGE_CONTENT"

# # Create or update the Nginx configuration file
# create_or_update_file "$NGINX_CONF" "$NGINX_CONF_CONTENT"

# # Enable the Nginx site by creating a symlink if it doesn't exist
# if [[ ! -L "$NGINX_CONF_LINK" ]]; then
#     echo "Enabling the Nginx site..."
#     sudo ln -s $NGINX_CONF $NGINX_CONF_LINK
# fi

# # Test Nginx configuration
# echo "Testing Nginx configuration..."
# sudo nginx -t

# # Reload Nginx to apply the new configuration
# echo "Reloading Nginx..."
# sudo systemctl reload nginx

# # Check Nginx status
# echo "Checking Nginx status..."
# sudo systemctl status nginx




















