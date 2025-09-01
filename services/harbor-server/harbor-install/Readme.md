# Harbor Ansible Installation 

![Ansible](https://img.shields.io/badge/Ansible-Role-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Harbor](https://img.shields.io/badge/Harbor-v2.13.1-60B932?style=for-the-badge&logo=harbor&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-Scanner-1904DA?style=for-the-badge&logo=aqua&logoColor=white)

Guia para instalacion de harbor mediante ansible plaubook de forma automatizada con certificados SSL y scanner Trivy.

## Características

-  **Instalación Offline** con Harbor v2.13.1
-  **SSL/TLS** preconfigurado
-  **Trivy Scanner** integrado
-  **Docker Compose** automático
-  **Idempotente** y reutilizable

## Preparación

### 1. Descargar Harbor

```bash
wget https://github.com/goharbor/harbor/releases/download/v2.13.1/harbor-offline-installer-v2.13.1.tgz
```

### 2. Estructura del Proyecto

```
harbor-install/
├── files/
│   ├── harbor-offline-installer-v2.13.1.tgz  # ← Colocar aquí
│   ├── harbor.yml                             # Configuración
│   ├── harbor.pem                             # Certificado SSL
│   └── harbor.key                             # Clave privada
├── tasks/main.yml                             # Tareas Ansible
└── defaults/main.yml                          # Variables
```

## Configuración

### Variables Principales

```yaml
# defaults/main.yml
harbor_install_dir: "/opt/harbor"
harbor_hostname: "harbor.company.local"
harbor_admin_password: "Harbor12345"
harbor_ssl_enabled: true
harbor_trivy_enabled: true
```

### Inventario

```ini
[harbor_servers]
harbor-server ansible_host=192.168.1.100 ansible_user=root

[harbor_servers:vars]
harbor_hostname=registry.company.com
harbor_admin_password=MySecurePassword123
```

## Instalación

### Playbook Básico

```yaml
# harbor-install.yml
---
- name: Install Harbor Registry
  hosts: harbor_servers
  become: yes
  roles:
    - harbor-install
```

### Ejecutar

```bash
# Instalación estándar
ansible-playbook -i inventory harbor-install.yml

# Con variables personalizadas
ansible-playbook -i inventory harbor-install.yml \
  -e "harbor_hostname=registry.company.com"
```

![Trivy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-7.png)

## Verificación

### Comprobar Estado

```bash
# Servicios corriendo
cd /opt/harbor/harbor && docker compose ps

# Acceso web
curl -k https://harbor.server.local

```
![Trivy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-8.png)

![Trivy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-9.png)

### Acceso Web

```
URL: https://harbor.server.local
Usuario: admin
Password: [tu harbor_admin_password]
```

![Trivy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-9.png)


### Servicios Esperados

```
 harbor-core        (API principal)
 harbor-portal      (Web UI)
 registry           (Docker registry)
 harbor-db          (PostgreSQL)
 redis              (Cache)
 trivy-adapter      (Scanner)
```

### Puertos ocupados

```bash
# Verificar puertos
netstat -tlnp | grep -E ':(80|443)'

# Liberar puerto si es necesario
sudo fuser -k 443/tcp
```

## Backup y Actualización

### Crear Backup

```bash
cd /opt/harbor/harbor && docker compose down
tar -czf harbor-backup-$(date +%Y%m%d).tar.gz /opt/harbor/
```

### Actualizar Harbor

```bash
# Re-ejecutar role con nueva versión
ansible-playbook -i inventory harbor-install.yml \
  -e "harbor_version=v2.14.0"
```

## Certificados SSL

### Renovar Certificados

```bash
# Backup actuales
cp /opt/harbor/certs/harbor.* /backup/

# Copiar nuevos
cp new-harbor.pem /opt/harbor/certs/harbor.pem
cp new-harbor.key /opt/harbor/certs/harbor.key
chmod 600 /opt/harbor/certs/harbor.key

# Reiniciar
cd /opt/harbor/harbor && docker compose restart
```

## Notas Importantes

- El archivo `.tgz` debe estar en `files/` antes de ejecutar
- Cambiar passwords por defecto en producción
- Verificar resolución DNS del hostname
- Backup regular de la base de datos PostgreSQL
