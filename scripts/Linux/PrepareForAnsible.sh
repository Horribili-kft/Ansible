#!/bin/bash
# !!! You must run this as root !!!

# wget https://raw.githubusercontent.com/Horribili-kft/Ansible/refs/heads/main/scripts/Linux/PrepareForAnsible.sh
# chmod +x ./PrepareForAnsible.sh
# ./PrepareForAnsible.sh

# --- Variables ---
ANSIBLE_USER="ansible" # If you change this, you must update it in the playbook as well.
# IMPORTANT! This password will be removed after Ansible copies over the SSH keys for secure remote management.       
DEFAULT_PASSWORD="Solar-Dynamics-2025"  # The default password for the ansible user. This is removed by the basic setup playbook later for more secure management

# --- Script ---
# Function to check if a package is installed
function is_installed() {
    dpkg -l | grep -i "$1" >/dev/null 2>&1
}


# Step 1: Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi


# Step 2: Install SSH server if not already installed
if ! is_installed "openssh-server"; then
    echo "SSH server not found. Installing SSH server..."
    apt update -y && apt install -y openssh-server
else
    echo "SSH server is already installed."
fi


# Step 3: Ensure Python is installed (Ansible requires Python)
if ! is_installed "python3"; then
    echo "Python3 not found. Installing Python3..."
    apt install -y python3
else
    echo "Python3 is already installed."
fi


# Step 4: Create or modify the Ansible user
if id "$ANSIBLE_USER" &>/dev/null; then
    echo "User exists. Resetting password."
    echo "$ANSIBLE_USER:$DEFAULT_PASSWORD" | /sbin/chpasswd
else
    echo "Creating user..."
    /sbin/adduser --gecos "" "$ANSIBLE_USER"
    echo "$ANSIBLE_USER:$DEFAULT_PASSWORD" | /sbin/chpasswd
fi

# Passwordless sudo
echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$ANSIBLE_USER
chmod 440 /etc/sudoers.d/$ANSIBLE_USER


# Step 8: Restart the SSH service
echo "Restarting SSH service..."
systemctl restart ssh


# Step 9: Test SSH connection (optional)
echo "Testing SSH connection as '$ANSIBLE_USER'..."
su - $ANSIBLE_USER -c "sudo ssh -o StrictHostKeyChecking=no -T localhost echo 'SSH connection test successful.'"


# Completion message
echo "Host is now prepared for Ansible management!"
echo "You should run the debian-basic-setup.yaml script on the control node!"


# End of script
