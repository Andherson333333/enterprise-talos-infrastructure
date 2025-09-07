# Talos ISO Builder

![Talos](https://img.shields.io/badge/Talos-Linux_OS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![ISO](https://img.shields.io/badge/ISO-Builder-FF6B35?style=for-the-badge&logo=linux&logoColor=white)

Herramienta para crear imágenes ISO booteable de Talos Linux con cache offline de imágenes.

## ¿Qué es?

Genera imágenes ISO de Talos Linux con todas las imágenes de Kubernetes y CNI precargadas. Ideal para instalaciones offline en servidores físicos o máquinas virtuales.

### Beneficios Principales

- **Instalación offline**: ISO con todas las imágenes necesarias incluidas
- **Cache optimizado**: Imágenes precargadas para instalación rápida
- **Booteable**: ISO lista para instalar en cualquier hardware
- **CNI incluido**: Flannel preconfigurado por defecto
- **Sin internet**: Funciona completamente offline tras la generación

## Prerequisitos

- Docker instalado
- talosctl CLI
- Acceso privilegiado (/dev mount)
- Espacio en disco (~2GB para ISO)
- Acceso a internet (solo para build inicial)

## Estructura de Archivos

```
~/talos-iso-builder/
├── images.txt              # Lista de imágenes base
├── extra-images.txt        # Imágenes adicionales (opcional)
├── image-cache.oci/        # Cache de imágenes generado
└── _out/                   # Archivos de salida
    └── metal-amd64.iso     # ISO final
```

## Instalación

### 1. Preparar Workspace

```bash
# Crear directorio de trabajo
mkdir ~/talos-iso-builder
cd ~/talos-iso-builder
```

### 2. Extraer Imágenes Base

```bash
# Extraer imágenes default de Talos
talosctl images default > images.txt

# Agregar imágenes extra (opcional)
# echo "registry.k8s.io/my-custom-image:latest" >> images.txt
# cat extra-images.txt >> images.txt
```

### 3. Crear Cache OCI

```bash
# Generar cache de imágenes (requiere internet)
cat images.txt | talosctl images cache-create \
  --image-cache-path ./image-cache.oci \
  --images=-
```

### 4. Generar ISO

```bash
# Crear directorio de salida
mkdir -p _out/

# Generar ISO con cache
docker run --rm -t \
  -v $PWD/_out:/secureboot:ro \
  -v $PWD/_out:/out \
  -v $PWD/image-cache.oci:/image-cache.oci:ro \
  -v /dev:/dev \
  --privileged \
  ghcr.io/siderolabs/imager:v1.10.3 iso \
  --image-cache /image-cache.oci
```

## Configuración

### Variables por Defecto

```yaml
# Versión Talos
talos_version: v1.10.3
imager_version: v1.10.3

# Arquitectura
arch: amd64

# CNI incluido
cni: flannel

# Cache path
image_cache_path: ./image-cache.oci
```

### Contenido de images.txt

```bash
# Ver qué imágenes se incluirán
cat images.txt

# Ejemplo de contenido:
# ghcr.io/siderolabs/flannel:v0.26.7
# registry.k8s.io/coredns/coredns:v1.12.1
# gcr.io/etcd-development/etcd:v3.5.21
# registry.k8s.io/kube-apiserver:v1.33.2
# ghcr.io/siderolabs/installer:v1.10.5
```

## Uso

### Preparar ISO para Instalación

```bash
# Verificar ISO generada
ls -lh _out/metal-amd64.iso

# Transferir a dispositivo USB
dd if=_out/metal-amd64.iso of=/dev/sdX bs=4M status=progress

# Para VMs, montar directamente el archivo ISO
```

### Instalación en Servidor

```bash
# 1. Bootear desde ISO
# 2. Seguir proceso normal de instalación Talos
# 3. Las imágenes se cargan desde cache local (rápido)
```

## Verificación

```bash
# Verificar cache generado
du -sh image-cache.oci/

# Contar imágenes en cache
cat images.txt | wc -l

# Verificar ISO final
file _out/metal-amd64.iso
ls -lh _out/metal-amd64.iso
```

## Administración

```bash
# Regenerar cache (si cambian las imágenes)
rm -rf image-cache.oci/
cat images.txt | talosctl images cache-create --image-cache-path ./image-cache.oci --images=-

# Limpiar archivos de salida
rm -rf _out/

# Ver espacio total usado
du -sh ~/talos-iso-builder/
```

## Comandos Resumidos

```bash
# Build completo en una secuencia
mkdir ~/talos-iso-builder && cd ~/talos-iso-builder

# 1. Extraer imágenes
talosctl images default > images.txt

# 2. Crear cache
cat images.txt | talosctl images cache-create --image-cache-path ./image-cache.oci --images=-

# 3. Generar ISO
mkdir -p _out/
docker run --rm -t -v $PWD/_out:/secureboot:ro -v $PWD/_out:/out -v $PWD/image-cache.oci:/image-cache.oci:ro -v /dev:/dev --privileged ghcr.io/siderolabs/imager:v1.10.3 iso --image-cache /image-cache.oci

# 4. Verificar resultado
ls -lh _out/metal-amd64.iso
```

## Solución de Problemas

| Problema | Solución |
|----------|----------|
| **Error /dev mount** | Ejecutar con `--privileged` |
| **Cache corrupto** | Eliminar `image-cache.oci/` y regenerar |
| **ISO muy grande** | Normal (~2GB con todas las imágenes) |
| **Sin espacio** | Liberar ~3GB antes del build |

---

**Nota**: La ISO generada incluye Flannel CNI por defecto. Para otros CNI o extensions, usar método personalizado.
