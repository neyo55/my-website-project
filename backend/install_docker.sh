#!/bin/bash

# install_docker.sh

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install necessary packages if not already installed
echo "Checking for required packages..."
if ! dpkg -l | grep -q apt-transport-https; then
    echo "Installing apt-transport-https..."
    sudo apt-get install -y apt-transport-https
else
    echo "apt-transport-https is already installed."
fi

if ! dpkg -l | grep -q ca-certificates; then
    echo "Installing ca-certificates..."
    sudo apt-get install -y ca-certificates
else
    echo "ca-certificates is already installed."
fi

if ! dpkg -l | grep -q curl; then
    echo "Installing curl..."
    sudo apt-get install -y curl
else
    echo "curl is already installed."
fi

if ! dpkg -l | grep -q software-properties-common; then
    echo "Installing software-properties-common..."
    sudo apt-get install -y software-properties-common
else
    echo "software-properties-common is already installed."
fi

# Check if Docker is installed
if ! command_exists docker; then
    echo "Docker is not installed. Proceeding with installation..."

    # Add Docker's official GPG key
    echo "Adding Docker's official GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the Docker stable repository
    echo "Setting up Docker APT repository..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package index again
    echo "Updating package index again..."
    sudo apt-get update

    # Install Docker CE
    echo "Installing Docker..."
    sudo apt-get install -y docker-ce

    # Add the current user to the 'docker' group to manage Docker as a non-root user
    echo "Adding the current user to the 'docker' group..."
    sudo usermod -aG docker "$USER"

    # Restart Docker service
    echo "Restarting Docker service..."
    sudo systemctl restart docker

    # Print Docker version to confirm installation
    echo "Docker installed successfully!"
    docker --version

    # Run Docker hello-world to verify installation
    echo "Running Docker hello-world container to verify installation..."
    docker run hello-world
else
    echo "Docker is already installed."
    docker --version
fi

# Check if Docker Compose is installed
if ! command_exists docker-compose; then
    echo "Docker Compose is not installed. Proceeding with installation..."

    # Install Docker Compose
    echo "Installing Docker Compose..."
    sudo apt-get install -y docker-compose

    # Print Docker Compose version to confirm installation
    echo "Docker Compose installed successfully!"
    docker-compose --version
else
    echo "Docker Compose is already installed."
    docker-compose --version
fi

echo "Docker and Docker Compose installation and setup complete!"
echo "Please log out and log back in for group changes to take effect."

