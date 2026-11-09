**English** | [Español](./README.es.md)

# Role: certificados

Distributes the internal CA to hosts so the system and Docker trust Harbor and Gitea.

## What it does

1. Copies `harbor-ca.crt` and `gitea-ca.crt` to `/usr/local/share/ca-certificates/`
2. Runs `update-ca-certificates`
3. Creates `/etc/docker/certs.d/192.168.253.12` and `/etc/docker/certs.d/registry.harbor.local`
4. Copies `ca.crt` into `/etc/docker/certs.d/` for `192.168.253.11` and `gitea.server.local`
5. Restarts Docker

> **Note**: step 3 creates the Harbor directories, but step 4 copies into the Gitea ones, which are never created. Make sure both lists match.

## Requirements

- Docker installed
- CA exported to `files/` (`ca.crt`, `harbor-ca.crt`, `gitea-ca.crt`)

## Usage

```bash
ansible-playbook -i inventory certificados.yml
```

Targets the `gitea` group by default. Change `hosts:` in `certificados.yml` for other servers.

## Verification

```bash
ls /etc/ssl/certs | grep -iE 'harbor|gitea'
```

```bash
docker login registry.harbor.local
```
