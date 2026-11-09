**English** | [Español](./README.es.md)

# Host Network 2IP Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Network](https://img.shields.io/badge/Network-Dual_IP-FF6B35?style=for-the-badge&logo=cisco&logoColor=white)

Automatic dual-IP network configuration for the APT-Cacher-NG server using an Ansible playbook.

## What does it do?

Configures two static network interfaces and the hostname for the APT cache server, giving the cache service dual connectivity.

### Included configuration

- **Interface ens18**: 192.168.133.157/24 (gateway 192.168.133.2)
- **Interface ens19**: 192.168.253.10/24 (no gateway)
- **Hostname**: apt-cacher-ng.local

## Usage

```bash
# Apply configuration
ansible-playbook -i inventory network.yml
```

### Configured host

```
127.0.1.1 apt-cacher-ng.local apt-cacher-ng
```

## Verification

```bash
# Check both interfaces
ansible all -i inventory -m shell -a "ip addr show ens18"
ansible all -i inventory -m shell -a "ip addr show ens19"

# Check hostname
ansible all -i inventory -m shell -a "cat /etc/hosts"

# Test dual connectivity
ansible all -i inventory -m shell -a "ping -c 2 192.168.133.157"
ansible all -i inventory -m shell -a "ping -c 2 192.168.253.10"
```

## Customization

To change the configuration, edit:
- `files/interfaces` - IPs, gateway, netmask
- `files/hosts` - Hostname
