# Ansible Playbook Repository

## Overview
This repository contains playbook files for the Solar Dynamics company network. The playbooks are designed assuming SD-HQ-NMS is the control node. 

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Scripts](#scripts)
- [Playbooks](#playbooks)
- [Roles](#roles)

## Prerequisites
- Ansible (installed and configured with prepareNMS.sh)
- Default community modules (installed by default)
- zabbix.zabbix module version >=1.4 (installed automatically by nms-setup.yaml)
- SSH Access to the target machines (the PrepareForAnsible.sh script set this up automatically for user "ansible" on all target hosts)
- Root privileges on the target machines for setup. (After installation the "ansible" user is used for root tasks. They are set up with passwordless sudo by PrepareForAnsible.sh)


## Installation on control node (SD-HQ-NMS)

First, run the basic setup script that installs dependencies and sets up a python-venv

```bash
apt update -y
apt install -y git 
git clone https://github.com/Horribili-kft/Ansible
cd ./Ansible/scripts/Linux
chmod +x ./PrepareNMS.sh
./PrepareNMS.sh
```

Then move the created python-venv environment to your home folder, and change the permissions so you can use it.ű

```bash
# Substitute username for your non-root manager user (solaire in this example)
sudo mv -r /root/ansible-venv /home/solaire/
sudo chown -R solaire:solaire /home/solaire/ansible-venv
```



## Linux host configuration for control with Ansible

```bash
wget https://raw.githubusercontent.com/Horribili-kft/Ansible/refs/heads/main/scripts/Linux/PrepareForAnsible.sh
chmod +x ./PrepareForAnsible.sh
# The scirpt requires root permissions
# You can change the temporary password for the ansible user (which is later removed by the control node)
./PrepareForAnsible.sh
```


Make sure to run the `PrepareForAnsible.sh` script to set up the necessary environment:

```bash
chmod +x helperscripts/PrepareForAnsible.sh
sudo ./helperscripts/PrepareForAnsible.sh
```

## Usage
The scripts install a python virtual environment with Ansible into the ./ansible

```bash
ansible-playbook playbooks/<playbook_name>.yaml -i inventory/hosts.yaml
```

Replace `<playbook_name>` with the name of the playbook you wish to execute.

## Playbooks
- **debian-basic-setup.yaml**: Sets up a basic Debian environment, including essential packages and user configurations.
- **setup_ssh_key.yaml**: Configures SSH key-based authentication for users.
- **pingall.yaml**: Pings all Linux and Windows servers to check connectivity.
- **zabbix-register-hosts.yaml**: Registers hosts to Zabbix for monitoring.

## Roles
- **resolv.conf**: Manages the `/etc/resolv.conf` file.
- **zabbix-agent**: Installs and configures the Zabbix agent on target machines.


