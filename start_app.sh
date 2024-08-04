#!/bin/bash

# Set the project directory and virtual environment path
PROJECT_DIR=$(dirname "$(realpath "$0")")
VENV_PATH="$PROJECT_DIR/.venv"
LOG_FILE="$PROJECT_DIR/install.log"

# Function to log messages
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to check and install Python if not already installed
install_python() {
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
}

# Function to check and install Nginx, PHP 8.1, PHP-FPM, and PHP-MySQL if not already installed
install_web_stack() {
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
}

# Ensure the log file exists and truncate it for a new run
log "Starting new installation log..."

# Check and install Python if necessary
install_python

# Check and install Nginx, PHP 8.1, PHP-FPM, and PHP-MySQL if necessary
install_web_stack

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
if [ -f "$VENV_PATH/bin/activate" ]; then
    if source "$VENV_PATH/bin/activate"; then
        log "Virtual environment activated."
    else
        log "Failed to activate the virtual environment."
        exit 1
    fi
else
    log "Virtual environment activation script not found."
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
chmod +x "$PROJECT_DIR/adminer_setup.sh" | tee -a "$LOG_FILE"

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

# Run the adminer_setup.sh script
log "Running adminer_setup.sh..."
"$PROJECT_DIR/adminer_setup.sh" | tee -a "$LOG_FILE"
if [[ $? -ne 0 ]]; then
    log "Failed to run adminer_setup.sh."
    exit 1
fi

# Run Gunicorn
log "Starting Gunicorn..."
exec gunicorn -c "$PROJECT_DIR/gunicorn_config.py" app:app









# #!/bin/bash

# # Set the project directory and virtual environment path
# PROJECT_DIR=$(dirname "$(realpath "$0")")
# VENV_PATH="$PROJECT_DIR/.venv"
# LOG_FILE="$PROJECT_DIR/install.log"

# # Function to check and install Python if not already installed
# install_python() {
#     if ! command -v python3 &> /dev/null; then
#         echo "Python3 is not installed. Installing Python3..." | tee -a "$LOG_FILE"
#         sudo apt update | tee -a "$LOG_FILE"
#         sudo apt install -y python3 python3-venv python3-pip | tee -a "$LOG_FILE"
#         if [[ $? -ne 0 ]]; then
#             echo "Failed to install Python3." | tee -a "$LOG_FILE"
#             exit 1
#         fi
#     else
#         echo "Python3 is already installed." | tee -a "$LOG_FILE"
#     fi

#     if ! command -v python &> /dev/null; then
#         echo "Python is not installed. Creating a symlink to Python3..." | tee -a "$LOG_FILE"
#         sudo ln -s /usr/bin/python3 /usr/bin/python | tee -a "$LOG_FILE"
#         if [[ $? -ne 0 ]]; then
#             echo "Failed to create symlink to Python3." | tee -a "$LOG_FILE"
#             exit 1
#         fi
#     else
#         echo "Python is already installed." | tee -a "$LOG_FILE"
#     fi
# }

# # Ensure the log file exists and truncate it for a new run
# echo "Starting new installation log..." > "$LOG_FILE"

# # Check and install Python if necessary
# install_python

# # Check if the virtual environment directory exists
# if [[ ! -d "$VENV_PATH" ]]; then
#     echo "Virtual environment not found. Creating a new one..." | tee -a "$LOG_FILE"
#     python3 -m venv "$VENV_PATH" | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         echo "Failed to create virtual environment." | tee -a "$LOG_FILE"
#         exit 1
#     fi
# fi

# # Activate the virtual environment
# echo "Activating the virtual environment..." | tee -a "$LOG_FILE"
# if [ -f "$VENV_PATH/bin/activate" ]; then
#     if source "$VENV_PATH/bin/activate"; then
#         echo "Virtual environment activated." | tee -a "$LOG_FILE"
#     else
#         echo "Failed to activate the virtual environment." | tee -a "$LOG_FILE"
#         exit 1
#     fi
# else
#     echo "Virtual environment activation script not found." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Install requirements
# echo "Installing requirements from requirements.txt..." | tee -a "$LOG_FILE"
# pip install --upgrade pip | tee -a "$LOG_FILE"
# pip install -r "$PROJECT_DIR/requirements.txt" | tee -a "$LOG_FILE"
# if [[ $? -eq 0 ]]; then
#     echo "Requirements installed successfully." | tee -a "$LOG_FILE"
# else
#     echo "Failed to install requirements." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Ensure the other scripts have execution permissions
# chmod +x "$PROJECT_DIR/create_service.sh" | tee -a "$LOG_FILE"
# chmod +x "$PROJECT_DIR/nginx_setup.sh" | tee -a "$LOG_FILE"
# chmod +x "$PROJECT_DIR/mysql_setup.sh" | tee -a "$LOG_FILE"
# chmod +x "$PROJECT_DIR/adminer_setup.sh" | tee -a "$LOG_FILE"

