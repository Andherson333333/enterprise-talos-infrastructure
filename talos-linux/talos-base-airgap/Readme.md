**English** | [Español](./Readme.es.md)

# Talos ISO Builder

![Talos](https://img.shields.io/badge/Talos-Linux_OS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![ISO](https://img.shields.io/badge/ISO-Builder-FF6B35?style=for-the-badge&logo=linux&logoColor=white)

Tool to build bootable Talos Linux ISO images with an offline image cache.

## What is it?

Builds Talos Linux ISO images with every Kubernetes and CNI image preloaded. Ideal for offline installations on physical servers or virtual machines.

### Main Benefits

- **Offline installation**: ISO with every required image included
- **Optimized cache**: Preloaded images for a fast installation
- **Bootable**: ISO ready to install on any hardware
- **CNI included**: Flannel preconfigured by default
- **No internet**: Works fully offline after the build

## Prerequisites

- Docker installed
- talosctl CLI
- Privileged access (/dev mount)
- Disk space (~2GB for the ISO)
- Internet access (initial build only)

## File Structure

```
~/talos-iso-builder/
├── images.txt              # Base image list
├── extra-images.txt        # Additional images (optional)
├── image-cache.oci/        # Generated image cache
└── _out/                   # Output files
    └── metal-amd64.iso     # Final ISO
```

## Installation

### 1. Prepare the Workspace

```bash
# Create working directory
mkdir ~/talos-iso-builder
cd ~/talos-iso-builder
```

### 2. Extract Base Images

```bash
# Extract the default Talos images
talosctl images default > images.txt

# Add extra images (optional)
# echo "registry.k8s.io/my-custom-image:latest" >> images.txt
# cat extra-images.txt >> images.txt
```

### 3. Create the OCI Cache

```bash
# Build the image cache (requires internet)
cat images.txt | talosctl images cache-create \
  --image-cache-path ./image-cache.oci \
  --images=-
```

### 4. Build the ISO

```bash
# Create output directory
mkdir -p _out/

# Build the ISO with the cache
docker run --rm -t \
  -v $PWD/_out:/secureboot:ro \
  -v $PWD/_out:/out \
  -v $PWD/image-cache.oci:/image-cache.oci:ro \
  -v /dev:/dev \
  --privileged \
  ghcr.io/siderolabs/imager:v1.10.3 iso \
  --image-cache /image-cache.oci
```

## Configuration

### Default Variables

```yaml
# Talos version
talos_version: v1.10.3
imager_version: v1.10.3

# Architecture
arch: amd64

# Included CNI
cni: flannel

# Cache path
image_cache_path: ./image-cache.oci
```

### images.txt Contents

```bash
# Show which images will be included
cat images.txt

# Example contents:
# ghcr.io/siderolabs/flannel:v0.26.7
# registry.k8s.io/coredns/coredns:v1.12.1
# gcr.io/etcd-development/etcd:v3.5.21
# registry.k8s.io/kube-apiserver:v1.33.2
# ghcr.io/siderolabs/installer:v1.10.5
```

## Usage

### Prepare the ISO for Installation

```bash
# Check the generated ISO
ls -lh _out/metal-amd64.iso

# Write it to a USB device
dd if=_out/metal-amd64.iso of=/dev/sdX bs=4M status=progress

# For VMs, mount the ISO file directly
```

### Server Installation

```bash
# 1. Boot from the ISO
# 2. Follow the normal Talos installation process
# 3. Images are loaded from the local cache (fast)
```

## Verification

```bash
# Check the generated cache
du -sh image-cache.oci/

# Count images in the cache
cat images.txt | wc -l

# Check the final ISO
file _out/metal-amd64.iso
ls -lh _out/metal-amd64.iso
```

## Administration

```bash
# Rebuild the cache (if the images change)
rm -rf image-cache.oci/
cat images.txt | talosctl images cache-create --image-cache-path ./image-cache.oci --images=-

# Clean output files
rm -rf _out/

# Show total disk usage
du -sh ~/talos-iso-builder/
```

## Command Summary

```bash
# Full build in one sequence
mkdir ~/talos-iso-builder && cd ~/talos-iso-builder

# 1. Extract images
talosctl images default > images.txt

# 2. Create cache
cat images.txt | talosctl images cache-create --image-cache-path ./image-cache.oci --images=-

# 3. Build ISO
mkdir -p _out/
docker run --rm -t -v $PWD/_out:/secureboot:ro -v $PWD/_out:/out -v $PWD/image-cache.oci:/image-cache.oci:ro -v /dev:/dev --privileged ghcr.io/siderolabs/imager:v1.10.3 iso --image-cache /image-cache.oci

# 4. Check the result
ls -lh _out/metal-amd64.iso
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **/dev mount error** | Run with `--privileged` |
| **Corrupted cache** | Delete `image-cache.oci/` and rebuild |
| **ISO too large** | Normal (~2GB with every image) |
| **Out of space** | Free ~3GB before the build |

---

**Note**: The generated ISO includes Flannel CNI by default. For other CNIs or extensions, use the custom method.
