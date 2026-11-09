**English** | [Español](./Readme.es.md)

# Ansible APT Proxy Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![APT](https://img.shields.io/badge/APT-Proxy-FF6B35?style=for-the-badge&logo=debian&logoColor=white)

Configures an APT proxy on multiple servers automatically.

## What does it do?

Creates `/etc/apt/apt.conf.d/02proxy` on every server so they use the centralized APT proxy.

## Usage

```bash
# Run
ansible-playbook -i inventory ansible-proxy.yaml

# Verify
ansible all -i inventory -m shell -a "cat /etc/apt/apt.conf.d/02proxy"
```

## Customize

```yaml
# Change the proxy IP in ansible-proxy.yaml
content: 'Acquire::http::Proxy "http://YOUR_PROXY_IP:3142";'
```

## Remove

```bash
# Remove the configuration
ansible all -i inventory -m file -a "path=/etc/apt/apt.conf.d/02proxy state=absent" --become
```
