# Talos Custom Installer Builder

![Talos](https://img.shields.io/badge/Talos-Kubernetes_OS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![OCI](https://img.shields.io/badge/OCI-Image_Cache-FF6B35?style=for-the-badge&logo=containerd&logoColor=white)

Herramienta para crear installers personalizados de Talos con system extensions incluidas para uso offline.

## ¿Qué es?

Genera installers de Talos que incluyen system extensions (iscsi-tools, util-linux-tools, qemu-guest-agent) preinstaladas. Ideal para entornos sin internet o con registry local.

### Beneficios Principales

- **Uso offline**: Funciona sin acceso a internet usando registry local
- **Extensions preinstaladas**: iscsi-tools, util-linux-tools, qemu-guest-agent incluidas
- **Cache optimizado**: Imágenes en cache OCI para builds rápidos
- **Upgrades simplificados**: Un solo comando para actualizar nodos
- **Reproducible**: Mismo installer para toda la infraestructura

## Prerequisitos

- Docker instalado
- Acceso a internet (solo para build inicial)
- talosctl CLI
- Registry local (Harbor recomendado para uso offline)

## Estructura de Archivos

```
~/talos-images-tools/
├── images.txt              # Lista de imágenes para cache
├── image-cache.oci/        # Cache de imágenes generado
└── _out/                   # Archivos de salida
    └── installer-amd64.tar # Installer personalizado
```

## Instalación

### 1. Preparar Workspace

```bash
mkdir ~/talos-images-tools
cd ~/talos-images-tools
```

### 2. Crear Image Cache

```bash
# Lista de imágenes necesarias
cat > images.txt << EOF
ghcr.io/siderolabs/flannel:v0.26.7
registry.k8s.io/coredns/coredns:v1.12.1
gcr.io/etcd-development/etcd:v3.5.21
registry.k8s.io/kube-apiserver:v1.33.3
registry.k8s.io/kube-controller-manager:v1.33.3
registry.k8s.io/kube-scheduler:v1.33.3
registry.k8s.io/kube-proxy:v1.33.3
ghcr.io/siderolabs/kubelet:v1.33.3
ghcr.io/siderolabs/installer:v1.10.6
registry.k8s.io/pause:3.10
ghcr.io/siderolabs/qemu-guest-agent:10.0.2@sha256:0d16cd4f8cefab33f091e336bc666943a71355ee010d0dfa0e46498693af1c52
ghcr.io/siderolabs/util-linux-tools:2.40.4@sha256:f305315aec4fe0a355fb933c919a25550c67785acb193ee2842784317b5fa66b
ghcr.io/siderolabs/iscsi-tools:v0.2.0@sha256:f2d78a7f19d301f2bf88ec99d948ffc63778125ce3acb0146049b75ed7ecd18c
EOF
```
```
# Generar cache OCI
docker run --rm -v $PWD/image-cache.oci:/image-cache.oci \
  ghcr.io/siderolabs/imager:v1.10.6 image-cache \
  --images @images.txt \
  --output /image-cache.oci
```

### 3. Generar Installer Custom

```bash
docker run --rm -t \
  -v $PWD/_out:/out \
  -v $PWD/image-cache.oci:/image-cache.oci:ro \
  ghcr.io/siderolabs/imager:v1.10.6 installer \
  --arch amd64 \
  --system-extension-image ghcr.io/siderolabs/qemu-guest-agent:10.0.2@sha256:0d16cd4f8cefab33f091e336bc666943a71355ee010d0dfa0e46498693af1c52 \
  --system-extension-image ghcr.io/siderolabs/util-linux-tools:2.40.4@sha256:f305315aec4fe0a355fb933c919a25550c67785acb193ee2842784317b5fa66b \
  --system-extension-image ghcr.io/siderolabs/iscsi-tools:v0.2.0@sha256:f2d78a7f19d301f2bf88ec99d948ffc63778125ce3acb0146049b75ed7ecd18c \
  --image-cache /image-cache.oci
```

## Configuración

### Variables por Defecto

```yaml
# System Extensions incluidas
qemu-guest-agent: v10.0.2
util-linux-tools: v2.40.4
iscsi-tools: v0.2.0

# Arquitectura
arch: amd64

# Versión Talos
talos_version: v1.10.6
```

### Registry Local (para uso offline)

```bash
# Cargar imagen en Docker
cd _out/
docker load -i installer-amd64.tar

# Tagear para registry local
docker tag ghcr.io/siderolabs/installer-base:v1.10.6 \
  registry.harbor.local/docker-images/installer-base:v1.10.6

# Subir a Harbor
docker push registry.harbor.local/docker-images/installer-base:v1.10.6
```

## Uso

### Upgrade Nodos Talos

```bash
# Upgrade nodo único
talosctl upgrade --nodes 192.168.253.101 \
  --image registry.harbor.local/docker-images/installer-base:v1.10.6

# Upgrade múltiples nodos
talosctl upgrade --nodes 192.168.253.101,192.168.253.111,192.168.253.112 \
  --image registry.harbor.local/docker-images/installer-base:v1.10.6
```

### Verificación

```bash
# Verificar extensions activas
talosctl get extensions --nodes 192.168.253.101

# Estado del nodo
talosctl get machinestatus --nodes 192.168.253.101
```

## Administración

```bash
# Verificar imagen cargada
docker images | grep installer

# Listar archivos generados
ls -la _out/

# Ver espacio usado por cache
du -sh image-cache.oci/
```

## Comandos Resumidos

```bash
# Build completo
mkdir ~/talos-images-tools && cd ~/talos-images-tools

# 1. Cache
docker run --rm -v $PWD/image-cache.oci:/image-cache.oci ghcr.io/siderolabs/imager:v1.10.6 image-cache --images @images.txt --output /image-cache.oci

# 2. Installer
docker run --rm -t -v $PWD/_out:/out -v $PWD/image-cache.oci:/image-cache.oci:ro ghcr.io/siderolabs/imager:v1.10.6 installer --arch amd64 --system-extension-image ghcr.io/siderolabs/qemu-guest-agent:10.0.2@sha256:... --image-cache /image-cache.oci

# 3. Deploy
docker load -i _out/installer-amd64.tar
talosctl upgrade --nodes <NODE_IP> --image <INSTALLER_IMAGE>
```

## Limitaciones

| Escenario | Funcionalidad |
|-----------|---------------|
| **Con internet** | Funcionamiento completo |
| **Sin internet** | Solo con registry local |
| **Versiones** | SHAs deben coincidir con Talos |

