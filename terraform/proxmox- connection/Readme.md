# Terraform Proxmox Connection
![Terraform](https://img.shields.io/badge/Terraform-Latest-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Required-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker_Compose-2.39+-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## Parte del proyecto: Enterprise Infrastructure

Este módulo maneja la **conexión base** entre Terraform y Proxmox VE vía Docker para el despliegue automatizado de infraestructura.


## Arquitectura 


## Características

- **Imagen Airgap**: `andherson1039/terraform-complete-airgap:2.0` con todos los providers incluidos
- **Conexión API**: Configuración de token y endpoint para Proxmox VE
- **Variables Flexibles**: Control de nodos, cluster y configuraciones vía `.env`
- **Escalamiento**: Agregar/quitar VMs modificando variables

## Estructura del Módulo

```
terraform/
├── docker-compose.yml          # Configuración de servicios Docker
├── .env                        # Variables de entorno para conexión
├── provider.tf                 # Providers y versiones requeridas
├── variables.tf                # Definición de variables
├── main.tf                     # Configuración principal VMs
├── outputs.tf                  # Outputs de Terraform
└── Readme.md                   # Esta guía
```

## Requisitos

- Docker Engine 20.10+
- Docker Compose v2.39+
- Proxmox VE 7.0+ con API habilitada
- Token de API de Proxmox configurado (ver `requirements/proxmox-api-token/`)
- Red accesible entre Docker host y Proxmox

## Configuración

### 1. Configurar variables de entorno

Crea el archivo `.env` con tu configuración de Proxmox:

```bash
# Variables TF_VAR_* que siempre funcionan en Docker
TF_VAR_proxmox_endpoint=https://192.168.1.100:8006
TF_VAR_proxmox_api_token=terraform@pam!terraform=1160238f-41a8-49a8-99f3-3e5692324cca
TF_VAR_proxmox_insecure=true
TF_VAR_node_name=pve-1
```

### 2. Verificar imagen Docker

```bash
# Verificar que la imagen esté disponible
docker pull andherson1039/terraform-complete-airgap:2.0
```

## Verificar Conexión

### Probar conectividad a Proxmox

```bash
# Probar que Proxmox API responde
curl -k https://192.168.1.100:8006/api2/extjs/access/domains

# Probar conexión desde el contenedor
docker compose run --rm terraform bash -c "curl -k \$TF_VAR_proxmox_endpoint/api2/extjs/version"
```

### Validar configuración de Terraform

```bash
# Inicializar y validar configuración
docker compose run --rm terraform init
docker compose run --rm terraform validate
```

## Uso

### Inicializar Terraform

```bash
# Levantar el contenedor y inicializar
docker compose run --rm terraform init
```

### Planificar despliegue

```bash
# Ver cambios propuestos
docker compose run --rm terraform plan
```

### Aplicar infraestructura

```bash
# Aplicar cambios
docker compose run --rm terraform apply
```

### Escalar cluster

```bash
# Modificar variables en .env o usar override
TF_VAR_control_plane_count=3 TF_VAR_worker_count=2 docker compose run --rm terraform apply
```

### Destruir recursos

```bash
# Eliminar toda la infraestructura
docker compose run --rm terraform destroy
```

## Variables de Entorno

| Variable | Descripción | Ejemplo | Default |
|----------|-------------|---------|---------|
| `TF_VAR_proxmox_endpoint` | URL del API de Proxmox | `https://192.168.1.100:8006` | - |
| `TF_VAR_proxmox_api_token` | Token de API de Proxmox | `terraform@pam!terraform=1160238f...` | - |
| `TF_VAR_proxmox_insecure` | Permitir certificados SSL no válidos | `true` o `false` | `true` |
| `TF_VAR_node_name` | Nombre del nodo Proxmox destino | `pve-1` | `pve-1` |
| `TF_VAR_cluster_name` | Nombre del cluster a desplegar | `talos-infrastructure` | `talos-infrastructure` |
| `TF_VAR_control_plane_count` | Número de nodos control plane | `1`, `3`, `5` | `1` |
| `TF_VAR_worker_count` | Número de nodos worker | `0`, `2`, `5` | `0` |

## Providers Incluidos

- **proxmox** (bpg/proxmox ~> 0.80.0) - Gestión de VMs en Proxmox
- **talos** (siderolabs/talos ~> 0.8.0) - Configuraciones de Talos Linux
- **local, http, random, null, time** - Providers auxiliares

## Troubleshooting

### Error de conexión

```bash
# Verificar conectividad básica
ping 192.168.1.100

# Probar API manualmente
curl -k https://192.168.1.100:8006/api2/extjs/version
```

### Token inválido

```bash
# Verificar que el token existe en Proxmox
# Datacenter → API Tokens → verificar terraform@pam!terraform
```

### Limpiar estado

```bash
# Limpiar estado de Terraform
docker compose run --rm terraform bash -c "rm -rf .terraform .terraform.lock.hcl"
docker compose run --rm terraform init
