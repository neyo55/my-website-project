#!/bin/bash

# Set variables
PROJECT_DIR=$(dirname "$(realpath "$0")")
LOG_FILE="$PROJECT_DIR/install.log"
ENV_FILE="$PROJECT_DIR/.env"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to log messages
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Ensure the log file exists and truncate it for a new run
echo "Starting new MySQL setup log..." > "$LOG_FILE"

# Load environment variables from .env file
if [ -f "$ENV_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ ! $line =~ ^# && $line == *=* ]]; then
            export "$line"
        fi
    done < "$ENV_FILE"
else
    log ".env file not found."
    exit 1
fi

# Check if MySQL is installed
if command_exists mysql; then
    log "MySQL is already installed."
else
    log "MySQL is not installed. Installing MySQL..."
    
    # Preconfigure MySQL installation prompts
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASS"
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASS"

    # Update package index
    sudo apt update | tee -a "$LOG_FILE"

    # Install MySQL server
    sudo apt install -y mysql-server | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to install MySQL server."
        exit 1
    fi

    # Secure MySQL installation
    log "Securing MySQL installation..."
    sudo mysql -u root -p"$DB_ROOT_PASS" <<-EOF
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
EOF
    if [[ $? -ne 0 ]]; then
        log "Failed to secure MySQL installation."
        exit 1
    fi
fi

# Check if MySQL service is running
sudo systemctl status mysql | grep "active (running)" &> /dev/null
if [[ $? -ne 0 ]]; then
    log "MySQL service is not running. Starting MySQL..."
    sudo systemctl start mysql | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to start MySQL service."
        exit 1
    fi
else
    log "MySQL service is already running."
fi

# Enable MySQL to start on boot
sudo systemctl enable mysql | tee -a "$LOG_FILE"
if [[ $? -ne 0 ]]; then
    log "Failed to enable MySQL service to start on boot."
    exit 1
fi

# Check if the database exists
DB_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" > /dev/null; echo "$?")
if [[ $DB_EXISTS -eq 0 ]]; then
    log "Database $DB_NAME already exists."
else
    log "Creating database $DB_NAME..."
    
    # Create the database and table
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -e "CREATE DATABASE $DB_NAME;" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to create database $DB_NAME."
        exit 1
    fi

    mysql -u"$DB_USER" -p"$DB_PASSWORD" -h"$DB_HOST" -D"$DB_NAME" -e "
    CREATE TABLE users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100),
        phone VARCHAR(20),
        dob DATE,
        gender VARCHAR(10),
        address TEXT
    );" | tee -a "$LOG_FILE"
    if [[ $? -ne 0 ]]; then
        log "Failed to create table in database $DB_NAME."
        exit 1
    fi

    log "Database and table created successfully."
fi

log "MySQL setup completed successfully."













# #!/bin/bash

# # Set variables
# PROJECT_DIR=$(dirname "$(realpath "$0")")
# LOG_FILE="$PROJECT_DIR/install.log"
# ENV_FILE="$PROJECT_DIR/.env"

# # Function to log messages
# log() {
#     echo "$1" | tee -a "$LOG_FILE"
# }

# # Ensure the log file exists and truncate it for a new run
# echo "Starting new MySQL setup log..." > "$LOG_FILE"

# # Check if MySQL is already installed
# if command -v mysql &> /dev/null; then
#     log "MySQL is already installed."
# else
#     log "MySQL is not installed. Installing MySQL..."
#     sudo apt update | tee -a "$LOG_FILE"
#     sudo apt install -y mysql-server | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         log "Failed to install MySQL."
#         exit 1
#     fi
# fi

# # Secure MySQL installation
# log "Securing MySQL installation..."
# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASS}'; FLUSH PRIVILEGES;" | tee -a "$LOG_FILE"

# sudo mysql_secure_installation <<EOF

# y
# $DB_ROOT_PASS
# $DB_ROOT_PASS
# y
# y
# y
# y
# EOF

