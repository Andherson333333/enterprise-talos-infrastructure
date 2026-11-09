**English** | [Español](./README.es.md)

# Role: harbor-install

Installs Harbor v2.13.1 with Trivy using the offline installer.

## What it does

1. Creates `/opt/harbor` and `/opt/harbor/certs`
2. Copies the offline installer, `harbor.yml` and the certificates
3. Extracts the installer and runs `./prepare`
4. If Harbor is not running, runs `./install.sh --with-trivy`
5. Removes the installer `.tgz`

Idempotent: it does not reinstall if `docker compose ps` already returns containers.

## Requirements

- Docker + Compose (`shared-infrastructure/docker-install-ansible`)
- `files/harbor-offline-installer-v2.13.1.tgz`
- `harbor.pem` / `harbor.key` certificates (`requirements/certificate-server-config`)

## Variables (`vars/main.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `harbor_install_dir` | `/opt/harbor` | Installation directory |

Harbor configuration (hostname, TLS, passwords) lives in `files/harbor.yml`.

> `harbor.yml` includes the admin and database passwords: use `ansible-vault encrypt` or placeholders before committing it.

## Usage

```bash
ansible-playbook -i inventory harbor-install.yml
```

## Verification

```bash
docker compose -f /opt/harbor/harbor/docker-compose.yml ps
```

```bash
curl -I https://registry.harbor.local
```
