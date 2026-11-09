**English** | [Español](./Readme.es.md)

# Shared Infrastructure

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Infrastructure](https://img.shields.io/badge/Infrastructure-Shared-4CAF50?style=for-the-badge&logo=ansible&logoColor=white)

Shared base infrastructure for enterprise services using Ansible playbooks.

## What does it include?

Common base configuration required by every service: APT proxy, Docker and SSL/TLS certificates.

### Components

- **prox-repo-debian**: APT proxy configuration for package caching
- **docker-install-ansible**: Offline installation of Docker and its components
- **certificate-ansible**: SSL/TLS certificate configuration for the system and Docker

## Implementation Order

**IMPORTANT**: Run in this exact order so dependencies are satisfied.

### 1. Configure APT Proxy
```bash
cd prox-repo-debian/
ansible-playbook -i inventory proxy-setup.yml
```

### 2. Install Docker
```bash
cd docker-install-ansible/
ansible-playbook -i inventory docker-install.yml
```

### 3. Configure Certificates
```bash
cd certificate-ansible/
ansible-playbook -i inventory certificados.yml
```

## Full Verification

```bash
# Check proxy configuration
ansible all -i inventory -m shell -a "cat /etc/apt/apt.conf.d/02proxy"

# Check Docker installation
ansible all -i inventory -m shell -a "docker --version"

# Check certificates
ansible all -i inventory -m shell -a "ls /usr/local/share/ca-certificates/"
```

## Usage by Services

Run this base infrastructure before deploying:
- harbor-server
- gitea-server  
- apt-cacher-ng

## Specific Documentation

| Component | README | Purpose |
|-----------|--------|---------|
| prox-repo-debian | [`prox-repo-debian/Readme.md`](./prox-repo-debian/Readme.md) | APT cache proxy |
| docker-install-ansible | [`docker-install-ansible/Readme.md`](./docker-install-ansible/Readme.md) | Offline Docker installation |
| certificate-ansible | [`certificate-ansible/Readme.md`](./certificate-ansible/Readme.md) | SSL/TLS certificates |
