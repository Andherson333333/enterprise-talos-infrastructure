# Requirements - Guía de Despliegue

![Infrastructure](https://img.shields.io/badge/Infrastructure-Setup-4B8BBE?style=for-the-badge)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Ready-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![SSL](https://img.shields.io/badge/SSL_Certificates-Generated-28a745?style=for-the-badge)

Guía paso a paso para preparar todos los requisitos necesarios antes del despliegue de infraestructura.

## Orden de Despliegue

### 1. Preparar Imágenes Base
**Carpeta**: [`iso/`](./iso/)

Descargar y verificar imágenes ISO para instalación base:
- Proxmox VE (hipervisor)
- Debian GNU/Linux (template VMs)

```bash
cd iso/
# Seguir README.md para descargar ISOs verificadas
```

### 2. Instalar Herramientas de Trabajo
**Carpeta**: [`install/`](./install/)

Instalar stack de herramientas DevOps en tu máquina de trabajo:
- kubectl, Terraform, Ansible, Helm

```bash
cd install/
chmod +x install.sh
./install.sh
```

### 3. Preparar Terraform Air-gapped
**Carpeta**: [`terraform-images/`](./terraform-images/)

Crear bundle offline de Terraform con providers y módulos:
- Providers: BPG, Telmate, Talos
- Módulos populares pre-descargados
- Imagen Docker portable

```bash
cd terraform-images/
# Seguir proceso de 2 fases (online → offline)
```

### 4. Configurar API de Proxmox
**Carpeta**: [`proxmox-api-token/`](./proxmox-api-token/)

Crear usuario y token API para automatización con Terraform:
- Usuario `terraform@pam`
- Rol con permisos completos
- Token API para provider BPG

```bash
# Ejecutar comandos desde README.md
```

### 5. Generar Certificados SSL
**Carpeta**: [`certificate-server-config/`](./certificate-server-config/)

Crear certificados SSL para servicios (elegir un método):
- **Automatizado**: Ansible + mkcert containers
- **Manual**: Comandos directos OpenSSL

```bash
cd certific-server/
# Elegir: ansible-ssl/ o open-ssl/
```

### 6. Crear template debian 12
**Carpeta**: [`templates-debian12/`](./templates-debian12/)

Crear Template para debian12 
- **Storage**: Docker sdb para guardar la data
- **Automatizado**: sdb automatico en funcion al tamaño

## Estado de Preparación

Al completar todos los pasos tendrás:

-  **Proxmox VE** instalado y funcionando
-  **Herramientas DevOps** en máquina de trabajo
-  **Bundle Terraform** listo para entornos air-gapped
-  **API Token** configurado para Terraform
-  **Certificados SSL** para todos los servicios
-  **Template debia12** templates para vm

## Siguiente Paso

Una vez completados estos requisitos, dirigirse a:
- **`../terraform/`** - Implementación y despliegues
- **`../services/`** - Configuración de aplicaciones

## Dependencias

Cada paso puede tener dependencias del anterior:
- **Paso 3** requiere herramientas instaladas (Paso 2)
- **Paso 4** requiere Proxmox funcionando (Paso 1) y bundle Terraform (Paso 3)
- **Paso 5** (certificados SSL) pueden ejecutarse independientemente
