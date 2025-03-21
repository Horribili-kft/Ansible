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

### Control node (SD-HQ-NMS)
| Requirement                                              | Automatically done by                       |
|----------------------------------------------------------|---------------------------------------------|
| Basic packages (python, python-venv, pip)                | PrepareNMS-setup.sh (root required)         |
| Ansible                                                  | PrepareNMS-user.sh                          |
| Default community modules                                | PrepareNMS-user.sh                          |
| zabbix.zabbix module version >=1.4                       | PrepareNMS-user.sh                          |


### Controlled hosts

#### Linux
| Requirement                                              | Automatically done by (run on host, not NMS)|
|----------------------------------------------------------|---------------------------------------------|
| Basic packages (python, sudo)                            | PrepareForAnsible.sh (root required)        |
| Sudo privileges on "ansible" user                        | PrepareForAnsible.sh (root required)        |
| SSH Access to the host by control node                   | PrepareForAnsible.sh (root required)        |

#### Cisco
| Requirement                                              | Automatically done by (run on host, not NMS)|


## Installation

### Install on control node (SD-HQ-NMS)

> [!NOTE]
> First, run the basic setup script that installs basic dependencies as ***root***

```bash
apt update -y
apt install -y git 
git clone https://github.com/Horribili-kft/Ansible
cd ./Ansible/scripts/Linux
chmod +x ./*
./PrepareNMS-.sh
```

> [!NOTE]
> Next, run the script that installs the ansible-venv as ***non-root***

```bash
./PrepareNMS-user.sh
```

You can now run Ansible.

> [!NOTE]
> Final step is to run two playbooks that completely set up the NMS

> [!IMPORTANT]
> Your manager user must be in the sudo group, if they are not you should run
> `su -c "usermod -aG sudo <username>"`

```bash
cd
# Use the virtual environment
source ansible-venv/bin/activate
cd Ansible
# Run this playbook first
ansible-playbook playbooks/debian-basic-setup.yaml  --limit SD-HQ-NMS -i inventory/hosts.yaml --ask-become-pass
# Run this playbook second
ansible-playbook playbooks/nms-setup.yaml  --limit SD-HQ-NMS -i inventory/hosts.yaml --ask-become-pass
```




> [!TIP]
> You can run the PrepareNMS-user.sh script as a different user to set ansible up for that user as well.


### Prepare Linux hosts for management

> [!NOTE]
> Run the script. You don't need to download the full repository, only this script is enough.

```bash
wget https://raw.githubusercontent.com/Horribili-kft/Ansible/refs/heads/main/scripts/Linux/PrepareForAnsible.sh
chmod +x ./PrepareForAnsible.sh
./PrepareForAnsible.sh
```

> [!CAUTION]
> The scipt sets up a temporary password for the created "ansible" user until the control node takes over and replaces the password login with pubkey login.
> This leaves a small window of time between you running PrepareForAnsible.sh on the host and setup_ssh_key.yaml on the control node where the host can be connected to via password.
> The script (along with the temporary password) is in a public GitHub repository, so changing the temporary password in the script is recommended for environments requiring absolute security.


## Usage
> [!IMPORTANT]
> The scripts install a python virtual environment with Ansible into the ./ansible
> Before running any playbooks, you should tell the shell to use the venv

```bash
source ansible-venv/bin/activate
```

```bash
ansible-playbook playbooks/<playbook_name>.yaml -i inventory/hosts.yaml
```
> [!IMPORTANT]
> When password / become (sudo/enable) password is required

```bash
ansible-playbook playbooks/<playbook_name>.yaml -i inventory/hosts.yaml --ask-pass --ask-become-pass
```


Replace `<playbook_name>` with the name of the playbook you wish to execute.

## Playbooks

### Setup scripts
- **nms-setup.yaml**: Sets up the control node. Installs Nessus and Zabbix. *Runs only on SD-HQ-NMS*
- **debian-basic-setup.yaml**: Sets up a basic Debian server environment, including essential packages, zabbix-agent and resolv.conf. *Runs on all linux_servers*
- **setup_ssh_key.yaml**: Configures SSH pubkey-based authentication for the "ansible" user. *Runs on all linux_servers*
- **pingall.yaml**: Orders devices to ping key network targets to test connectivity.
- **zabbix-register-hosts.yaml**: Automatically registers hosts to Zabbix for monitoring.

## Roles
- **zabbix-server-install**: Installs and configures
- **resolv.conf**: Manages the `/etc/resolv.conf` file.
- **zabbix-agent**: Installs and configures the Zabbix agent on target machines. Included in debian-basic-setup.yaml


