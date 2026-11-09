**English** | [Español](./README.es.md)

# Role: gitea-install

Deploys Gitea behind Traefik with TLS, all images served from Harbor.

## What it does

1. Creates `/opt/gitea`
2. Copies `docker-compose.yml`, `tls.yml` and the certificates (`gitea.pem`, `gitea.key`, `rootCA.pem`)
3. Starts the stack with `docker compose up -d`

| Component | Detail |
|-----------|--------|
| Traefik | `traefik:v3.0`, ports 80 (redirect to HTTPS), 443, 2222 (SSH) |
| Gitea | `gitea/gitea:1.24.2`, SQLite, Actions enabled |
| Domain | `gitea.server.local` / `192.168.253.11` |
| Images | `registry.harbor.local/proxy-docker/...` |

## Requirements

- Docker + Compose and a trusted CA on the host (`shared-infrastructure`)
- Harbor with the `proxy-docker` proxy cache
- Certificates generated (`requirements/certificate-server-config`). Keys must not be committed to Git.

## Usage

```bash
ansible-playbook -i inventory gitea-install.yml
```

## Verification

```bash
docker compose -f /opt/gitea/docker-compose.yml ps
```

```bash
curl -I https://gitea.server.local
```
