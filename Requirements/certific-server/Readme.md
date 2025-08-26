# Certificate Server Generator

![SSL](https://img.shields.io/badge/SSL_Certificates-Multiple_Methods-28a745?style=for-the-badge)
![Ansible](https://img.shields.io/badge/Ansible-Automated-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![OpenSSL](https://img.shields.io/badge/OpenSSL-Manual-721412?style=for-the-badge&logo=openssl&logoColor=white)

Generación de certificados SSL para Gitea, Harbor y dominios wildcard usando dos métodos diferentes.

## Métodos Disponibles

### 1. Automatizado con Ansible

**Ubicación**: [`ansible-ssl/`](./ansible-ssl/)

**Características**:
- Automatización completa con Ansible
- Usa contenedores Docker con mkcert
- Configuración mediante playbooks
- Ideal para múltiples hosts

**Cuando usar**:
- Tienes múltiples servidores
- Quieres automatización repetible
- Prefieres gestión de configuración

### 2. Manual con OpenSSL

**Ubicación**: [`open-ssl/`](./open-ssl/)

**Características**:
- Comandos directos de OpenSSL
- Control total del proceso
- No requiere Docker ni Ansible
- Comandos copy-paste simples

**Cuando usar**:
- Un solo servidor o pocos
- Prefieres control manual
- Entorno sin Docker/Ansible

## Comparación Rápida

| Aspecto | Ansible (ansible-ssl/) | OpenSSL (open-ssl/) |
|---------|------------------------|---------------------|
| **Automatización** | Alta | Manual |
| **Requisitos** | Ansible + Docker | Solo OpenSSL |
| **Configuración** | Playbook YAML | Comandos directos |
| **Escalabilidad** | Múltiples hosts | Single host |
| **Aprendizaje** | Requiere Ansible | Conocimientos básicos |

## Certificados Generados

Ambos métodos generan los mismos certificados:

- **CA Root**: Certificate Authority compartida
- **Gitea**: `gitea.server.local` + IPs locales
- **Harbor**: `registry.harbor.local`, `harbor.server.local` + IPs
- **Wildcard**: `*.local` para múltiples servicios

## Elección Recomendada

- **Principiante o prueba rápida**: Usar [`open-ssl/`](./open-ssl/)
- **Producción o múltiples hosts**: Usar [`ansible-ssl/`](./ansible-ssl/)

## Dominios Soportados

- `gitea.server.local`, `registry.harbor.local`, `harbor.server.local`
- `*.local` (wildcard para cualquier subdominio)
- `localhost`, `127.0.0.1` y direcciones IP específicas
