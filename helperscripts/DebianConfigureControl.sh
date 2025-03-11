#!/bin/bash

# Run the following commands as root to install this script
# apt update -y
# apt install -y git 
# git clone https://github.com/Horribili-kft/Ansible
# cd ./Ansible/helperscripts/
# chmod +x ./DebianConfigureControl.sh
# ./DebianConfigureControl.sh

# Variables
BASIC_SETUP_PLAYBOOK="../playbooks/debian-basic-setup.yaml"
NMS_SETUP_PLAYBOOK="../playbooks/nms-setup.yaml"
INVENTORY="../inventory/hosts.yaml"

# Function to check if a package is installed
function is_installed() {
    dpkg -l | grep -i "$1" >/dev/null 2>&1
}

# Step 1: Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Step 2: Update system and install dependencies
echo "(apt update) Updating the system... "
apt update -y

# Step 3: Install Ansible if not already installed
if ! is_installed "ansible"; then
    echo "Ansible is not installed. Installing Ansible..."
    apt install -y ansible
else
    echo "Ansible is already installed."
fi

# Step 3.1: Install sudo if not already installed
if ! is_installed "sudo"; then
    echo "sudo is not installed. Installing sudo..."
    apt install -y sudo
else
    echo "sudo is already installed."
fi

# Step 4: Check if the basic setup playbook exists
if [ ! -f "$BASIC_SETUP_PLAYBOOK" ]; then
    echo "Error: Basic setup playbook ($BASIC_SETUP_PLAYBOOK) not found!"
    exit 1
fi

# Step 5: Run the basic environment setup playbook
echo "Running the basic environment setup playbook..."
ansible-playbook "$BASIC_SETUP_PLAYBOOK" --limit SD-HQ-NMS -i "$INVENTORY"

# Step 6: Check if the NMS setup playbook exists
if [ ! -f "$NMS_SETUP_PLAYBOOK" ]; then
    echo "Error: NMS setup playbook ($NMS_SETUP_PLAYBOOK) not found!"
    exit 1
fi

# Step 7: Run the NMS setup playbook
echo "Running the NMS software installation playbook..."
ansible-playbook "$NMS_SETUP_PLAYBOOK" --limit SD-HQ-NMS -i "$INVENTORY"

echo "Setup complete. Your NMS should be fully configured."
