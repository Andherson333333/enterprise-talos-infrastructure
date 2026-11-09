[English](./README.md) | **Español**

# Role: harbor-install

Instala Harbor v2.13.1 con Trivy usando el instalador offline.

## Qué hace

1. Crea `/opt/harbor` y `/opt/harbor/certs`
2. Copia el instalador offline, `harbor.yml` y los certificados
3. Extrae el instalador y ejecuta `./prepare`
4. Si Harbor no está corriendo, ejecuta `./install.sh --with-trivy`
5. Borra el `.tgz` del instalador

Idempotente: no reinstala si `docker compose ps` ya devuelve contenedores.

## Requisitos

- Docker + Compose (`shared-infrastructure/docker-install-ansible`)
- `files/harbor-offline-installer-v2.13.1.tgz`
- Certificados `harbor.pem` / `harbor.key` (`requirements/certificate-server-config`)

## Variables (`vars/main.yml`)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `harbor_install_dir` | `/opt/harbor` | Directorio de instalación |

La configuración de Harbor (hostname, TLS, passwords) está en `files/harbor.yml`.

> `harbor.yml` incluye el password de admin y el de la base de datos: usar `ansible-vault encrypt` o placeholders antes de versionarlo.

## Uso

```bash
ansible-playbook -i inventory harbor-install.yml
```

## Verificación

```bash
docker compose -f /opt/harbor/harbor/docker-compose.yml ps
```

```bash
curl -I https://registry.harbor.local
```
