**English** | [Español](./README.es.md)

# Role: mkcert-ca

Generates TLS certificates for internal services, signed by the local mkcert CA, using `iamluc/mkcert` containers with Docker Compose.

## What it does

1. Creates `/opt/generated_certs/{gitea,harbor,wildcard-local}`
2. Copies the `docker-compose.yml` for each generator
3. Runs `docker compose up` in each folder to issue the certificates

| Certificate | Files | SANs |
|-------------|-------|------|
| Gitea | `gitea/gitea.pem`, `gitea.key` | `gitea.server.local`, `localhost`, `127.0.0.1`, `192.168.253.11` |
| Harbor | `harbor/harbor.pem`, `harbor.key` | `registry.harbor.local`, `harbor.server.local`, `harbor.local`, `localhost`, IPs |
| Wildcard | `wildcard-local/wildcard-local.pem`, `.key` | `*.local`, `local`, `localhost` |

`files/` also includes `openbao-compose.yml` and `proxy-openbao-compose.yml` (OpenBao nodes and HAProxy); the role does not run them today, they are launched manually.

## Requirements

- Docker + Compose on the host
- mkcert CA in `/opt/harbor/mkcert-ca` (mounted read-only by the compose files)

## Variables (`vars/main.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `cert_base_dir` | `/opt/generated_certs` | Output directory |
| `mkcert_ca_path` | `/opt/mkcert-ca` | Not used: the compose files mount `/opt/harbor/mkcert-ca` directly |

## Usage

```bash
ansible-playbook -i ../inventory mkcer.yml
```

## Verification

```bash
openssl x509 -in /opt/generated_certs/harbor/harbor.pem -noout -subject -ext subjectAltName
```
