# Harbor Registry - Guía de Uso

![Harbor](https://img.shields.io/badge/Harbor-Registry-326CE5?style=for-the-badge&logo=harbor&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-Security-FF6B6B?style=for-the-badge&logo=trivy&logoColor=white)
![SBOM](https://img.shields.io/badge/SBOM-Enabled-4CAF50?style=for-the-badge)
![Proxy](https://img.shields.io/badge/Proxy-Cache-FFA726?style=for-the-badge)

Guía de uso diario para Harbor Registry con proxy cache, security scanning y SBOM generation.

## ¿Qué es Harbor, Trivy y SBOM?
###Harbor Registry
Harbor es un registry privado de contenedores open-source desarrollado por VMware. Actúa como un repositorio centralizado para almacenar, gestionar y distribuir imágenes Docker/OCI. Incluye funcionalidades avanzadas como:

Proxy cache para múltiples registries externos
Control de acceso basado en roles (RBAC)
Escaneo de vulnerabilidades integrado
Replicación de imágenes entre registries

### Trivy Security Scanner

Trivy es un scanner de vulnerabilidades de código abierto desarrollado por Aqua Security. Se integra con Harbor para:

Detectar vulnerabilidades conocidas (CVEs) en imágenes de contenedores
Analizar dependencias y bibliotecas dentro de las imágenes
Clasificar vulnerabilidades por severidad (Critical, High, Medium, Low)
Bloquear el despliegue de imágenes con vulnerabilidades críticas

### SBOM (Software Bill of Materials)
SBOM es un inventario detallado de todos los componentes de software que contiene una aplicación o imagen. Incluye:

Lista completa de dependencias y bibliotecas
Versiones exactas de cada componente
Licencias de software utilizadas
Información de vulnerabilidades asociadas
Formatos estándar: SPDX (Linux Foundation) y CycloneDX (OWASP)

## Proxy Registries Disponibles

```
proxy-docker   → registry-1.docker.io     (Docker Hub)
proxy-quay     → quay.io                   (Red Hat Quay)
proxy-k8s      → registry.k8s.io          (Kubernetes)
proxy-ghcr     → ghcr.io                   (GitHub Container Registry)
```

## Estructura de Proyectos (Estado Actual)

```
registry.harbor.local/
├── docker-images/        # (argocd, installer-base)
├── helm-charts/          # (listo para Helm charts)  
├── proxy-docker/         # (Proxy cache Docker Hub)
├── proxy-quay/           # (Proxy cache Quay.io)
├── proxy-k8s/            # (Proxy cache K8s)
└── proxy-ghcr/           # (Proxy cache GitHub)

```

![Proxy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-12.png)


## Uso de Proxy Cache

### Estado de Registries Externos
```bash
# Todos los endpoints configurados están Healthy:
proxy-quay-registry     https://quay.io               
proxy-k8s               https://registry.k8s.io          
proxy-docker            https://registry-1.docker.io   
proxy-ghcr              https://ghcr.io                 
```

![Proxy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-11.png)

### Pull através de Proxy
```bash
# Login al registry
docker login registry.harbor.local -u admin

# Docker Hub através del proxy
docker pull registry.harbor.local/proxy-docker/library/nginx:latest
docker pull registry.harbor.local/proxy-docker/grafana/grafana:latest
docker pull registry.harbor.local/proxy-docker/library/redis:latest

# Kubernetes registry através del proxy  
docker pull registry.harbor.local/proxy-k8s/ingress-nginx/controller:latest
docker pull registry.harbor.local/proxy-k8s/metrics-server/metrics-server:latest

# GitHub Container Registry através del proxy
docker pull registry.harbor.local/proxy-ghcr/fluxcd/source-controller:latest
docker pull registry.harbor.local/proxy-ghcr/dexidp/dex:latest

# Quay.io através del proxy
docker pull registry.harbor.local/proxy-quay/prometheus/prometheus:latest
docker pull registry.harbor.local/proxy-quay/argoproj/argocd:latest
```

![Proxy](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/harbor-server-8.png)

### Beneficios del Proxy Cache
- **Velocidad**: Descarga rápida desde cache local
- **Ahorro de ancho de banda**: Solo descarga una vez desde internet
- **Disponibilidad**: Funciona aunque el registry externo esté down
- **Rate limiting**: Evita límites de Docker Hub y otros registries

## Creación y Gestión de Repositorios

### Crear Proyecto Nuevo
```bash
# Via UI: Projects - New Project
Nombre: mi-proyecto
Acceso: Public/Private
Proxy Cache: No (para proyectos custom)
```

### Push de Imágenes Personalizadas
```bash
# Ejemplos reales de push exitosos:

# 1. Installer-base (Talos Linux)
docker tag ghcr.io/siderolabs/installer-base:v1.10.6 registry.harbor.local/docker-images/installer-base:v1.10.6
docker push registry.harbor.local/docker-images/installer-base:v1.10.6
#  Pushed: digest sha256:c1ee3b599526d680ad0abd6d247bbea9cdbc08d56d6e5de2bc7b00c347b45b92 size: 741

# 2. ArgoCD Custom
docker tag argocd-custom:v3.1.0 registry.harbor.local/docker-images/argocd:v3.1.0-custom  
docker push registry.harbor.local/docker-images/argocd:v3.1.0-custom
#  Pushed: digest sha256:3273af08a0de8de1c0757669d53c169077bf0161e80bb738e00528fa8904a498 size: 3448
```

### Configuración del Proyecto docker-images
```yaml
Registro de proyectos:  Público
Proxy Cache:  Deshabilitado (para imágenes custom)
Seguridad Despliegues:
  - Cosign:  Disponible  
  - Notación:  Disponible
  - Prevenir imágenes vulnerables:  Activado (Severidad: Bajo)
Escaneo de vulnerabilidad:  Automático al push
Generación de SBOM:  Automático al push
CVE allowlist: System allowlist (nivel sistema)
```

### Gestión de Tags
```bash
# Multiple tags para la misma imagen
docker tag mi-app:latest harbor.local/docker-images/mi-app:latest
docker tag mi-app:latest harbor.local/docker-images/mi-app:stable

docker push harbor.local/docker-images/mi-app:latest
docker push harbor.local/docker-images/mi-app:stable
```

## Security Scanning con Trivy (Configurado)

### Configuración Automática Activada
```yaml
Escaneo automático:  Activado al push
Prevenir imágenes vulnerables:  Activado  
Nivel de bloqueo: Bajo y superior
Generación SBOM:  Automática al push
CVE Allowlist: System allowlist (nivel sistema)
```

### Interpretar Resultados de Vulnerabilidades
```yaml
Severity Levels:
  Critical: Requiere acción inmediata - BLOQUEADO
  High: Debe solucionarse pronto - BLOQUEADO
  Medium: Revisar cuando sea posible - BLOQUEADO  
  Low: Informativo - BLOQUEADO (configurado)
  Unknown: Sin información de severidad
```

### Verificar Escaneo en UI
```bash
# Navegar a: Projects - docker-images - Repository - Artifact
# Tabs disponibles:
# - Overview: Información general
# - Security: Vulnerabilidades detectadas  
# - SBOM: Software Bill of Materials generado
# - Build History: Historial de builds
```

## SBOM (Software Bill of Materials) - Auto-Generado

### Configuración Actual
```yaml
Estado:  Habilitado globalmente
Trigger: Automático al push
Formatos: SPDX, CycloneDX  
Storage: Almacenado con cada artifact
```

### Acceder a SBOM Generado
```bash
# Via UI: 
# Projects - docker-images - argocd - Artifacts - SBOM tab

# Para installer-base:v1.10.6
# Projects - docker-images - installer-base - Artifacts - SBOM tab

# Download formats: JSON, XML
```

## Gestión Diaria

### Script de Reinicio Harbor
```bash
#!/bin/bash
HARBOR_PATH="/opt/harbor/harbor"
echo "Reiniciando Harbor..."
cd $HARBOR_PATH
docker compose down
docker compose up -d
docker compose ps
echo "Harbor reiniciado!"
```

### Verificar Estado
```bash
# Estado de contenedores
cd /opt/harbor/harbor && docker compose ps

# Logs en tiempo real
docker compose logs -f harbor-core

# Health check
curl -k https://harbor.local/api/v2.0/health
```

### Security
```bash
# Revisar vulnerabilidades antes de deploy
# Configurar webhooks para notificaciones
# Usar robot accounts para CI/CD
```

### Storage Management
```bash
# Configurar retention policies
# Ejecutar garbage collection regularmente
# Monitorear uso de storage por proyecto
```