# # Log into MySQL as root and create the database and user
# log "Creating database and user..."
# sudo mysql -u root -p"$DB_ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;" | tee -a "$LOG_FILE"
# sudo mysql -u root -p"$DB_ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';" | tee -a "$LOG_FILE"
# sudo mysql -u root -p"$DB_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';" | tee -a "$LOG_FILE"
# sudo mysql -u root -p"$DB_ROOT_PASS" -e "FLUSH PRIVILEGES;" | tee -a "$LOG_FILE"

# # Create the table
# log "Creating table..."
# sudo mysql -u root -p"$DB_ROOT_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100), phone VARCHAR(20), dob DATE, gender VARCHAR(10), address TEXT);" | tee -a "$LOG_FILE"

# log "MySQL setup completed successfully."











# #!/bin/bash

# # Set variables
# PROJECT_DIR="$HOME/my-website-project"
# LOG_FILE="$PROJECT_DIR/install.log"
# ENV_FILE="$PROJECT_DIR/.env"

# # Function to check if a command exists
# command_exists() {
#     command -v "$1" &> /dev/null
# }

# # Function to log messages
# log() {
#     echo "$1" | tee -a "$LOG_FILE"
# }

# # Ensure the log file exists and truncate it for a new run
# echo "Starting new MySQL setup log..." > "$LOG_FILE"

# # Load environment variables from .env file
# if [ -f "$ENV_FILE" ]; then
#     export $(cat "$ENV_FILE" | grep -v '#' | awk '/=/ {print $1}')
# else
#     log ".env file not found."
#     exit 1
# fi

# # Check if MySQL is installed
# if command_exists mysql; then
#     log "MySQL is already installed."
# else
#     log "MySQL is not installed. Installing MySQL..."
    
#     # Preconfigure MySQL installation prompts
#     sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASS"
#     sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASS"

#     # Update package index
#     sudo apt update | tee -a "$LOG_FILE"

#     # Install MySQL server
#     sudo apt install -y mysql-server | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         log "Failed to install MySQL server."
#         exit 1
#     fi

#     # Secure MySQL installation
#     log "Securing MySQL installation..."
#     sudo mysql -u root -p"$DB_ROOT_PASS" <<-EOF
#         DELETE FROM mysql.user WHERE User='';
#         DROP DATABASE IF EXISTS test;
#         DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
#         FLUSH PRIVILEGES;
# EOF
#     if [[ $? -ne 0 ]]; then
#         log "Failed to secure MySQL installation."
#         exit 1
#     fi
# fi

# # Check if MySQL service is running
# sudo systemctl status mysql | grep "active (running)" &> /dev/null
# if [[ $? -ne 0 ]]; then
#     log "MySQL service is not running. Starting MySQL..."
#     sudo systemctl start mysql | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         log "Failed to start MySQL service."
#         exit 1
#     fi
# else
#     log "MySQL service is already running."
# fi

# # Enable MySQL to start on boot
# sudo systemctl enable mysql | tee -a "$LOG_FILE"
# if [[ $? -ne 0 ]]; then
#     log "Failed to enable MySQL service to start on boot."
#     exit 1
# fi

# # Check if the database exists
# DB_EXISTS=$(mysql -u$DB_USER -p$DB_PASSWORD -h$DB_HOST -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" > /dev/null; echo "$?")
# if [[ $DB_EXISTS -eq 0 ]]; then
#     log "Database $DB_NAME already exists."
# else
#     log "Creating database $DB_NAME..."
    
#     # Create the database and table
#     mysql -u$DB_USER -p$DB_PASSWORD -h$DB_HOST -e "CREATE DATABASE $DB_NAME;" | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         log "Failed to create database $DB_NAME."
#         exit 1
#     fi

#     mysql -u$DB_USER -p$DB_PASSWORD -h$DB_HOST -D$DB_NAME -e "
#     CREATE TABLE users (
#         id INT AUTO_INCREMENT PRIMARY KEY,
#         name VARCHAR(100),
#         email VARCHAR(100),
#         phone VARCHAR(20),
#         dob DATE,
#         gender VARCHAR(10),
#         address TEXT
#     );" | tee -a "$LOG_FILE"
#     if [[ $? -ne 0 ]]; then
#         log "Failed to create table in database $DB_NAME."
#         exit 1
#     fi

#     log "Database and table created successfully."
# fi

# log "MySQL setup completed successfully."














