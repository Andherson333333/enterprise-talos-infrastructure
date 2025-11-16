# Talos Cluster Deployment on Proxmox

![Talos](https://img.shields.io/badge/Talos-v1.10.6-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Cluster-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)

Automatización completa para desplegar clusters Talos Kubernetes en Proxmox con configuraciones personalizadas y registry mirrors.

## ¿Qué es?

Despliega un cluster Kubernetes usando Talos OS en infraestructura Proxmox con configuraciones modulares mediante patches YAML. Soporta registry mirrors locales para entornos offline.

### Beneficios Principales

- **Configuración modular**: Patches reutilizables para diferentes nodos
- **Registry mirrors**: Soporte para Harbor local (offline)
- **Storage personalizado**: Configuración Longhorn preintegrada
- **Multi-nodo**: 1 control plane + 2 workers
- **Reproducible**: Misma configuración para toda la infraestructura

## Prerequisitos

- Proxmox VE con VMs creadas
- talosctl CLI instalado
- kubectl instalado
- Registry local (Harbor) - opcional para offline
- Acceso SSH a nodos Proxmox

## Estructura de Archivos

```
.
├── customs/
│   ├── custom.yml                  # Configuración base común
│   ├── controlplane-patch-1.yml    # Patch para control plane
│   ├── worker-patch-1.yml          # Patch para worker 1
│   ├── worker-patch-2.yml          # Patch para worker 2
│   ├── storage.yml                 # Configuración Longhorn
│   └── registry-mirrors.yml        # Mirrors para Harbor
└── _out/
    ├── controlplane.yaml           # Config generada control plane
    ├── worker.yaml                 # Config generada workers
    └── talosconfig                 # Credentials del cluster
```

## Instalación

### 1. Generar Configuración Base

```bash
talosctl gen config promox-cluster https://192.168.253.100:6443 \
  -f \
  --with-docs=false \
  --install-disk /dev/sda \
  --output-dir _out
```

### 2. Aplicar Configuración Inicial

#### Control Plane Node
```bash
talosctl apply-config \
  --insecure \
  --nodes 192.168.253.236 \
  --config-patch @customs/custom.yml \
  --config-patch @customs/controlplane-patch-1.yml \
  --config-patch @customs/storage.yml \
  --file _out/controlplane.yaml
```

#### Worker Node 1
```bash
talosctl apply-config \
  --insecure \
  --nodes 192.168.253.239 \
  --config-patch @customs/custom.yml \
  --config-patch @customs/worker-patch-1.yml \
  --config-patch @customs/storage.yml \
  --file _out/worker.yaml
```

#### Worker Node 2
```bash
talosctl apply-config \
  --insecure \
  --nodes 192.168.253.238 \
  --config-patch @customs/custom.yml \
  --config-patch @customs/worker-patch-2.yml \
  --config-patch @customs/storage.yml \
  --file _out/worker.yaml
```

### 3. Configurar Acceso al Cluster

```bash
# Exportar talosconfig
export TALOSCONFIG=_out/talosconfig

# Configurar endpoints
talosctl config endpoint 192.168.253.101,192.168.253.100
```

### 4. Bootstrap Cluster

```bash
talosctl bootstrap -n 192.168.253.101
```

### 5. Obtener Kubeconfig

```bash
# Desde control plane primario
talosctl kubeconfig -n 192.168.253.101

# Verificar acceso
kubectl get nodes
```

## Configuración

### Topology del Cluster

| Nodo | IP | Rol | Patches |
|------|-------|-------------|---------|
| **control-plane-1** | 192.168.253.101 | Control Plane | custom, controlplane-patch-1, storage |
| **worker-1** | 192.168.253.111 | Worker | custom, worker-patch-1, storage |
| **worker-2** | 192.168.253.112 | Worker | custom, worker-patch-2, storage |

### Patches Disponibles

```yaml
customs/
├── custom.yml              # Hostname, timezone, NTP
├── controlplane-patch-1    # Config control plane
├── worker-patch-1          # Config worker 1
├── worker-patch-2          # Config worker 2
├── storage.yml             # Longhorn storage
└── registry-mirrors.yml    # Harbor mirrors
```

## Uso

### Upgrade Nodos

```bash
# Upgrade workers
talosctl upgrade --nodes 192.168.253.111,192.168.253.112 \
  --image registry.harbor.local/docker-images/installer-base:v1.10.6
```

### Aplicar Registry Mirrors

#### Control Plane
```bash
talosctl apply-config \
  --nodes 192.168.253.101 \
  --config-patch @customs/custom.yml \
  --config-patch @customs/controlplane-patch-1.yml \
  --config-patch @customs/registry-mirrors.yml \
  --config-patch @customs/storage.yml \
  --file _out/controlplane.yaml
```

#### Workers
```bash
# Worker 1
talosctl apply-config \
  --nodes 192.168.253.111 \
  --config-patch @customs/custom.yml \
  --config-patch @customs/worker-patch-1.yml \
  --config-patch @customs/registry-mirrors.yml \
  --config-patch @customs/storage.yml \
  --file _out/worker.yaml

# Worker 2
talosctl apply-config \
  --nodes 192.168.253.112 \
  --config-patch @customs/custom.yml \
  --config-patch @customs/worker-patch-2.yml \
  --config-patch @customs/registry-mirrors.yml \
  --config-patch @customs/storage.yml \
  --file _out/worker.yaml
```

## Administración

### Verificación

```bash
# Estado del cluster
talosctl health --nodes 192.168.253.101

# Ver nodos Kubernetes
kubectl get nodes

# Verificar extensions
talosctl get extensions --nodes 192.168.253.101

# Logs del sistema
talosctl logs --nodes 192.168.253.101
```

### Comandos Útiles

```bash
# Dashboard Talos
talosctl dashboard --nodes 192.168.253.101

# Shell en nodo
talosctl shell --nodes 192.168.253.101

# Reiniciar nodo
talosctl reboot --nodes 192.168.253.111

# Reset completo (¡DESTRUCTIVO!)
talosctl reset --nodes 192.168.253.111
```

## Workflow Completo

```bash
# 1. Generar configs
talosctl gen config promox-cluster https://192.168.253.100:6443 -f --with-docs=false --install-disk /dev/sda --output-dir _out

# 2. Aplicar configs (control plane + workers)
talosctl apply-config --insecure --nodes 192.168.253.236 --config-patch @customs/custom.yml --config-patch @customs/controlplane-patch-1.yml --config-patch @customs/storage.yml --file _out/controlplane.yaml
talosctl apply-config --insecure --nodes 192.168.253.239 --config-patch @customs/custom.yml --config-patch @customs/worker-patch-1.yml --config-patch @customs/storage.yml --file _out/worker.yaml
talosctl apply-config --insecure --nodes 192.168.253.238 --config-patch @customs/custom.yml --config-patch @customs/worker-patch-2.yml --config-patch @customs/storage.yml --file _out/worker.yaml

# 3. Configurar acceso
export TALOSCONFIG=_out/talosconfig
talosctl config endpoint 192.168.253.101,192.168.253.100

# 4. Bootstrap
talosctl bootstrap -n 192.168.253.101

# 5. Kubeconfig
talosctl kubeconfig -n 192.168.253.101
```

## Troubleshooting

| Problema | Solución |
|----------|----------|
| **Nodo no responde** | Verificar IP y conectividad: `ping 192.168.253.101` |
| **Bootstrap falla** | Esperar 2-3 min, verificar logs: `talosctl logs -n 192.168.253.101` |
| **Upgrade colgado** | Reiniciar nodo: `talosctl reboot -n <NODE_IP>` |
| **Registry no funciona** | Verificar mirrors en: `talosctl get machinestatus -n <NODE_IP>` |

## Limitaciones

| Escenario | Funcionalidad |
|-----------|---------------|
| **Con internet** | Pull directo de ghcr.io |
| **Sin internet** | Requiere Harbor con mirrors |
| **Versiones** | Talos v1.10.6+ recomendado |
| **Storage** | Requiere discos adicionales para Longhorn |
