#!/bin/bash

# start_app.sh 

# Set environment to noninteractive to avoid dialog prompts
export DEBIAN_FRONTEND=noninteractive

# Set the project directory to the parent directory of this script
PROJECT_DIR=$(dirname "$(realpath "$0")")
BACKEND_DIR="$PROJECT_DIR"
DATABASE_DIR="$PROJECT_DIR/../database"
LOG_DIR="$BACKEND_DIR/logs"
LOG_FILE="$LOG_DIR/install.log"

# Ensure the log directory exists
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    sudo chown ubuntu:ubuntu "$LOG_DIR"
fi

# Ensure log file permissions are correct
sudo touch "$LOG_FILE"
sudo chown ubuntu:ubuntu "$LOG_FILE"

# Function to log messages
log() {
    echo "$1" | sudo tee -a "$LOG_FILE"
}

# Function to exit the script with an error
exit_script() {
    log "Error occurred. Exiting script."
    exit 1
}

# Function to check and install Python if not already installed
install_python() {
    log "Checking for Python3 installation..."
    if ! command -v python3 &> /dev/null; then
        log "Python3 is not installed. Installing Python3..."
        sudo apt-get update -y -q | tee -a "$LOG_FILE"
        sudo apt-get install -y -q python3 python3-pip || exit_script
    else
        log "Python3 is already installed."
    fi

    log "Checking for pip3 installation..."
    if ! command -v pip3 &> /dev/null; then
        log "pip3 is not installed. Installing pip3..."
        sudo apt-get update -y -q || exit_script
        sudo apt-get install -y -q python3-pip || exit_script
    else
        log "pip3 is already installed."
    fi

    log "Upgrading pip..."
    sudo python3 -m pip install --upgrade pip || exit_script
}

# Function to install Python packages from requirements.txt
install_python_packages() {
    log "Installing Python packages from requirements.txt..."
    if [ -f "$BACKEND_DIR/requirements.txt" ]; then
        sudo python3 -m pip install -r "$BACKEND_DIR/requirements.txt" --ignore-installed || exit_script
    else
        log "requirements.txt file not found in $BACKEND_DIR."
        exit_script
    fi
}

# Function to verify Python package installations
verify_python_packages() {
    log "Verifying Python package installations..."
    python3 -c "import flask; import mysql.connector; import dotenv; import gunicorn" || exit_script
    log "Python packages installed and verified successfully."
}

# Function to check and install Nginx, PHP 8.1, PHP-FPM, and PHP-MySQL if not already installed
install_web_stack() {
    log "Checking for Nginx installation..."
    if ! command -v nginx &> /dev/null; then
        log "Nginx is not installed. Installing Nginx..."
        sudo apt-get install -y -q nginx || exit_script
    else
        log "Nginx is already installed."
    fi

    log "Checking for PHP and PHP-FPM installation..."
    if ! command -v php &> /dev/null; then
        log "PHP is not installed. Installing PHP 8.1 and PHP-FPM..."
        sudo add-apt-repository -y ppa:ondrej/php || exit_script
        sudo apt-get update -y -q || exit_script
        sudo apt-get install -y -q php8.1 php8.1-fpm php8.1-mysql || exit_script
    else
        PHP_VERSION=$(php -v | grep -oP '^PHP \K([0-9]+\.[0-9]+)')
        if [[ "$PHP_VERSION" != "8.1" ]]; then
            log "PHP version is not 8.1. Installing PHP 8.1 and PHP-FPM..."
            sudo add-apt-repository -y ppa:ondrej/php || exit_script
            sudo apt-get update -y -q || exit_script
            sudo apt-get install -y -q php8.1 php8.1-fpm php8.1-mysql || exit_script
        else
            log "PHP 8.1 is already installed."
        fi
    fi

    # Ensure cgi.fix_pathinfo is set to 0
    log "Ensuring cgi.fix_pathinfo is set correctly..."
    sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.1/fpm/php.ini || exit_script
    sudo systemctl restart php8.1-fpm || exit_script
}

# Function to check and install Gunicorn if not already installed
install_gunicorn() {
    log "Checking for Gunicorn installation..."
    if ! command -v gunicorn &> /dev/null; then
        log "Gunicorn is not installed. Installing Gunicorn..."
        sudo python3 -m pip install gunicorn || exit_script
    else
        log "Gunicorn is already installed."
    fi
}

