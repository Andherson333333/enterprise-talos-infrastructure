[English](./README.md) | **Español**

# Role: apt-cacher-ng

Despliega apt-cacher-ng en Docker como cache de paquetes APT para las VMs Debian del entorno.

## Qué hace

1. Crea `/opt/apt-cacher-ng`
2. Copia `files/docker-compose.yml`
3. Levanta el servicio con `docker compose up -d`

| Parámetro | Valor |
|-----------|-------|
| Imagen | `sameersbn/apt-cacher-ng` |
| Puerto | `80` (host) → `3142` (contenedor) |
| Volumen | `apt-cacher-ng` → `/var/cache/apt-cacher-ng` |
| Healthcheck | `http://localhost:3142/acng-report.html` |

## Requisitos

- Docker + Compose instalados (`shared-infrastructure/docker-install-ansible`)
- Grupo `apt_ng` en el inventario

## Uso

```bash
ansible-playbook -i inventory apt-cacher-ng.yml
```

## Verificación

```bash
docker ps --filter name=apt-cacher-ng
```

```bash
curl -s http://localhost/acng-report.html | head
```
