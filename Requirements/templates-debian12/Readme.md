# Template para Proxmox debian 12

![Proxmox](https://img.shields.io/badge/Proxmox-Template-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Compatible-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Volumes-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![LVM](https://img.shields.io/badge/LVM-Auto_Resize-FF6B35?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-Template-A81D33?style=for-the-badge&logo=debian&logoColor=white)

Configuración manual de template Debian para Proxmox con volúmenes Docker LVM y redimensionamiento automático.

## Arquitectura 




## Arquitectura y Flujo de Trabajo

```
CREACIÓN DEL TEMPLATE:
Debian VM → Configuración LVM Manual → Template Proxmox

USO DEL TEMPLATE:
Template → Nueva VM → Auto-resize al boot

ESTRUCTURA LVM:
/dev/sdb (Disco adicional)
    ↓
Physical Volume (PV) → Auto-resize
    ↓  
Volume Group (vg_data) → Auto-expand
    ↓
Logical Volume (docker_data) → Auto-extend
    ↓
/var/lib/docker/volumes → Listo para usar
```

## ¿Cómo Funciona?

1. **Configuración Manual**: Se configura LVM manualmente en una VM Debian limpia
2. **Template en Proxmox**: La VM se convierte en template con LVM preconfigurado
3. **Deploy de VMs**: Se crean nuevas VMs desde el template con el disco del tamaño deseado
4. **Auto-resize al Boot**: El script detecta el nuevo tamaño y expande automáticamente
5. **Docker Ready**: Los volúmenes Docker están listos con el espacio asignado

## Características

- **Template Proxmox Ready**: Pre-configurado para usar como template
- **Auto-resize al Boot**: Detecta y expande el disco automáticamente al arrancar
- **Docker Volumes Optimizados**: `/var/lib/docker/volumes` listo desde el inicio
- **Zero Configuration**: Las VMs creadas desde el template no necesitan configuración adicional
- **Escalable**: Funciona con cualquier tamaño de disco asignado
- **Infraestructura como Código**: Compatible con Terraform, Ansible, etc.

## Requisitos

### Para crear el template:
- VM Debian limpia en Proxmox
- Disco adicional (`/dev/sdb`) agregado a la VM
- Permisos de root en la VM

### Para usar el template:
- Proxmox configurado
- Template creado y disponible
- Sistema de deployment (Terraform, Ansible, etc.)

## Creación de VM Debian en Proxmox

### 1. Crear nueva VM
```bash
# En la interfaz web de Proxmox:
# Datacenter → Node → Create VM
```

#### Configuración General
- **VM ID**: Asignar un número único (ej: 100)
- **Name**: Nombre descriptivo (ej: debian-docker-template)
- **Resource Pool**: Seleccionar pool apropiado (opcional)

#### Configuración del Sistema Operativo
- **ISO Image**: Seleccionar ISO de Debian 12 (Bookworm)
- **Type**: Linux
- **Version**: 6.x - 2.6 Kernel

#### Configuración del Sistema
- **Graphic Card**: Default
- **Machine**: Default (i440fx)
- **BIOS**: Default (SeaBIOS)
- **SCSI Controller**: VirtIO SCSI single
- **Qemu Agent**:  **ACTIVAR** (importante para integración)

#### Configuración de Discos
```bash
# Disco principal (Sistema Operativo)
Bus/Device: SCSI 0
Storage: local-lvm (o el storage que uses)
Disk size: 20 GB (suficiente para el template)
Cache: Write back
Discard:  Activar
SSD emulation:  Activar (opcional)

# Disco adicional (para Docker LVM)
Bus/Device: SCSI 1  
Storage: local-lvm (o el storage que uses)
Disk size: 10 GB (tamaño base, se redimensionará después)
Cache: Write back
Discard:  Activar
```

#### Configuración de CPU
- **Sockets**: 1
- **Cores**: 2 (mínimo para el template)
- **Type**: host (para mejor rendimiento)

#### Configuración de Memoria
- **Memory**: 2048 MB (2GB mínimo)
- **Ballooning Device**:  Activar

#### Configuración de Red
- **Bridge**: vmbr0 (o el bridge configurado)
- **VLAN Tag**: Dejar vacío (a menos que uses VLANs)
- **Firewall**:  Activar (opcional)
- **Model**: VirtIO (paravirtualized)

### 2. Confirmar configuración
```bash
# Revisar resumen de configuración:
# - VM ID y nombre
# - 2 discos SCSI (20GB sistema + 10GB Docker)
# - Qemu Agent activado
# - Red configurada correctamente

# Click "Finish" para crear la VM
```

### 3. Instalar Debian

Hacer la instalacion con GUI o grafico 

## Nota 

Se explica procoeso manual si quiere realizarlo mas rapido puede ejecutar esto 4 scrip



### 4. Configuración inicial post-instalación
```bash
# Conectar por SSH a la VM como root
ssh root@<ip-de-la-vm>

# Verificar que ambos discos están presentes
lsblk
# Debería mostrar:
# sda (20G) - Disco sistema con particiones
# sdb (10G) - Disco adicional sin particionar

# Verificar que qemu-guest-agent se instalará después
# (se instala en el paso 2 de configuración LVM)
```

### 1. Preparar VM en Proxmox
```bash
# Crear VM Debian limpia en Proxmox
# Agregar disco adicional (ej: 10G para el template)
# Acceder por SSH a la VM como root
```

### 2. Instalar paquetes necesarios
```bash
# Actualizar repositorios del sistema
apt update

# Instalar LVM2 para gestión avanzada de volúmenes
apt install lvm2 -y

# Instalar qemu-guest-agent para mejor integración con Proxmox
apt install -y qemu-guest-agent
```

### 3. Configurar LVM para Docker
```bash
# Crear Physical Volume en el disco adicional
pvcreate /dev/sdb

# Crear Volume Group llamado 'vg_data'
vgcreate vg_data /dev/sdb  

# Crear Logical Volume usando todo el espacio disponible
lvcreate -n docker_data -l 100%FREE vg_data

# Formatear el Logical Volume con sistema de archivos ext4
mkfs.ext4 /dev/vg_data/docker_data

# Crear directorio donde se montarán los volúmenes Docker
mkdir -p /var/lib/docker/volumes

# Montar el Logical Volume en el directorio Docker
mount /dev/vg_data/docker_data /var/lib/docker/volumes

# Configurar montaje automático al arranque del sistema
echo "/dev/vg_data/docker_data /var/lib/docker/volumes ext4 defaults 0 2" >> /etc/fstab
```

### 4. Crear script de redimensionamiento automático
```bash
# Crear script que redimensionará automáticamente al arrancar
cat > /usr/local/bin/resize-docker-volumes.sh << 'EOF'
#!/bin/bash
# Script de redimensionamiento automático para volúmenes Docker

# Redimensionar el Physical Volume al tamaño actual del disco
pvresize /dev/sdb

# Extender el Logical Volume para usar todo el espacio disponible
lvextend -l +100%FREE /dev/vg_data/docker_data

# Redimensionar el sistema de archivos para usar el nuevo espacio
resize2fs /dev/vg_data/docker_data
EOF

# Dar permisos de ejecución al script
chmod +x /usr/local/bin/resize-docker-volumes.sh
```

### 5. Configurar ejecución automática al arranque
```bash
# Crear archivo rc.local para ejecutar el script al arrancar el sistema
cat > /etc/rc.local << 'EOF'
#!/bin/sh -e
#
# rc.local - Script ejecutado al final del proceso de arranque
#
# Esperar 60 segundos para que el sistema esté completamente iniciado
sleep 60

# Cambiar al directorio de scripts y ejecutar redimensionamiento
cd /usr/local/bin && ./resize-docker-volumes.sh

# Finalizar correctamente
exit 0
EOF

# Dar permisos de ejecución al archivo rc.local
chmod +x /etc/rc.local

# Verificar el estado del servicio rc-local
systemctl status rc-local.service

# Iniciar el servicio rc-local para la próxima vez
systemctl start rc-local.service
```

### 6. Limpiar y convertir a Template
```bash
# Limpiar cachés y archivos temporales antes de crear el template
apt clean
apt autoremove
history -c

# En Proxmox UI: Seleccionar VM → More → Convert to Template
# O usar CLI: qm template <vmid>
```

### Verificar funcionamiento en nueva VM
```bash
# En una VM creada desde el template, verificar:

# Que el disco se expandió correctamente
lsblk
df -h /var/lib/docker/volumes

# Que LVM tiene el tamaño correcto
pvdisplay | grep "PV Size"
lvdisplay | grep "LV Size"
```
```
