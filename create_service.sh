#!/bin/bash

# Variables
SERVICE_NAME="my_web_app"
PROJECT_DIR=$(dirname "$(realpath "$0")")
VENV_PATH="$PROJECT_DIR/.venv"
USER_NAME=$(whoami)
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

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

# Systemd service content
SERVICE_FILE_CONTENT="[Unit]
Description=Gunicorn instance to serve my web app
After=network.target

[Service]
User=$USER_NAME
Group=www-data
WorkingDirectory=$PROJECT_DIR
Environment=\"PATH=$VENV_PATH/bin\"
ExecStart=$VENV_PATH/bin/gunicorn -c $PROJECT_DIR/gunicorn_config.py app:app

[Install]
WantedBy=multi-user.target"

# Create or update the system service file
create_or_update_file "$SERVICE_FILE" "$SERVICE_FILE_CONTENT"

# Enable and start the service if not already enabled
if ! sudo systemctl is-enabled --quiet $SERVICE_NAME; then
    echo "Enabling the $SERVICE_NAME service..."
    sudo systemctl enable $SERVICE_NAME
fi

echo "Starting the $SERVICE_NAME service..."
sudo systemctl restart $SERVICE_NAME

# Check the status of the service
echo "Checking the status of the $SERVICE_NAME service..."
sudo systemctl status $SERVICE_NAME

















# #!/bin/bash

# # Variables
# SERVICE_NAME="my_web_app"
# PROJECT_DIR="$HOME/my-website-project"
# VENV_PATH="$PROJECT_DIR/.venv"
# USER_NAME=$(whoami)
# SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# # Create the system service file
# echo "Creating system service file for $SERVICE_NAME..."

# sudo bash -c "cat > $SERVICE_FILE" <<EOL
# [Unit]
# Description=Gunicorn instance to serve my web app
# After=network.target

# [Service]
# User=$USER_NAME
# Group=www-data
# WorkingDirectory=$PROJECT_DIR
# Environment=\"PATH=$VENV_PATH/bin\"
# ExecStart=$VENV_PATH/bin/gunicorn -c $PROJECT_DIR/gunicorn_config.py app:app

# [Install]
# WantedBy=multi-user.target
# EOL

# # Enable and start the service
# echo "Enabling and starting the $SERVICE_NAME service..."
# sudo systemctl enable $SERVICE_NAME
# sudo systemctl start $SERVICE_NAME

# # Check the status of the service
# echo "Checking the status of the $SERVICE_NAME service..."
# sudo systemctl status $SERVICE_NAME
