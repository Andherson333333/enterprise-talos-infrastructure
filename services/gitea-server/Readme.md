# Gitea Enterprise Suite
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-1.24.2-609926?style=for-the-badge&logo=gitea&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-Proxy-00ADD8?style=for-the-badge&logo=traefik&logoColor=white)
![Air-Gapped](https://img.shields.io/badge/Air_Gapped-Ready-FF6B35?style=for-the-badge)

Suite completa de automatización para desplegar y gestionar infraestructura Gitea empresarial con soporte para entornos air-gapped. Incluye servidor, runners y actions locales.

## Arquitectura General
![Architecture](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner.png)

## Componentes de la Suite

### 1. Gitea Install ([gitea-install-ansible/](./gitea-install-ansible/))
**Servidor Gitea con proxy reverso y certificados TLS**

```
Funciones:
- Servidor Gitea 1.24.2 con Docker Compose
- Proxy reverso Traefik con SSL/TLS
- Integración con Harbor Registry
- Configuración automática para Actions

Resultado: https://gitea.server.local (con certificados TLS)
```

### 2. Gitea Runners ([gitea-runners-ansible/](./gitea-runners-ansible/))  
**Runners para CI/CD con soporte Docker-in-Docker**

```
Funciones:
- Despliegue automatizado de runners
- Configuración Docker-in-Docker
- Conectividad con registry Harbor
- SSL strict y certificados corporativos

Resultado: Runners registrados y listos para pipelines
```

### 3. Gitea Actions ([gitea-actions-ansible/](./gitea-actions-ansible/))
**GitHub Actions para entornos air-gapped**

```
Funciones:
- Pre-descarga de 25+ GitHub Actions
- Despliegue como repositorios locales
- Soporte completo air-gapped
- Organización automática en Gitea

Resultado: Actions locales en https://192.168.253.11/actions/
```

## Flujo de Despliegue Completo

### Infraestructura Base (Prerequisitos)
```bash
# Ejecutar en orden (prerequisitos para toda la suite):
ansible-playbook host-network-1ip.yml
ansible-playbook docker-install.yml  
ansible-playbook ansible-proxy.yaml
ansible-playbook certificados.yml
```

### Despliegue de la Suite Gitea
```bash
# 1. Instalar servidor Gitea
cd gitea-install-ansible/
ansible-playbook -i inventory gitea-install.yml

# 2. Configurar runners  
cd ../gitea-runners-ansible/
ansible-playbook -i inventory gitea-runner.yml

# 3. Desplegar actions (air-gapped)
cd ../gitea-actions-ansible/
./git.sh  # Ejecutar desde servidor con internet
scp /tmp/github-actions-airgap-full-repos.tar.gz root@192.168.253.11:/opt/
ansible-playbook -i inventory gitea-actions.yml
```

## Configuración de Red

### Servicios y Puertos
```
Gitea Server:
- Web: https://gitea.server.local (443)
- SSH: git@gitea.server.local:2222
- API: https://gitea.server.local/api/v1/

Harbor Registry:  
- Registry: registry.harbor.local (443)
- Web: https://harbor.local (443)

Traefik:
- Dashboard: http://gitea.server.local:8080
```

### Hosts Configuration
```bash
# Agregar a /etc/hosts en todos los nodos:
192.168.253.11    gitea.server.local
192.168.253.12    registry.harbor.local harbor.local
```

## Ejemplo de Pipeline Completo

### Pipeline CI/CD usando Actions Locales
```yaml
# .gitea/workflows/ci.yml
name: Enterprise CI Pipeline
on: [push]

jobs:
  build:
    runs-on: gitea-runner-docker
    steps:
      # Usar actions locales (air-gapped)
      - uses: https://192.168.253.11/actions/checkout@v4
      
      - uses: https://192.168.253.11/actions/setup-node@v4
        with:
          node-version: '18'
          
      # Build con registry Harbor
      - uses: https://192.168.253.11/actions/docker-build-push-action@v6
        with:
          push: true
          tags: registry.harbor.local/project/app:${{ github.sha }}
          
      - uses: https://192.168.253.11/actions/upload-artifact@v4
        with:
          name: build-artifacts  
          path: dist/
```

## Características Empresariales

### Seguridad
- **Certificados TLS**: Integración completa con PKI corporativo
- **Air-Gapped Support**: Operación sin internet después del setup
- **Registry Privado**: Imágenes Docker desde Harbor local
- **SSH Security**: Operaciones Git via SSH en puerto dedicado

### Alta Disponibilidad  
- **Health Checks**: Monitoreo automatizado de servicios
- **Persistent Storage**: Volúmenes Docker persistentes
- **Auto Recovery**: Restart policies en contenedores
- **Load Balancing**: Traefik como proxy reverso

### DevOps Integration
- **Docker-in-Docker**: Soporte completo para pipelines containerizadas  
- **25+ Actions**: Biblioteca completa de GitHub Actions locales
- **API First**: Integración via API REST de Gitea
- **Webhook Support**: Integración con sistemas externos

## Estructura del Repositorio
```
gitea-server/
├── gitea-install-ansible/     # Servidor Gitea + Traefik
│   ├── files/
│   │   ├── docker-compose.yml
│   │   ├── tls.yml  
│   │   └── certificados/
│   └── tasks/main.yml
├── gitea-runners-ansible/     # Runners CI/CD
│   ├── files/
│   │   ├── docker-compose.yml
│   │   └── config.yaml
│   └── tasks/main.yml  
└── gitea-actions-ansible/     # Actions Air-Gapped
    ├── files/
    │   └── github-actions-airgap-full-repos.tar.gz
    ├── tasks/
    │   ├── main.yml
    │   └── push.yml
    └── vars/main.yml
```

