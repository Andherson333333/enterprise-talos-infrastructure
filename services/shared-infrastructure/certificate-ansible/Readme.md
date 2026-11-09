**English** | [Español](./Readme.es.md)

# Certificates Ansible Role

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![SSL](https://img.shields.io/badge/SSL-Certificates-4CAF50?style=for-the-badge&logo=letsencrypt&logoColor=white)

Automatic SSL/TLS certificate configuration for the system and Docker using an Ansible playbook.

## What does it do?

Installs custom certificates on the system and configures them for Docker, updating the operating system certificate trust store.

### Included certificates

- harbor-ca.crt (Harbor Registry)
- gitea-ca.crt (Gitea Server) 
- ca.crt (Root certificate for Docker)

## Usage

```bash
# Apply configuration
ansible-playbook -i inventory certificados.yml
```

## Structure

```
certificados/
├── files/                           # SSL certificates
│   ├── ca.crt                       # Root CA for Docker
│   ├── harbor-ca.crt                # Harbor certificate
│   └── gitea-ca.crt                 # Gitea certificate
└── tasks/main.yml                   # Installation tasks
```

## Verification

```bash
# Check system certificates
ansible all -i inventory -m shell -a "ls /usr/local/share/ca-certificates/"

# Check Docker certificates
ansible all -i inventory -m shell -a "ls /etc/docker/certs.d/"

# Test SSL trust
ansible all -i inventory -m shell -a "curl -k https://registry.harbor.local"
```

## Updating

To update certificates:
1. Replace the .crt files in `files/`
2. Run the playbook again
3. Docker restarts automatically
