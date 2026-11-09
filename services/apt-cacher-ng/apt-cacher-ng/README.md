**English** | [Español](./README.es.md)

# Role: apt-cacher-ng

Deploys apt-cacher-ng in Docker as an APT package cache for the Debian VMs in the environment.

## What it does

1. Creates `/opt/apt-cacher-ng`
2. Copies `files/docker-compose.yml`
3. Starts the service with `docker compose up -d`

| Parameter | Value |
|-----------|-------|
| Image | `sameersbn/apt-cacher-ng` |
| Port | `80` (host) → `3142` (container) |
| Volume | `apt-cacher-ng` → `/var/cache/apt-cacher-ng` |
| Healthcheck | `http://localhost:3142/acng-report.html` |

## Requirements

- Docker + Compose installed (`shared-infrastructure/docker-install-ansible`)
- `apt_ng` group in the inventory

## Usage

```bash
ansible-playbook -i inventory apt-cacher-ng.yml
```

## Verification

```bash
docker ps --filter name=apt-cacher-ng
```

```bash
curl -s http://localhost/acng-report.html | head
```