# # Run the create_service.sh script
# echo "Running create_service.sh..." | tee -a "$LOG_FILE"
# "$PROJECT_DIR/create_service.sh" | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     echo "Failed to run create_service.sh." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Run the nginx_setup.sh script
# echo "Running nginx_setup.sh..." | tee -a "$LOG_FILE"
# "$PROJECT_DIR/nginx_setup.sh" | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     echo "Failed to run nginx_setup.sh." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Run the mysql_setup.sh script
# echo "Running mysql_setup.sh..." | tee -a "$LOG_FILE"
# "$PROJECT_DIR/mysql_setup.sh" | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     echo "Failed to run mysql_setup.sh." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Run the adminer_setup.sh script
# echo "Running adminer_setup.sh..." | tee -a "$LOG_FILE"
# "$PROJECT_DIR/adminer_setup.sh" | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     echo "Failed to run adminer_setup.sh." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Run Gunicorn
# echo "Starting Gunicorn..." | tee -a "$LOG_FILE"
# exec gunicorn -c "$PROJECT_DIR/gunicorn_config.py" app:app














############################ DIRECTORY SPECIFIC ############################################

# #!/bin/bash

# # Set the project directory and virtual environment path
# PROJECT_DIR="$HOME/my-website-project"
# VENV_PATH="$PROJECT_DIR/.venv"
# LOG_FILE="$PROJECT_DIR/install.log"

# # Function to check and install Python if not already installed
# install_python() {
#     if ! command -v python3 &> /dev/null; then
#         echo "Python3 is not installed. Installing Python3..." | tee -a "$LOG_FILE"
#         sudo apt update | tee -a "$LOG_FILE"
#         sudo apt install -y python3 python3-venv python3-pip | tee -a "$LOG_FILE"
#         if [[ $? -ne 0 ]]; then
#             echo "Failed to install Python3." | tee -a "$LOG_FILE"
#             exit 1
#         fi
#     else
#         echo "Python3 is already installed." | tee -a "$LOG_FILE"
#     fi

#     if ! command -v python &> /dev/null; then
#         echo "Python is not installed. Creating a symlink to Python3..." | tee -a "$LOG_FILE"
#         sudo ln -s /usr/bin/python3 /usr/bin/python | tee -a "$LOG_FILE"
#         if [[ $? -ne 0 ]]; then
#             echo "Failed to create symlink to Python3." | tee -a "$LOG_FILE"
#             exit 1
#         fi
#     else
#         echo "Python is already installed." | tee -a "$LOG_FILE"
#     fi
# }

# # Ensure the log file exists and truncate it for a new run
# echo "Starting new installation log..." > "$LOG_FILE"

# # Check and install Python if necessary
# install_python

# # Check if the virtual environment directory exists
# if [[ ! -d "$VENV_PATH" ]]; then
#     echo "Virtual environment not found. Creating a new one..." | tee -a "$LOG_FILE"
#     python3 -m venv "$VENV_PATH" | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         echo "Failed to create virtual environment." | tee -a "$LOG_FILE"
#         exit 1
#     fi
# fi

# # Activate the virtual environment
# echo "Activating the virtual environment..." | tee -a "$LOG_FILE"
# if [ -f "$VENV_PATH/bin/activate" ]; then
#     if source "$VENV_PATH/bin/activate"; then
#         echo "Virtual environment activated." | tee -a "$LOG_FILE"
#     else
#         echo "Failed to activate the virtual environment." | tee -a "$LOG_FILE"
#         exit 1
#     fi
# else
#     echo "Virtual environment activation script not found." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Install requirements
# echo "Installing requirements from requirements.txt..." | tee -a "$LOG_FILE"
# pip install --upgrade pip | tee -a "$LOG_FILE"
# pip install -r "$PROJECT_DIR/requirements.txt" | tee -a "$LOG_FILE"
# if [[ $? -eq 0 ]]; then
#     echo "Requirements installed successfully." | tee -a "$LOG_FILE"
# else
#     echo "Failed to install requirements." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Ensure the other scripts have execution permissions
# chmod +x "$PROJECT_DIR/create_service.sh" | tee -a "$LOG_FILE"
# chmod +x "$PROJECT_DIR/setup_nginx.sh" | tee -a "$LOG_FILE"

# # Run the create_service.sh script
# echo "Running create_service.sh..." | tee -a "$LOG_FILE"
# "$PROJECT_DIR/create_service.sh" | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     echo "Failed to run create_service.sh." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Run the setup_nginx.sh script
# echo "Running setup_nginx.sh..." | tee -a "$LOG_FILE"
# "$PROJECT_DIR/setup_nginx.sh" | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     echo "Failed to run setup_nginx.sh." | tee -a "$LOG_FILE"
#     exit 1
# fi

# # Run Gunicorn
# echo "Starting Gunicorn..." | tee -a "$LOG_FILE"
# exec gunicorn -c "$PROJECT_DIR/gunicorn_config.py" app:app




















