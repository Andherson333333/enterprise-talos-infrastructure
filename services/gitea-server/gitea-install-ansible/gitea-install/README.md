# Role: gitea-install

Despliega Gitea detrás de Traefik con TLS, todo con imágenes servidas desde Harbor.

## Qué hace

1. Crea `/opt/gitea`
2. Copia `docker-compose.yml`, `tls.yml` y los certificados (`gitea.pem`, `gitea.key`, `rootCA.pem`)
3. Levanta el stack con `docker compose up -d`

| Componente | Detalle |
|------------|---------|
| Traefik | `traefik:v3.0`, puertos 80 (redirect a HTTPS), 443, 2222 (SSH) |
| Gitea | `gitea/gitea:1.24.2`, SQLite, Actions habilitado |
| Dominio | `gitea.server.local` / `192.168.253.11` |
| Imágenes | `registry.harbor.local/proxy-docker/...` |

## Requisitos

- Docker + Compose y CA confiada en el host (`shared-infrastructure`)
- Harbor con el proxy cache `proxy-docker`
- Certificados generados (`requirements/certificate-server-config`). Las llaves no deben subirse a Git.

## Uso

```bash
ansible-playbook -i inventory gitea-install.yml
```

## Verificación

```bash
docker compose -f /opt/gitea/docker-compose.yml ps
```

```bash
curl -I https://gitea.server.local
```