# Function to install Adminer
install_adminer() {
    log "Installing Adminer..."
    sudo wget -q https://www.adminer.org/latest.php -O /var/www/html/adminer.php || exit_script
    sudo chown www-data:www-data /var/www/html/adminer.php || exit_script
    sudo chmod 755 /var/www/html/adminer.php || exit_script
    log "Adminer installed successfully."
}

# Function to set up the Gunicorn service
setup_gunicorn_service() {
    log "Setting up Gunicorn service..."
    GUNICORN_PATH=$(which gunicorn)
    if [[ -z "$GUNICORN_PATH" ]]; then
        log "Gunicorn path not found, cannot proceed."
        exit_script
    fi

    SERVICE_FILE="/etc/systemd/system/my_web_app.service"
    sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Gunicorn instance to serve my web app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=$BACKEND_DIR
ExecStart=$GUNICORN_PATH -c $BACKEND_DIR/gunicorn_config.py app:app

[Install]
WantedBy=multi-user.target
EOL

    # Ensure correct permissions for the backend directory
    sudo chown -R ubuntu:www-data $BACKEND_DIR || exit_script
    sudo chmod -R 755 $BACKEND_DIR || exit_script

    sudo systemctl daemon-reload || exit_script
    sudo systemctl enable my_web_app || exit_script
    sudo systemctl restart my_web_app || exit_script
    log "Gunicorn service setup completed."
}

# Ensure the log file exists and truncate it for a new run
log "Starting new installation log..."

# Check and install Python if necessary
install_python

# Install Python packages from requirements.txt
install_python_packages

# Verify the Python package installations
verify_python_packages

# Install Nginx, PHP-FPM, and PHP-MySQL
install_web_stack

# Check and install Gunicorn if necessary
install_gunicorn

# Install Adminer
install_adminer

# Set up the Gunicorn service
setup_gunicorn_service

# Ensure the other scripts have execution permissions
log "Setting execution permissions for additional scripts..."
sudo chmod +x "$BACKEND_DIR/create_service.sh" || exit_script
sudo chmod +x "$BACKEND_DIR/nginx_setup.sh" || exit_script
sudo chmod +x "$DATABASE_DIR/mysql_setup.sh" || exit_script
sudo chmod +x "$BACKEND_DIR/install_docker.sh" || exit_script

# Run the create_service.sh script
log "Running create_service.sh..."
sudo "$BACKEND_DIR/create_service.sh" || exit_script

# Run the nginx_setup.sh script
log "Running nginx_setup.sh..."
sudo "$BACKEND_DIR/nginx_setup.sh" || exit_script

# Run the mysql_setup.sh script
log "Running mysql_setup.sh..."
sudo "$DATABASE_DIR/mysql_setup.sh" || exit_script

# Run the install_docker.sh script
log "Running install_docker.sh..."
sudo "$BACKEND_DIR/install_docker.sh" || exit_script

# Add the current user to the Docker group
log "Adding current user to the Docker group..."
sudo usermod -aG docker $USER || exit_script

# Suggest user to log out and back in or run `newgrp docker`
log "To apply Docker group changes, log out and back in or run 'newgrp docker'"

# Restart Docker service to apply changes
log "Restarting Docker service..."
sudo systemctl restart docker || exit_script

# Stop existing Gunicorn service (if running)
log "Stopping Gunicorn service..."
sudo systemctl stop my_web_app || exit_script

# Kill any remaining Gunicorn processes
log "Killing remaining Gunicorn processes..."
sudo pkill -f gunicorn || exit_script

# Check for any processes listening on port 5000 and kill them
log "Checking and killing processes on port 5000..."
PORT_PIDS=$(sudo lsof -t -i:5000)
if [ -n "$PORT_PIDS" ]; then
    sudo kill -9 $PORT_PIDS || exit_script
else
    log "No processes found on port 5000."
fi

# Start Gunicorn
log "Starting Gunicorn..."
exec gunicorn -c "$BACKEND_DIR/gunicorn_config.py" app:app || exit_script
