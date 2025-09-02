# Harbor Enterprise Suite

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Harbor](https://img.shields.io/badge/Harbor-2.11.0-326CE5?style=for-the-badge&logo=harbor&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-Security-FF6B6B?style=for-the-badge&logo=trivy&logoColor=white)
![SBOM](https://img.shields.io/badge/SBOM-Enabled-4CAF50?style=for-the-badge)
![Air-Gapped](https://img.shields.io/badge/Air_Gapped-Ready-FF6B35?style=for-the-badge)

Complete automation suite for deploying and managing enterprise Harbor infrastructure with proxy cache, security scanning, and SBOM generation. Includes automated installation and operational usage guide.

## Operation Modes

### Modo 1: Acceso a Internet (proxy)

**Capabilities**:
- Proxy cache activo para 4 registries externos
- Descargas automáticas desde Docker Hub, Quay, Kubernetes y GitHub
- Actualizaciones automáticas de la base de datos Trivy
- Requiere acceso permanente a internet

**Use Cases**:
- Entornos de desarrollo con conectividad a internet
- Reducción de ancho de banda y mitigación de límites de tasa
- Aceleración de pulls recurrentes


![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Arquitectura%20general%20-1.png)


### Mode 2: Completamente Air-Gapped (Sin Internet)

**Capabilities**:
- Solo repositorios locales (docker-images, helm-charts)
- Push manual de imágenes previamente descargadas
- Base de datos Trivy offline (requiere actualizaciones manuales)
- Operación completamente interna sin acceso externo

**Use Cases**:
- Entornos de producción completamente aislados
- Sectores de alta seguridad (finanzas, gobierno, defensa)
- Requisitos estrictos de cumplimiento sin conectividad externa

![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Arquitectura%20general%20-2.png)

## Arquictectura 

![Air-Gapped](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/Harbor-server.png)


## Overview

Harbor Enterprise Suite provides a comprehensive solution for private container registry management with advanced security features. The suite includes automated installation procedures and operational guidelines for enterprise-grade container management.

### Key Features

- **Harbor 2.11.0** - Enterprise-grade private container registry
- **Trivy Integration** - Automated vulnerability scanning
- **SBOM Generation** - Software Bill of Materials compliance
- **Proxy Cache** - Support for multiple external registries
- **Air-Gapped Operations** - Complete offline functionality
- **Enterprise Security** - SSL/TLS with corporate certificates

## Architecture

The Harbor Enterprise Suite follows a distributed architecture designed for enterprise scalability and security requirements.

## Core Components

### Harbor Registry

Harbor is an open-source private container registry developed by VMware. It serves as a centralized repository for storing, managing, and distributing Docker/OCI images with advanced enterprise features:

- Proxy cache support for multiple external registries (Docker Hub, Quay, Kubernetes, GitHub)
- Role-based access control (RBAC)
- Integrated vulnerability scanning with Trivy
- Automatic SBOM generation
- Multi-project organization
- API-first architecture

### Trivy Security Scanner

Trivy is an open-source vulnerability scanner developed by Aqua Security. Integration with Harbor provides:

- Detection of known vulnerabilities (CVEs) in container images
- Analysis of dependencies and libraries within images
- Vulnerability classification by severity (Critical, High, Medium, Low)
- Blocking deployment of images with critical vulnerabilities
- Real-time security reporting

### Software Bill of Materials (SBOM)

SBOM provides a detailed inventory of all software components contained in an application or image:

- Complete list of dependencies and libraries
- Exact versions of each component
- Software licenses information
- Associated vulnerability information
- Standard formats: SPDX (Linux Foundation) and CycloneDX (OWASP)

## Suite Structure

### 1. Harbor Install Module

**Location**: `harbor-install/`

Automated Harbor installation with Trivy and enterprise configurations.

**Features**:
- Harbor 2.11.0 deployment with Docker Compose
- Integrated Trivy scanner for vulnerability assessment
- Proxy cache configuration for 4 external registries
- SSL/TLS configuration with corporate certificates
- Automatic SBOM generation enablement

**Output**: Complete Harbor installation at `https://registry.harbor.local`

### 2. Harbor Use Module

**Location**: `harbor-use/`

Comprehensive operational guide for daily Harbor usage.

**Features**:
- Proxy cache operations (Docker Hub, Quay, Kubernetes, GitHub)
- Repository and project management
- Security scan interpretation
- SBOM generation and download procedures
- Administration scripts and troubleshooting guides

## Deployment Process

### Prerequisites

Execute the following playbooks in order to prepare the base infrastructure:

```bash
ansible-playbook host-network-1ip.yml
ansible-playbook docker-install.yml  
ansible-playbook ansible-proxy.yaml
ansible-playbook certificados.yml
```

### Harbor Installation

```bash
# 1. Deploy Harbor with Trivy integration
cd harbor-install/
ansible-playbook -i inventory harbor-install.yml

# 2. Verify installation
curl -k https://registry.harbor.local/api/v2.0/health

# 3. Follow operational guide
# Reference harbor-use/README.md for daily operations
```

## Network Configuration

### Services and Ports

**Harbor Registry**:
- Web UI: `https://registry.harbor.local` (443)
- Docker API: `https://registry.harbor.local/v2/` (443)
- Notary: `https://registry.harbor.local:4443`

**Proxy Cache Endpoints**:
- Docker Hub: `registry.harbor.local/proxy-docker/*`
- Quay.io: `registry.harbor.local/proxy-quay/*`
- Kubernetes: `registry.harbor.local/proxy-k8s/*`
- GitHub: `registry.harbor.local/proxy-ghcr/*`

### Host Configuration

Add the following entries to `/etc/hosts` on all nodes:

```
192.168.253.12    registry.harbor.local harbor.local
```

## Enterprise Features

### Security

- **Trivy Integration**: Automatic vulnerability scanning on every image push
- **SBOM Generation**: Complete component inventory for compliance requirements
- **CVE Blocking**: Prevention of vulnerable image deployments
- **Certificate Management**: Integration with corporate PKI infrastructure
- **Air-Gapped Support**: Complete operation without internet connectivity

### Performance and Availability

- **Proxy Cache**: Local caching for 4 major registries
- **Rate Limit Bypass**: Avoids Docker Hub and other registry limitations
- **High Availability**: Persistent storage and comprehensive health checks
- **Load Distribution**: Integration with load balancer layer

### DevOps Integration

- **API First**: Complete integration via REST API
- **Webhook Support**: Automatic scan result notifications
- **Multi-Project**: Organization by teams and applications
- **Registry Replication**: Synchronization between Harbor instances



### Mode 3: Hybrid (Initial Setup → Air-Gapped)

**Process**:
1. Initial installation with internet access for base image downloads
2. Proxy cache configuration and repository pre-population
3. Complete internet disconnection
4. Operation exclusively with local cache and manual repositories

**Use Cases**:
- Gradual migration to air-gapped environments
- Scenarios with intermittent connectivity
- Efficient initial installation with subsequent secure operation

## Support and Documentation

For detailed operational procedures, troubleshooting guides, and advanced configuration options, refer to the respective module documentation:

- Installation procedures: `harbor-install/README.md`
- Operational guidelines: `harbor-use/README.md`
- Troubleshooting: `harbor-use/troubleshooting.md`

## Requirements

- Docker and Docker Compose
- Ansible automation platform
- Corporate certificate infrastructure
- Network connectivity (varies by operation mode)
- Sufficient storage for image caching and repositories
