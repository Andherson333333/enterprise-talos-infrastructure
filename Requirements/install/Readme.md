# Instalador de Herramientas DevOps

![Kubernetes](https://img.shields.io/badge/kubectl-Latest-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Latest-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Latest-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-Ubuntu-A81D33?style=for-the-badge&logo=debian&logoColor=white)

Script automatizado para instalar herramientas esenciales de DevOps y Kubernetes en sistemas Debian/Ubuntu.

## Herramientas Incluidas

- **kubectl**: Cliente de línea de comandos de Kubernetes
- **Terraform**: Herramienta de infraestructura como código
- **Helm**: Gestor de paquetes para Kubernetes

## Instalación

### 1. Ejecutar instalador

```bash
# Dar permisos de ejecución
chmod +x install.sh

# Ejecutar script
./install.sh
```

## Requisitos

- Sistema operativo: Debian/Ubuntu
- Permisos sudo
- Conexión a internet

## Verificación

El script automáticamente verifica las instalaciones mostrando las versiones:

```bash
kubectl version --client
terraform --version
helm version
```

## Compatibilidad

- Debian 11+
- Ubuntu 20.04+
- Arquitectura: amd64
