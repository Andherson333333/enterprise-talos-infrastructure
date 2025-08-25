# Preparación de Imágenes ISO 

![Proxmox](https://img.shields.io/badge/Proxmox-VE-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-12+-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Virtualization](https://img.shields.io/badge/Virtualization-Lab-4B8BBE?style=for-the-badge)
![Checksums](https://img.shields.io/badge/SHA256-Verified-success?style=for-the-badge&logo=gnu-privacy-guard&logoColor=white)

Guía para descargar y verificar imágenes ISO necesarias para un entorno de virtualización con Proxmox y Debian.

## Componentes

- **Proxmox VE**: Hipervisor de código abierto para bare-metal
- **Debian GNU/Linux**: Sistema operativo base para plantillas VM

## Verificación de Integridad

**Importante**: Siempre verificar checksums para garantizar seguridad e integridad.

## 1. Proxmox Virtual Environment

### Descargar

```bash
# Crear directorio de trabajo
mkdir -p ~/iso-images && cd ~/iso-images

# Descargar ISO (reemplazar con versión actual)
wget https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso

# Descargar archivo de checksums
wget https://enterprise.proxmox.com/iso/sha256sum.txt
```

### Verificar

```bash
sha256sum -c sha256sum.txt --ignore-missing
```

**Resultado esperado**: `proxmox-ve_8.2-1.iso: OK`

## 2. Debian GNU/Linux (DVD Completo)

Imagen completa de instalación que incluye paquetes de software comunes para instalación offline.

### Descargar

```bash
# Descargar ISO completa DVD-1 (reemplazar con versión actual)
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.5.0-amd64-dvd-1.iso

# Descargar archivo de checksums
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/SHA256SUMS
```

### Verificar

```bash
# Filtrar y verificar solo el DVD-1
grep "dvd-1.iso" SHA256SUMS | sha256sum --check
```

**Resultado esperado**: `debian-12.5.0-amd64-dvd-1.iso: OK`

## Enlaces de Referencia

- [Proxmox Downloads](https://www.proxmox.com/en/downloads)
- [Debian DVD Images](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/)

## Resultado

Con estos archivos verificados tendrás:
- Instalador de Proxmox VE para servidor físico
- Instalador completo de Debian para plantillas VM
