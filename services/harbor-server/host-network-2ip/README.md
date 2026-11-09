**English** | [Español](./README.es.md)

# Host Network 2IP Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Network](https://img.shields.io/badge/Network-Dual_IP-FF6B35?style=for-the-badge&logo=cisco&logoColor=white)

Automatic dual-IP network configuration and DNS resolution for the Harbor server using an Ansible playbook.

## What does it do?

Configures two static network interfaces and local hostnames for services, giving dual connectivity and internal DNS resolution.

### Included configuration

- **Interface ens18**: 192.168.133.20/24 (gateway 192.168.133.2)
- **Interface ens19**: 192.168.253.12/24 (no gateway)
- **Local DNS**: Harbor Registry (dual IP) and Gitea Server
- **Hostname**: harbor-server

## Usage

```bash
# Apply configuration
ansible-playbook -i inventory network.yml
```

### Configured hosts

```
192.168.133.20 registry.harbor.local
192.168.253.12 registry.harbor.local  
192.168.253.11 gitea.server.local
```

## Verification

```bash
# Check both interfaces
ansible all -i inventory -m shell -a "ip addr show ens18"
ansible all -i inventory -m shell -a "ip addr show ens19"

# Check DNS resolution
ansible all -i inventory -m shell -a "cat /etc/hosts"

# Test dual connectivity
ansible all -i inventory -m shell -a "ping -c 2 192.168.133.20"
ansible all -i inventory -m shell -a "ping -c 2 192.168.253.12"
```

## Customization

To change the configuration, edit:
- `files/interfaces` - IPs, gateway, netmask
- `files/hosts` - Add/change hostnames
