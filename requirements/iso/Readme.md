**English** | [Español](./Readme.es.md)

# ISO Image Preparation 

![Proxmox](https://img.shields.io/badge/Proxmox-VE-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-12+-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Virtualization](https://img.shields.io/badge/Virtualization-Lab-4B8BBE?style=for-the-badge)
![Checksums](https://img.shields.io/badge/SHA256-Verified-success?style=for-the-badge&logo=gnu-privacy-guard&logoColor=white)

Guide to download and verify the ISO images required for a virtualization environment with Proxmox and Debian.

## Components

- **Proxmox VE**: Open-source bare-metal hypervisor
- **Debian GNU/Linux**: Base operating system for VM templates

## Integrity Verification

**Important**: Always verify checksums to guarantee security and integrity.

## 1. Proxmox Virtual Environment

### Download

```bash
# Create working directory
mkdir -p ~/iso-images && cd ~/iso-images

# Download ISO (replace with current version)
wget https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso

# Download checksum file
wget https://enterprise.proxmox.com/iso/sha256sum.txt
```

### Verify

```bash
sha256sum -c sha256sum.txt --ignore-missing
```

**Expected result**: `proxmox-ve_8.2-1.iso: OK`

## 2. Debian GNU/Linux (Full DVD)

Full installation image including common software packages for offline installation.

### Download

```bash
# Download full DVD-1 ISO (replace with current version)
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.5.0-amd64-dvd-1.iso

# Download checksum file
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/SHA256SUMS
```

### Verify

```bash
# Filter and verify DVD-1 only
grep "dvd-1.iso" SHA256SUMS | sha256sum --check
```

**Expected result**: `debian-12.5.0-amd64-dvd-1.iso: OK`

## Reference Links

- [Proxmox Downloads](https://www.proxmox.com/en/downloads)
- [Debian DVD Images](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/)

## Result

With these verified files you will have:
- Proxmox VE installer for the physical server
- Full Debian installer for VM templates
