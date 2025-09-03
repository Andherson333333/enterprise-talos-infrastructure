# Services

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Services](https://img.shields.io/badge/Services-Enterprise-4CAF50?style=for-the-badge&logo=kubernetes&logoColor=white)

Suite de servicios empresariales automatizados para infraestructura Talos mediante playbooks de Ansible.

**Características**:
- **Automatización completa**: Despliegue sin intervención manual
- **Certificados SSL autofirmados**: Comunicación segura preconfigurada  
- **Instalación offline**: Funciona sin acceso a internet una vez descargado
- **Idempotente**: Los playbooks se pueden re-ejecutar sin problemas

## Servicios Disponibles

### Infraestructura Base

| Servicio | Propósito | README |
|----------|-----------|--------|
| **shared-infrastructure** | Prerequisitos base (proxy, Docker, certificados) | [`shared-infrastructure/README.md`](./shared-infrastructure/README.md) |

### Servicios de Aplicación

| Servicio | Propósito | README |
|----------|-----------|--------|
| **harbor-server** | Registry privado de contenedores | [`harbor-server/README.md`](./harbor-server/README.md) |
| **gitea-server** | Git server empresarial | [`gitea-server/README.md`](./gitea-server/README.md) |
| **apt-cacher-ng** | Proxy cache para paquetes APT | [`apt-cacher-ng/README.md`](./apt-cacher-ng/README.md) |

## Orden de Implementación

### 1. Infraestructura Base (OBLIGATORIO)
```bash
cd shared-infrastructure/
# Seguir pasos del README (proxy → Docker → certificados)
```

### 2. Servicios de Aplicación (OPCIONAL - según necesidad)
```bash
# Registry de contenedores
cd harbor-server/

# Git server  
cd gitea-server/

# Cache APT
cd apt-cacher-ng/
```

## Implementación Completa

```bash
# 1. Infraestructura base
cd shared-infrastructure/
ansible-playbook -i inventory infrastructure-setup.yml

# 2. Servicios (ejemplo con todos)
cd ../harbor-server/
ansible-playbook -i inventory harbor-install.yml

cd ../apt-cacher-ng/
ansible-playbook -i inventory apt-cacher-ng.yml

cd ../gitea-server/ 
ansible-playbook -i inventory gitea-install.yml
```

## ¿Por Dónde Empezar?

1. **Nuevo Usuario**: Ejecuta `shared-infrastructure` primero
2. **Registry de Contenedores**: Ve a `harbor-server`
3. **Git Server**: Ve a `gitea-server`  
4. **Cache APT**: Ve a `apt-cacher-ng`

---

**Nota**: `shared-infrastructure` es prerequisito obligatorio. Los demás servicios son independientes entre sí.
