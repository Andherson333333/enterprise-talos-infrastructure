**English** | [Español](./README.es.md)

# Host Network Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Network](https://img.shields.io/badge/Network-Static_IP-FF6B35?style=for-the-badge&logo=cisco&logoColor=white)

Automatic static network configuration and local DNS resolution using an Ansible playbook.

## What does it do?

Configures a static IP and local hostnames for services, giving a fixed network and internal DNS resolution.

### Included configuration

- **Static IP**: 192.168.253.11/24
- **Gateway**: 192.168.253.1  
- **Local DNS**: Harbor Registry and Gitea Server
- **Hostname**: gitea-server

## Usage

```bash
# Apply configuration
ansible-playbook -i inventory host-network-1ip.yml
```

## Configuration files

```
host-network-1ip/
├── files/
│   ├── hosts                        # Local DNS resolution
│   └── interfaces                   # Static network configuration
└── tasks/main.yml                   # Configuration tasks
```

### Configured hosts

```
192.168.253.12 registry.harbor.local
192.168.253.11 gitea.server.local
```

## Verification

```bash
# Check configured IP
ansible all -i inventory -m shell -a "ip addr show ens18"

# Check DNS resolution
ansible all -i inventory -m shell -a "cat /etc/hosts"

# Test connectivity
ansible all -i inventory -m shell -a "ping -c 2 registry.harbor.local"
```

## Customization

To change the configuration, edit:
- `files/interfaces` - IP, gateway, netmask
- `files/hosts` - Add/modify hostnames
