#!/bin/bash

# create_service.sh

# Variables
SERVICE_NAME="my_web_app"
BACKEND_DIR="$HOME/my-web-project/backend"  # Corrected path to the backend directory
USER_NAME=$(whoami)
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
GUNICORN_PATH=$(command -v gunicorn)  # Get the path to Gunicorn

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

# Ensure Gunicorn is installed
if [ -z "$GUNICORN_PATH" ]; then
    echo "Error: Gunicorn is not installed. Please install Gunicorn before running this script."
    exit 1
fi

# Check if the backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "Error: Backend directory $BACKEND_DIR does not exist. Exiting script."
    exit 1
fi

# Systemd service content
SERVICE_FILE_CONTENT="[Unit]
Description=Gunicorn instance to serve my web app
After=network.target

[Service]
User=$USER_NAME
Group=www-data
WorkingDirectory=$BACKEND_DIR
ExecStart=$GUNICORN_PATH -c $BACKEND_DIR/gunicorn_config.py app:app
Restart=always

[Install]
WantedBy=multi-user.target"

# Create or update the system service file
create_or_update_file "$SERVICE_FILE" "$SERVICE_FILE_CONTENT"

# Reload systemd to recognize the new service file
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start the service
if ! sudo systemctl is-enabled --quiet $SERVICE_NAME; then
    echo "Enabling the $SERVICE_NAME service..."
    sudo systemctl enable $SERVICE_NAME
fi

echo "Starting the $SERVICE_NAME service..."
sudo systemctl restart $SERVICE_NAME

# Check the status of the service
echo "Checking the status of the $SERVICE_NAME service..."
sudo systemctl status $SERVICE_NAME --no-pager
