# Docker Install Ansible Role

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Install-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Offline](https://img.shields.io/badge/Offline-Ready-4CAF50?style=for-the-badge)

Instalación offline de Docker mediante archivos .deb preconfigurados usando Ansible playbook.

## ¿Qué hace?

Instala Docker y componentes desde archivos .deb locales mediante playbook de Ansible. No requiere acceso a internet ni repositorios APT.

### Componentes incluidos

- containerd.io (1.7.27)
- docker-ce (28.3.2) 
- docker-ce-cli (28.3.2)
- docker-buildx-plugin (0.25.0)
- docker-compose-plugin (2.38.2)

## Uso

```bash
# Ejecutar instalación
ansible-playbook -i inventory docker-install.yml
```

## Estructura

```
docker-install/
├── files/                           # Archivos .deb
│   ├── containerd.io_1.7.27-1_amd64.deb
│   ├── docker-ce_5%3a28.3.2-1~debian.12~bookworm_amd64.deb
│   ├── docker-ce-cli_5%3a28.3.2-1~debian.12~bookworm_amd64.deb
│   ├── docker-buildx-plugin_0.25.0-1~debian.12~bookworm_amd64.deb
│   └── docker-compose-plugin_2.38.2-1~debian.12~bookworm_amd64.deb
└── tasks/main.yml                   # Tareas de instalación
```

## Verificación

```bash
# Comprobar instalación
ansible all -i inventory -m shell -a "docker --version"
ansible all -i inventory -m shell -a "docker compose --version"

# Verificar servicio
ansible all -i inventory -m shell -a "systemctl status docker"
```

## Actualización

Para actualizar Docker:
1. Reemplazar archivos .deb en `files/`
2. Actualizar nombres en `defaults/main.yml` 
3. Ejecutar playbook nuevamente
