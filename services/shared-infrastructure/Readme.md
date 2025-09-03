# Shared Infrastructure

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Infrastructure](https://img.shields.io/badge/Infrastructure-Shared-4CAF50?style=for-the-badge&logo=ansible&logoColor=white)

Infraestructura compartida base para servicios empresariales mediante playbooks de Ansible.

## ¿Qué incluye?

Configuración base común requerida por todos los servicios: proxy APT, Docker y certificados SSL/TLS.

### Componentes

- **prox-repo-debian**: Configuración proxy APT para cache de paquetes
- **docker-install-ansible**: Instalación offline de Docker y componentes
- **certificate-ansible**: Configuración certificados SSL/TLS sistema y Docker

## Orden de Implementación

**IMPORTANTE**: Ejecutar en este orden específico para dependencias correctas.

### 1. Configurar Proxy APT
```bash
cd prox-repo-debian/
ansible-playbook -i inventory proxy-setup.yml
```

### 2. Instalar Docker
```bash
cd docker-install-ansible/
ansible-playbook -i inventory docker-install.yml
```

### 3. Configurar Certificados
```bash
cd certificate-ansible/
ansible-playbook -i inventory certificados.yml
```

## Verificación Completa

```bash
# Verificar proxy configurado
ansible all -i inventory -m shell -a "cat /etc/apt/apt.conf.d/02proxy"

# Verificar Docker instalado
ansible all -i inventory -m shell -a "docker --version"

# Verificar certificados
ansible all -i inventory -m shell -a "ls /usr/local/share/ca-certificates/"
```

## Uso en Servicios

Ejecutar esta infraestructura base antes de desplegar:
- harbor-server
- gitea-server  
- apt-cacher-ng

## Documentación Específica

| Componente | README | Propósito |
|------------|--------|-----------|
| prox-repo-debian | [`prox-repo-debian/README.md`](./prox-repo-debian/README.md) | Proxy cache APT |
| docker-install-ansible | [`docker-install-ansible/README.md`](./docker-install-ansible/README.md) | Instalación Docker offline |
| certificate-ansible | [`certificate-ansible/README.md`](./certificate-ansible/README.md) | Certificados SSL/TLS |
