# Template para Proxmox Debian 12

![Proxmox](https://img.shields.io/badge/Proxmox-Template-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Compatible-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Volumes-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![LVM](https://img.shields.io/badge/LVM-Auto_Resize-FF6B35?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-Template-A81D33?style=for-the-badge&logo=debian&logoColor=white)

Configuración de template Debian para Proxmox con volúmenes Docker LVM y redimensionamiento automático.

## Arquitectura

![Architecture](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/templates-4.png)

## Flujo de Trabajo

```
CREACIÓN: Debian VM → LVM Config → Template Proxmox
USO: Template → Nueva VM → Auto-resize al boot

ESTRUCTURA LVM:
/dev/sdb → PV → VG (vg_data) → LV (docker_data) → /var/lib/docker/volumes
```

## Características

- **Auto-resize**: Expande automáticamente al arrancar
- **Zero Config**: VMs listas para Docker inmediatamente  
- **Escalable**: Funciona con cualquier tamaño de disco
- **Compatible**: Terraform, Ansible, etc.

## Requisitos

- VM Debian limpia en Proxmox
- Disco adicional (`/dev/sdb`)
- Permisos de root

## Creación de VM en Proxmox

### Configuración VM
```bash
# Proxmox UI: Datacenter → Node → Create VM

VM ID: 100
Name: debian-docker-template
ISO: Debian 12 (Bookworm)
Type: Linux 6.x - 2.6 Kernel

# Sistema
SCSI Controller: VirtIO SCSI single
Qemu Agent:  ACTIVAR

# Discos
SCSI 0: 20GB (Sistema)
SCSI 1: 10GB (Docker LVM)
Cache: Write back
Discard:  Activar

# Hardware  
CPU: 2 cores, type host
RAM: 2048 MB
Red: VirtIO, bridge vmbr0
```

### Instalación Debian
- Instalar Debian 12 con interfaz gráfica
- Configurar SSH y usuario root
- Verificar discos: `lsblk` (sda=sistema, sdb=docker)

## Configuración LVM

### Método Rápido (Scripts)
```bash
# Ejecutar 4 scripts en orden:
./01-install-packages.sh
./02-lvm-setup.sh  
./03-create-resize-script.sh
./04-setup-autostart.sh
```

### Método Manual

#### 1. Instalar paquetes
```bash
apt update
apt install lvm2 -y
apt install -y qemu-guest-agent
```

#### 2. Configurar LVM
```bash
pvcreate /dev/sdb
vgcreate vg_data /dev/sdb  
lvcreate -n docker_data -l 100%FREE vg_data
mkfs.ext4 /dev/vg_data/docker_data
mkdir -p /var/lib/docker/volumes
mount /dev/vg_data/docker_data /var/lib/docker/volumes
echo "/dev/vg_data/docker_data /var/lib/docker/volumes ext4 defaults 0 2" >> /etc/fstab
```

#### 3. Script auto-resize
```bash
cat > /usr/local/bin/resize-docker-volumes.sh << 'EOF'
#!/bin/bash
pvresize /dev/sdb
lvextend -l +100%FREE /dev/vg_data/docker_data
resize2fs /dev/vg_data/docker_data
EOF

chmod +x /usr/local/bin/resize-docker-volumes.sh
```

#### 4. Configurar arranque automático
```bash
cat > /etc/rc.local << 'EOF'
#!/bin/sh -e
sleep 60
cd /usr/local/bin && ./resize-docker-volumes.sh
exit 0
EOF

chmod +x /etc/rc.local
systemctl start rc-local.service
```


## Verificación

```bash
# Verificar LVM
pvdisplay && vgdisplay && lvdisplay

# Verificar montaje
df -h | grep docker

# Verificar servicio
systemctl status rc-local.service

# En nueva VM (verificar auto-resize)
lsblk
df -h /var/lib/docker/volumes
```



