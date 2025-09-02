# Harbor Enterprise Suite

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Harbor](https://img.shields.io/badge/Harbor-2.11.0-326CE5?style=for-the-badge&logo=harbor&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-Security-FF6B6B?style=for-the-badge&logo=trivy&logoColor=white)
![SBOM](https://img.shields.io/badge/SBOM-Enabled-4CAF50?style=for-the-badge)
![Air-Gapped](https://img.shields.io/badge/Air_Gapped-Ready-FF6B35?style=for-the-badge)

Suite completa de automatización para desplegar y gestionar infraestructura Harbor empresarial con proxy cache, escaneo de seguridad y generación de SBOM. Incluye instalación automatizada y guía de uso operacional.

## Modos de Operación

### Modo 1: Acceso a Internet (proxy)

**Capacidades**:
- Proxy cache activo para 4 registries externos
- Descargas automáticas desde Docker Hub, Quay, Kubernetes y GitHub
- Actualizaciones automáticas de la base de datos Trivy
- Requiere acceso permanente a internet

**Casos de Uso**:
- Entornos de desarrollo con conectividad a internet
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

## Arquitectura 

![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Harbor-server.png)


## Descripción General

Harbor Enterprise Suite proporciona una solución integral para la gestión de registries privados de contenedores con características avanzadas de seguridad. La suite incluye procedimientos de instalación automatizados y pautas operacionales para gestión de contenedores de nivel empresarial.

### Características Principales

- **Harbor 2.11.0** - Registry privado de contenedores de nivel empresarial
- **Integración Trivy** - Escaneo automatizado de vulnerabilidades
- **Generación SBOM** - Cumplimiento de Software Bill of Materials
- **Proxy Cache** - Soporte para múltiples registries externos
- **Operaciones Air-Gapped** - Funcionalidad completa offline
- **Seguridad Empresarial** - SSL/TLS con certificados corporativos

## Arquitectura

Harbor Enterprise Suite sigue una arquitectura distribuida diseñada para escalabilidad empresarial y requisitos de seguridad.

## Componentes Principales

### Harbor Registry

Harbor es un registry privado de contenedores open-source desarrollado por VMware. Sirve como repositorio centralizado para almacenar, gestionar y distribuir imágenes Docker/OCI con características empresariales avanzadas:

- Soporte de proxy cache para múltiples registries externos (Docker Hub, Quay, Kubernetes, GitHub)
- Control de acceso basado en roles (RBAC)
- Escaneo integrado de vulnerabilidades con Trivy
- Generación automática de SBOM
- Organización multi-proyecto
- Arquitectura API-first

### Trivy Security Scanner

Trivy es un escáner de vulnerabilidades open-source desarrollado por Aqua Security. La integración con Harbor proporciona:

- Detección de vulnerabilidades conocidas (CVEs) en imágenes de contenedores
- Análisis de dependencias y bibliotecas dentro de las imágenes
- Clasificación de vulnerabilidades por severidad (Critical, High, Medium, Low)
- Bloqueo de despliegue de imágenes con vulnerabilidades críticas
- Reportes de seguridad en tiempo real

### Software Bill of Materials (SBOM)

SBOM proporciona un inventario detallado de todos los componentes de software contenidos en una aplicación o imagen:

- Lista completa de dependencias y bibliotecas
- Versiones exactas de cada componente
- Información de licencias de software
- Información de vulnerabilidades asociadas
- Formatos estándar: SPDX (Linux Foundation) y CycloneDX (OWASP)

## Estructura de la Suite

### 1. Módulo Harbor Install

**Ubicación**: `harbor-install/`

Instalación automatizada de Harbor con Trivy y configuraciones empresariales.

**Características**:
- Despliegue Harbor 2.11.0 con Docker Compose
- Escáner Trivy integrado para evaluación de vulnerabilidades
- Configuración de proxy cache para 4 registries externos
- Configuración SSL/TLS con certificados corporativos
- Habilitación de generación automática de SBOM

**Resultado**: Instalación completa de Harbor en `https://registry.harbor.local`

### 2. Módulo Harbor Use

**Ubicación**: `harbor-use/`

Guía operacional integral para uso diario de Harbor.

**Características**:
- Operaciones de proxy cache (Docker Hub, Quay, Kubernetes, GitHub)
- Gestión de repositorios y proyectos
- Interpretación de escaneos de seguridad
- Procedimientos de generación y descarga de SBOM
- Scripts de administración y guías de resolución de problemas

## Proceso de Despliegue

### Prerequisitos

Ejecutar los siguientes playbooks en orden para preparar la infraestructura base:

```bash
ansible-playbook host-network-1ip.yml
ansible-playbook docker-install.yml  
ansible-playbook ansible-proxy.yaml
ansible-playbook certificados.yml
```

### Instalación de Harbor

```bash
# 1. Desplegar Harbor con integración Trivy
cd harbor-install/
ansible-playbook -i inventory harbor-install.yml

# 2. Verificar instalación
curl -k https://registry.harbor.local/api/v2.0/health

# 3. Seguir guía operacional
# Referencia harbor-use/README.md para operaciones diarias
```

## Configuración de Red

### Servicios y Puertos

**Harbor Registry**:
- Web UI: `https://registry.harbor.local` (443)
- Docker API: `https://registry.harbor.local/v2/` (443)
- Notary: `https://registry.harbor.local:4443`

**Endpoints Proxy Cache**:
- Docker Hub: `registry.harbor.local/proxy-docker/*`
- Quay.io: `registry.harbor.local/proxy-quay/*`
- Kubernetes: `registry.harbor.local/proxy-k8s/*`
- GitHub: `registry.harbor.local/proxy-ghcr/*`

### Configuración de Hosts

Agregar las siguientes entradas a `/etc/hosts` en todos los nodos:

```
192.168.253.12    registry.harbor.local harbor.local
```

## Características Empresariales

### Seguridad

- **Integración Trivy**: Escaneo automático de vulnerabilidades en cada push de imagen
- **Generación SBOM**: Inventario completo de componentes para requisitos de cumplimiento
- **Bloqueo CVE**: Prevención de despliegue de imágenes vulnerables
- **Gestión de Certificados**: Integración con infraestructura PKI corporativa
- **Soporte Air-Gapped**: Operación completa sin conectividad a internet

### Rendimiento y Disponibilidad

- **Proxy Cache**: Cache local para 4 registries principales
- **Bypass de Límites de Tasa**: Evita limitaciones de Docker Hub y otros registries
- **Alta Disponibilidad**: Almacenamiento persistente y verificaciones integrales de salud
- **Distribución de Carga**: Integración con capa de balanceador de carga

### Integración DevOps

- **API First**: Integración completa vía REST API
- **Soporte Webhook**: Notificaciones automáticas de resultados de escaneo
- **Multi-Proyecto**: Organización por equipos y aplicaciones
- **Replicación de Registry**: Sincronización entre instancias Harbor

### Modo 3: Híbrido (Configuración Inicial → Air-Gapped)

**Proceso**:
1. Instalación inicial con acceso a internet para descarga de imágenes base
2. Configuración de proxy cache y pre-población de repositorios
3. Desconexión completa de internet
4. Operación exclusivamente con cache local y repositorios manuales

**Casos de Uso**:
- Migración gradual a entornos air-gapped
- Escenarios con conectividad intermitente
- Instalación inicial eficiente con operación posterior segura

## Soporte y Documentación

Para procedimientos operacionales detallados, guías de resolución de problemas y opciones de configuración avanzadas, consulte la documentación respectiva de cada módulo:

- Procedimientos de instalación: `harbor-install/README.md`
- Pautas operacionales: `harbor-use/README.md`
- Resolución de problemas: `harbor-use/troubleshooting.md`

## Requisitos

- Docker y Docker Compose
- Plataforma de automatización Ansible
- Infraestructura de certificados corporativos
- Conectividad de red (varía según el modo de operación)
- Almacenamiento suficiente para cache de imágenes y repositorios
