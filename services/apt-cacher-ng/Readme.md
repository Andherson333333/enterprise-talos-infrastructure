# APT-Cacher-NG Service

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![APT](https://img.shields.io/badge/APT-Cache-FF6B35?style=for-the-badge&logo=debian&logoColor=white)

Proxy cache automatizado para paquetes APT/Debian mediante Ansible y Docker Compose.

## ¿Qué es?

APT-Cacher-NG cachea paquetes APT localmente. Los clientes descargan una vez desde internet, las siguientes instalaciones son instantáneas desde el cache local.

### Beneficios Principales

- **Ahorro de ancho de banda**: Los paquetes se descargan una sola vez desde internet
- **Velocidad mejorada**: Instalaciones posteriores desde cache local son instantáneas
- **Reducción de carga**: Menos peticiones a repositorios oficiales
- **Disponibilidad offline**: Funciona aunque los repositorios externos estén inaccesibles
- **Eficiencia de red**: Ideal para entornos con múltiples servidores Debian/Ubuntu

## Prerequisitos

- Docker y Docker Compose
- Ansible 2.9+
- Acceso a internet

## Instalación

```bash
# Ejecutar playbook
ansible-playbook -i inventory apt-cacher-ng.yml
```

## Configuración

### Variables

```yaml
# defaults/main.yml
apt_cacher_ng_port: 3142
apt_cacher_ng_directory: /opt/apt-cacher-ng
```

### Inventario

```ini
[apt_cache_servers]
cache-server ansible_host=192.168.1.50 ansible_user=root
```

## Uso

### Configurar Cliente Ubuntu/Debian

```bash
# Configuración permanente
echo 'Acquire::http::Proxy "http://CACHE_IP:3142";' | sudo tee /etc/apt/apt.conf.d/01proxy

# Usar cache
apt update
apt install nginx
```

### Panel Web

```
http://CACHE_IP:3142/acng-report.html
```
![APT](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/apt-cacher-ng%20server-1.png)

## Verificación

```bash
# Estado del servicio
docker ps | grep apt-cacher-ng

# Logs
docker logs apt-cacher-ng

# Test desde cliente
curl http://CACHE_IP:3142/acng-report.html
```

## Administración

```bash
# Reiniciar
cd /opt/apt-cacher-ng && docker compose restart

# Ver cache utilizado
docker exec apt-cacher-ng du -sh /var/cache/apt-cacher-ng
```
