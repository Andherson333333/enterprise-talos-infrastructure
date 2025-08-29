# Gitea Runner Ansible Deployment
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-Runner-609926?style=for-the-badge&logo=gitea&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-Infrastructure-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Harbor](https://img.shields.io/badge/Harbor-Registry-60B932?style=for-the-badge&logo=harbor&logoColor=white)

Despliegue automatizado de Gitea Runner con Ansible en infraestructura Proxmox multi-capa con registro Harbor privado.

## Arquitectura
![Architecture](URL_DE_TU_IMAGEN_AQUI)

## Flujo de Trabajo
```
DESPLIEGUE: Ansible Role → Docker Compose → Gitea Runner Container
CONEXIÓN: Runner → Gitea Server (gitea.server.local:192.168.253.11)
REGISTRO: Harbor Registry (registry.harbor.local:192.168.253.12)
EJECUCIÓN: Runner → Docker in Docker → CI/CD Pipeline
```

## Características
- **Auto-registro**: Configuración automática con token de registro
- **Docker-in-Docker**: Soporte completo para pipelines de contenedores  
- **Registry privado**: Integración con Harbor registry local
- **SSL Strict**: Verificación estricta de certificados SSL/TLS ✅
- **Force Pull**: Actualización automática de imágenes en cada ejecución
- **CA Certificates**: Soporte completo para certificados corporativos
- **Ansible Ready**: Despliegue completamente automatizado
- **Persistent Data**: Volúmenes Docker persistentes
- **Custom Hosts**: Resolución DNS personalizada para servicios internos

## Requisitos
- Servidor con Docker y Docker Compose
- Acceso a Gitea Server (192.168.253.11)
- Acceso a Harbor Registry (192.168.253.12)
- Ansible 2.9+ en máquina de control
- Token de registro de Gitea

## Estructura del Proyecto
```
gitea-runner/
├── defaults/main.yml           # Variables por defecto
├── files/
│   ├── config.yaml            # Configuración del runner
│   └── docker-compose.yml     # Definición de servicios
├── handlers/main.yml          # Handlers de Ansible
├── tasks/main.yml            # Tareas principales
├── vars/main.yml             # Variables específicas
└── gitea-runner.yml          # Playbook principal
```

## Configuración

### Variables Principales (defaults/main.yml)
```yaml
# Gitea Configuration
gitea_instance_url: "https://gitea.server.local"
gitea_runner_token: "huYiXQ41nzCZkTCKV3SkHK5V4Arltok6tawLRsNN"
gitea_runner_name: "gitea-runner-docker"

# Harbor Registry
harbor_registry_url: "registry.harbor.local"

# Network Configuration
gitea_server_ip: "192.168.253.11"
harbor_registry_ip: "192.168.253.12"
```

### Docker Compose Services
```yaml
services:
  gitea-runner:
    image: registry.harbor.local/proxy-docker/gitea/act_runner:latest
    container_name: gitea-runner
    restart: always
    environment:
      - CONFIG_FILE=/config.yaml
      - GITEA_INSTANCE_URL=https://gitea.server.local
      - GITEA_RUNNER_REGISTRATION_TOKEN={{ gitea_runner_token }}
      - GITEA_RUNNER_NAME={{ gitea_runner_name }}
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - ./config.yaml:/config.yaml:ro
      - gitea-runner-data:/data
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
```

## Despliegue

### Método Rápido
```bash
# Ejecutar playbook completo
ansible-playbook -i inventory gitea-runner.yml
```

### Método Paso a Paso
#### 1. Preparar inventario
```bash
# Crear inventory con hosts objetivo
cat > inventory << EOF
[gitea_runners]
runner-01 ansible_host=192.168.1.100
runner-02 ansible_host=192.168.1.101
EOF
```

#### 2. Configurar variables

Sustituir el token de su gitea en el compose 

```bash
# Editar variables en defaults/main.yml
docker-compose.yaml
```

![Proxmox](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner-7.png)

#### 3. Ejecutar despliegue
```bash
# Despliegue con tags específicos
ansible-playbook -i inventory gitea-runner.yml --tags "docker,runner"

# Despliegue completo con verbose
ansible-playbook -i inventory gitea-runner.yml -v
```

![Proxmox](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner-9.png)

#### 4. Verificar servicios
```bash
# Check runner status
ansible all -i inventory -m shell -a "docker ps | grep gitea-runner"

# Check logs
ansible all -i inventory -m shell -a "docker logs gitea-runner"
```

## Configuración del Runner

### Config.yaml Completo
```yaml
---
log:
  level: info
runner:
  file: .runner
  capacity: 1
  timeout: 3h
  shutdown_timeout: 0s
  insecure: false
  fetch_timeout: 5s
  fetch_interval: 2s
cache:
  enabled: true
  dir: ""
  host: ""
  port: 0
container:
  options: >-
    --add-host=gitea.server.local:192.168.253.11
    --add-host=registry.harbor.local:192.168.253.12
    -v /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    -e NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
    -e GIT_SSL_NO_VERIFY=false
  valid_volumes:
    - "/etc/ssl/certs/ca-certificates.crt"
  network: ""
  privileged: false
  force_pull: true
  force_rebuild: false
host:
  workdir_parent: /tmp/act_runner
```

### Configuraciones Avanzadas

#### SSL y Certificados
```yaml
container:
  options: >-
    -v /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    -e NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
    -e GIT_SSL_NO_VERIFY=false
  valid_volumes:
    - "/etc/ssl/certs/ca-certificates.crt"
```

#### Hosts personalizados
```bash
# El runner incluye automáticamente:
gitea.server.local:192.168.253.11       # Servidor Gitea
registry.harbor.local:192.168.253.12    # Registry Harbor
```


## Verificación

```bash
# Verificar contenedor
docker ps | grep gitea-runner
docker logs gitea-runner

# Verificar registro en Gitea
curl -k https://gitea.server.local/api/v1/admin/runners

# Verificar conectividad Harbor
docker pull registry.harbor.local/proxy-docker/hello-world

# Test pipeline básico
git push origin main  # Trigger pipeline
```

![Proxmox](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner-8.png)

