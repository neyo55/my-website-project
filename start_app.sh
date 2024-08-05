#!/bin/bash

# start_app.sh 

# Set the project directory and virtual environment path
PROJECT_DIR=$(dirname "$(realpath "$0")")
VENV_PATH="$PROJECT_DIR/.venv"
LOG_FILE="$PROJECT_DIR/install.log"

# Function to log messages
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to check and install dependencies if not already installed
install_dependencies() {
    # Check and install Python if necessary
    if ! command -v python3 &> /dev/null; then
        log "Python3 is not installed. Installing Python3..."
        sudo apt update | tee -a "$LOG_FILE"
        sudo apt install -y python3 python3-venv python3-pip | tee -a "$LOG_FILE"
        if [[ $? -ne 0 ]]; then
            log "Failed to install Python3."
            exit 1
        fi
    else
        log "Python3 is already installed."
    fi

    if ! command -v python &> /dev/null; then
        log "Python is not installed. Creating a symlink to Python3..."
        sudo ln -s /usr/bin/python3 /usr/bin/python | tee -a "$LOG_FILE"
        if [[ $? -ne 0 ]]; then
            log "Failed to create symlink to Python3."
            exit 1
        fi
    else
        log "Python is already installed."
    fi

    # Check and install Nginx, PHP 8.1, PHP-FPM, and PHP-MySQL if not already installed
    if ! command -v nginx &> /dev/null; then
        log "Nginx is not installed. Installing Nginx..."
        sudo apt install -y nginx | tee -a "$LOG_FILE"
        if [[ $? -ne 0 ]]; then
            log "Failed to install Nginx."
            exit 1
        fi
    else
        log "Nginx is already installed."
    fi

    if ! command -v php &> /dev/null; then
        log "PHP is not installed. Installing PHP 8.1 and PHP-FPM..."
        sudo add-apt-repository -y ppa:ondrej/php
        sudo apt update | tee -a "$LOG_FILE"
        sudo apt install -y php8.1 php8.1-fpm php8.1-mysql | tee -a "$LOG_FILE"
        if [[ $? -ne 0 ]]; then
            log "Failed to install PHP 8.1 and PHP-FPM."
            exit 1
        fi
    else
        PHP_VERSION=$(php -v | grep -oP '^PHP \K([0-9]+\.[0-9]+)')
        if [[ "$PHP_VERSION" != "8.1" ]]; then
            log "PHP version is not 8.1. Installing PHP 8.1 and PHP-FPM..."
            sudo add-apt-repository -y ppa:ondrej/php
            sudo apt update | tee -a "$LOG_FILE"
            sudo apt install -y php8.1 php8.1-fpm php8.1-mysql | tee -a "$LOG_FILE"
            if [[ $? -ne 0 ]]; then
                log "Failed to install PHP 8.1 and PHP-FPM."
                exit 1
            fi
        else
            log "PHP 8.1 is already installed."
        fi
    fi

    # Check and install gettext if necessary
    if ! command -v envsubst &> /dev/null; then
        log "envsubst is not installed. Installing gettext..."
        sudo apt install -y gettext | tee -a "$LOG_FILE"
        if [[ $? -ne 0 ]]; then
            log "Failed to install gettext."
            exit 1
        fi
    else
        log "envsubst is already installed."
    fi
}

# Ensure the log file exists and truncate it for a new run
log "Starting new installation log..."

# Install dependencies
install_dependencies

# Check if the virtual environment directory exists
if [[ ! -d "$VENV_PATH" ]]; then
    log "Virtual environment not found. Creating a new one..."
    python3 -m venv "$VENV_PATH" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to create virtual environment."
        exit 1
    fi
fi

# Activate the virtual environment
log "Activating the virtual environment..."
source "$VENV_PATH/bin/activate"
if [[ $? -ne 0 ]]; then
    log "Failed to activate the virtual environment."
    exit 1
fi

# Install requirements
log "Installing requirements from requirements.txt..."
pip install --upgrade pip | tee -a "$LOG_FILE"
pip install -r "$PROJECT_DIR/requirements.txt" | tee -a "$LOG_FILE"
if [[ $? -eq 0 ]]; then
    log "Requirements installed successfully."
else
    log "Failed to install requirements."
    exit 1
fi

# Ensure the other scripts have execution permissions
chmod +x "$PROJECT_DIR/create_service.sh" | tee -a "$LOG_FILE"
chmod +x "$PROJECT_DIR/nginx_setup.sh" | tee -a "$LOG_FILE"
chmod +x "$PROJECT_DIR/mysql_setup.sh" | tee -a "$LOG_FILE"

# Run the create_service.sh script
log "Running create_service.sh..."
"$PROJECT_DIR/create_service.sh" | tee -a "$LOG_FILE"
if [[ $? -ne 0 ]]; then
    log "Failed to run create_service.sh."
    exit 1
fi

# Run the nginx_setup.sh script
log "Running nginx_setup.sh..."
"$PROJECT_DIR/nginx_setup.sh" | tee -a "$LOG_FILE"
if [[ $? -ne 0 ]]; then
    log "Failed to run nginx_setup.sh."
    exit 1
fi

# Run the mysql_setup.sh script
log "Running mysql_setup.sh..."
"$PROJECT_DIR/mysql_setup.sh" | tee -a "$LOG_FILE"
if [[ $? -ne 0 ]]; then
    log "Failed to run mysql_setup.sh."
    exit 1
fi

# Create the directory if it doesn't already exist
sudo mkdir -p /var/www/html

# Change the ownership of the directory and its contents to the 'www-data' user and group
sudo chown -R www-data:www-data /var/www/html

# Set the permissions of the directory and its contents to 755
sudo chmod -R 755 /var/www/html

# Create an empty 'index.html' file in the directory
sudo touch /var/www/html/index.html

# Write "Welcome to your web server!" into the 'index.html' file
echo "Welcome to your web server!" | sudo tee /var/www/html/index.html

# Stop existing Gunicorn service
log "Stopping Gunicorn service..."
sudo systemctl stop my_web_app

# Kill any remaining Gunicorn processes
log "Killing remaining Gunicorn processes..."
sudo pkill -f gunicorn

# Check for any processes listening on port 5000 and kill them
log "Checking and killing processes on port 5000..."
sudo kill -9 $(sudo lsof -t -i:5000) 2>/dev/null

# Start Gunicorn
log "Starting Gunicorn..."
exec gunicorn -c "$PROJECT_DIR/gunicorn_config.py" app:app
