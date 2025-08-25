# Ansible mkcert Certificate Generator

![Ansible](https://img.shields.io/badge/Ansible-Latest-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Required-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![mkcert](https://img.shields.io/badge/mkcert-SSL_Certificates-28a745?style=for-the-badge)
![Harbor](https://img.shields.io/badge/Harbor-Registry-60B932?style=for-the-badge&logo=harbor&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-Git_Service-609926?style=for-the-badge&logo=gitea&logoColor=white)

Role de Ansible para automatizar la generación de certificados SSL usando mkcert para Gitea, Harbor y dominios wildcard.

## Características

- **Certificados para Gitea**: `gitea.server.local`, IPs locales
- **Certificados para Harbor**: `registry.harbor.local`, `harbor.server.local`, IPs
- **Certificados Wildcard**: `*.local` para múltiples servicios
- **CA compartida**: Usa la misma Certificate Authority de Harbor

## Estructura del Proyecto

```
mkcert-ca/
├── inventory                     # Inventario de hosts
├── mkcer.yml                    # Playbook principal
└── mkcert-ca/                   # Role de Ansible
    ├── defaults/main.yml        # Variables por defecto
    ├── tasks/main.yml          # Tareas principales
    └── files/                  # Docker compose files
        ├── gitea-compose.yml
        ├── harbor-compose.yml
        └── wildcard-local-compose.yml
```

## Requisitos

- Ansible instalado
- Docker y Docker Compose en hosts destino
- CA de Harbor en `/opt/harbor/mkcert-ca`

## Uso

### 1. Configurar inventario

Edita el archivo `inventory` con tus hosts:

```ini
[certificate_servers]
your-server ansible_host=192.168.1.100
```

### 2. Ejecutar playbook

```bash
# Ejecutar desde el directorio mkcert-ca/
ansible-playbook -i inventory mkcer.yml
```

### 3. Verificar certificados

Los certificados se generan en:
- `/opt/generated_certs/gitea/` (gitea.pem, gitea.key)
- `/opt/generated_certs/harbor/` (harbor.pem, harbor.key)
- `/opt/generated_certs/wildcard-local/` (wildcard-local.pem, wildcard-local.key)

## Variables

Define en `defaults/main.yml` o al ejecutar:

```yaml
cert_base_dir: "/opt/generated_certs"  # Directorio base de certificados
```

## Dominios Soportados

- **Gitea**: `gitea.server.local`, `localhost`, `127.0.0.1`
- **Harbor**: `registry.harbor.local`, `harbor.server.local`, `localhost`
- **Wildcard**: `*.local`, `local`, `localhost`
