#!/bin/bash
# You must run PrepareNMS-setup.sh before this script

# This script sets up a python-venv in the current user's directory, and installs ansible within it.

# Variables
BASIC_SETUP_PLAYBOOK="../../playbooks/debian-basic-setup.yaml"
NMS_SETUP_PLAYBOOK="../../playbooks/nms-setup.yaml"
INVENTORY="../../inventory/hosts.yaml"
VENV_DIR="$HOME/ansible-venv"

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

# Step 5: Check if the basic setup playbook exists
if [ ! -f "$BASIC_SETUP_PLAYBOOK" ]; then
    echo "Error: Basic setup playbook ($BASIC_SETUP_PLAYBOOK) not found!"
    deactivate
    exit 1
fi

# Step 6: Run the basic environment setup playbook using virtual environment's Ansible
echo "Running the basic environment setup playbook..."
ansible-playbook "$BASIC_SETUP_PLAYBOOK" --limit SD-HQ-NMS -i "$INVENTORY"

# Step 7: Check if the NMS setup playbook exists
if [ ! -f "$NMS_SETUP_PLAYBOOK" ]; then
    echo "Error: NMS setup playbook ($NMS_SETUP_PLAYBOOK) not found!"
    deactivate
    exit 1
fi

# Step 8: Run the NMS setup playbook using virtual environment's Ansible
echo "Running the NMS software installation playbook..."
ansible-playbook "$NMS_SETUP_PLAYBOOK" --limit SD-HQ-NMS -i "$INVENTORY"

# Deactivate the virtual environment
deactivate
echo "Setup complete. Your NMS should be fully configured."
