**English** | [Español](./Readme.es.md)

# Certificate Server Generator

![SSL](https://img.shields.io/badge/SSL_Certificates-Multiple_Methods-28a745?style=for-the-badge)
![Ansible](https://img.shields.io/badge/Ansible-Automated-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![OpenSSL](https://img.shields.io/badge/OpenSSL-Manual-721412?style=for-the-badge&logo=openssl&logoColor=white)

SSL certificate generation for Gitea, Harbor and wildcard domains using two different methods.

## Available Methods

### 1. Automated with Ansible

**Location**: [`ansible-ssl/`](./ansible-ssl/)

**Features**:
- Fully automated with Ansible
- Uses Docker containers with mkcert
- Configured through playbooks
- Ideal for multiple hosts

**When to use**:
- You have multiple servers
- You want repeatable automation
- You prefer configuration management

### 2. Manual with OpenSSL

**Location**: [`open-ssl/`](./open-ssl/)

**Features**:
- Direct OpenSSL commands
- Full control over the process
- No Docker or Ansible required
- Simple copy-paste commands

**When to use**:
- A single server or just a few
- You prefer manual control
- Environment without Docker/Ansible

## Quick Comparison

| Aspect | Ansible (ansible-ssl/) | OpenSSL (open-ssl/) |
|--------|------------------------|---------------------|
| **Automation** | High | Manual |
| **Requirements** | Ansible + Docker | OpenSSL only |
| **Configuration** | YAML playbook | Direct commands |


## Generated Certificates

Both methods generate the same certificates:

- **Root CA**: Shared Certificate Authority
- **Gitea**: `gitea.server.local` + local IPs
- **Harbor**: `registry.harbor.local`, `harbor.server.local` + IPs
- **Wildcard**: `*.local` for multiple services

## Recommended Choice

- **Beginner or quick test**: Use [`open-ssl/`](./open-ssl/)
- **Production or multiple hosts**: Use [`ansible-ssl/`](./ansible-ssl/)

## Supported Domains

- `gitea.server.local`, `registry.harbor.local`, `harbor.server.local`
- `*.local` (wildcard for any subdomain)
- `localhost`, `127.0.0.1` and specific IP addresses
