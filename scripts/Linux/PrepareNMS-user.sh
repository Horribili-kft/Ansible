#!/bin/bash
# You must run PrepareNMS-setup.sh before this script

# This script sets up a python-venv in the current user's directory, and installs ansible within it.
# To run it, add execute permissions, and execute as the user you want to install ansible for
# chmod +x ./PrepareNMS-user.sh
# ./PrepareNMS-user.sh

# Variables
BASIC_SETUP_PLAYBOOK="../../playbooks/debian-basic-setup.yaml"
NMS_SETUP_PLAYBOOK="../../playbooks/nms-setup.yaml"
INVENTORY="../../inventory/hosts.yaml"
VENV_DIR="$HOME/ansible-venv"

# These modules will be installed automatically
REQUIRED_COLLECTIONS=(
    "zabbix.zabbix"

)

# Step 0: cd to script directory for relative paths to work:
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

# Step 1: Check if running as a non-root user
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a non-root user."
    exit 1
fi

# Step 2: Set up Python virtual environment for Ansible in user's home directory
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating a Python virtual environment for Ansible..."
    python3 -m venv "$VENV_DIR"
fi

# Step 3: Activate the virtual environment
echo "Activating the virtual environment..."
source "$VENV_DIR/bin/activate"

# Step 4: Install Ansible in the virtual environment if not already installed
if ! pip show ansible >/dev/null 2>&1; then
    echo "Ansible is not installed in the virtual environment. Installing Ansible..."
    pip install ansible
else
    echo "Ansible is already installed in the virtual environment."
fi

# Step 4.1: Install required Ansible collections
echo "Installing required Ansible collections..."
for collection in "${REQUIRED_COLLECTIONS[@]}"; do
    ansible-galaxy collection install "$collection"
done

# Step 5: Check if the basic setup playbook exists
if [ ! -f "$BASIC_SETUP_PLAYBOOK" ]; then
    echo "Warning: Basic setup playbook ($BASIC_SETUP_PLAYBOOK) not found!"
fi

# Step 6: Check if the NMS setup playbook exists
if [ ! -f "$NMS_SETUP_PLAYBOOK" ]; then
    echo "Warning: NMS setup playbook ($NMS_SETUP_PLAYBOOK) not found!"
fi

# Deactivate the virtual environment
deactivate
echo "Setup complete. Your NMS should be ready to run Ansible."

current_user=$(whoami)
echo "Your next moves should be:"
echo "1. Adding your user to the sudo group:"
echo "   su - -c 'usermod -aG sudo $current_user'"
echo ""
echo "2. Activating the Ansible virtual environment:"
echo "   source ~/ansible-venv/bin/activate"
echo ""
echo "3. Running the following playbooks in order:"
echo "   - First, run the basic setup playbook:"
echo "     ansible-playbook ~/Ansible/playbooks/debian-basic-setup.yaml --limit SD-HQ-NMS -i ~/Ansible/inventory/hosts.yaml --ask-become-pass"
echo "   - Second, run the NMS setup playbook:"
echo "     ansible-playbook ~/Ansible/playbooks/nms-setup.yaml --limit SD-HQ-NMS -i ~/Ansible/inventory/hosts.yaml --ask-become-pass"