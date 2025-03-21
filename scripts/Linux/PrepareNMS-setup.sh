#!/bin/bash
# !!! You must run this as root !!!

# Run the following commands as root to download this script
# apt update -y
# apt install -y git
# git clone https://github.com/Horribili-kft/Ansible
# cd ./Ansible/scripts/Linux
# chmod +x ./*
# ./PrepareNMS-setup.sh

# Variables for dependencies
REQUIRED_PACKAGES=("sudo" "sshpass" "python3" "python3-venv" "python3-pip")

# Step 1: Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Step 2: Update system
echo "(apt update) Updating the system... "
apt update -y

# Step 3: Install required system packages
for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "$package"; then
        echo "$package is not installed. Installing $package..."
        apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done

echo "System setup complete. Now run PrepareNMS-user.sh"
