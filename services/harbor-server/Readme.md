# Harbor Enterprise Suite

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Harbor](https://img.shields.io/badge/Harbor-2.13.1-326CE5?style=for-the-badge&logo=harbor&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-Security-FF6B6B?style=for-the-badge&logo=trivy&logoColor=white)
![SBOM](https://img.shields.io/badge/SBOM-Enabled-4CAF50?style=for-the-badge)
![Air-Gapped](https://img.shields.io/badge/Air_Gapped-Ready-FF6B35?style=for-the-badge)

Suite completa de automatización para desplegar y gestionar infraestructura Harbor empresarial con proxy cache, escaneo de seguridad y generación de SBOM.

## Tabla de Contenidos

- [Inicio Rápido](#inicio-rápido)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Arquitectura y Modos de Operación](#arquitectura-y-modos-de-operación)
- [Proceso Completo de Implementación](#proceso-completo-de-implementación)
- [Documentación Específica](#documentación-específica)

## Inicio Rápido

**¿Nuevo en Harbor Enterprise Suite?** Sigue este flujo:

1. **Lee esta introducción** (estás aquí)
2. **Instala Harbor** → Ve a [`harbor-install/README.md`](./harbor-install/README.md)
3. **Aprende a usarlo** → Ve a [`harbor-use/README.md`](./harbor-use/README.md)

## Estructura del Proyecto

```
harbor-enterprise-suite/
├── README.md                    # Guía principal (estás aquí)
├── harbor-install/              # Módulo de Instalación
│   ├── README.md                #    Guía completa de instalación
│   ├── files/                   #    Archivos de Harbor y certificados
│   ├── tasks/main.yml           #    Tareas Ansible
│   └── defaults/main.yml        #    Variables de configuración
└── harbor-use/                  # Módulo de Uso
    ├── README.md                #    Guía completa de uso diario
    └── scripts/                 #    Scripts de administración
```

### Documentación por Módulos

| Módulo | Propósito | Documentación |
|--------|-----------|---------------|
| **Principal** | Introducción y arquitectura | `README.md` (este archivo) |
| **harbor-install** | Instalación automatizada | [`harbor-install/README.md`](./harbor-install/README.md) |
| **harbor-use** | Uso operacional diario | [`harbor-use/README.md`](./harbor-use/README.md) |

## Arquitectura y Modos de Operación

![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Harbor-server.png)

### Modo 1: Acceso a Internet (Proxy Cache)

**Capacidades**:
- Proxy cache activo para 4 registries externos
- Descargas automáticas desde Docker Hub, Quay, Kubernetes y GitHub
- Actualizaciones automáticas de la base de datos Trivy
- Requiere acceso permanente a internet

**Casos de Uso**:
- Entornos de desarrollo con conectividad
- Reducción de ancho de banda y mitigación de límites de tasa
- Aceleración de pulls recurrentes

![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Arquitectura%20general%20-1.png)

### Modo 2: Completamente Air-Gapped (Sin Internet)

**Capacidades**:
- Solo repositorios locales (docker-images, helm-charts)
- Push manual de imágenes previamente descargadas
- Base de datos Trivy offline (requiere actualizaciones manuales)
- Operación completamente interna sin acceso externo

**Casos de Uso**:
- Entornos de producción completamente aislados
- Sectores de alta seguridad (finanzas, gobierno, defensa)
- Requisitos estrictos de cumplimiento sin conectividad externa

![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Arquitectura%20general%20-2.png)

### Modo 3: Híbrido

**Proceso**:
1. Instalación inicial con acceso a internet
2. Configuración de proxy cache y pre-población
3. Desconexión completa de internet
4. Operación exclusivamente local

## Proceso Completo de Implementación

### Fase 1: Preparación de Infraestructura

Ejecutar en orden estos playbooks base:

```bash
ansible-playbook host-network-1ip.yml
ansible-playbook docker-install.yml  
ansible-playbook ansible-proxy.yaml
ansible-playbook certificados.yml
```

### Fase 2: Instalación de Harbor

**Documentación completa**: [`harbor-install/README.md`](./harbor-install/README.md)

```bash
# 1. Ir al módulo de instalación
cd harbor-install/

# 2. Seguir la guía detallada
# Ver: harbor-install/README.md

# 3. Ejecutar instalación
ansible-playbook -i inventory harbor-install.yml
```

### Fase 3: Configuración y Uso Operacional

**Documentación completa**: [`harbor-use/README.md`](./harbor-use/README.md)

```bash
# 1. Verificar instalación
curl -k https://registry.harbor.local/api/v2.0/health

# 2. Seguir guía de uso diario
# Ver: harbor-use/README.md

# 3. Configurar proyectos y proxy cache
# Ver ejemplos completos en harbor-use/README.md
```

## Componentes Principales

### Harbor Registry
Registry privado de contenedores open-source desarrollado por VMware con características empresariales avanzadas.

### Trivy Security Scanner
Escáner de vulnerabilidades open-source que proporciona detección automatizada de CVEs y análisis de dependencias.

### Software Bill of Materials (SBOM)
Inventario detallado de componentes de software con cumplimiento de estándares SPDX y CycloneDX.

## Configuración de Red

### Servicios y Puertos
- **Web UI**: `https://registry.harbor.local` (443)
- **Docker API**: `https://registry.harbor.local/v2/` (443)
- **Notary**: `https://registry.harbor.local:4443`

### Endpoints Proxy Cache
- **Docker Hub**: `registry.harbor.local/proxy-docker/*`
- **Quay.io**: `registry.harbor.local/proxy-quay/*`
- **Kubernetes**: `registry.harbor.local/proxy-k8s/*`
- **GitHub**: `registry.harbor.local/proxy-ghcr/*`

### Configuración de Hosts
```bash
# Agregar a /etc/hosts en todos los nodos
192.168.253.12    registry.harbor.local harbor.local
```

## Documentación Específica

### Instalación Automatizada
**Archivo**: [`harbor-install/README.md`](./harbor-install/README.md)

**Contiene**:
- Preparación e instalación completa
- Configuración de variables
- Estructura de archivos necesarios
- Verificación post-instalación
- Backup y actualización

### Uso Operacional Diario
**Archivo**: [`harbor-use/README.md`](./harbor-use/README.md)

**Contiene**:
- Proxy cache para 4 registries
- Gestión de proyectos y repositorios
- Security scanning con Trivy
- Generación y descarga de SBOM
- Scripts de administración
- Resolución de problemas

## Características Empresariales

### Seguridad
- **Integración Trivy**: Escaneo automático de vulnerabilidades
- **Generación SBOM**: Inventario completo de componentes
- **Bloqueo CVE**: Prevención de despliegue de imágenes vulnerables
- **Certificados Corporativos**: Integración con PKI empresarial

### Rendimiento
- **Proxy Cache**: Cache local para 4 registries principales
- **Bypass de Límites**: Evita limitaciones de Docker Hub
- **Alta Disponibilidad**: Almacenamiento persistente
- **API First**: Integración completa vía REST API

