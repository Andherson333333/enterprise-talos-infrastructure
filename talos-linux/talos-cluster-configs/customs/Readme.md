# Talos Cluster Configuration Architecture

![Talos](https://img.shields.io/badge/Talos-Linux_OS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Container_Platform-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-Configuration-CB171E?style=for-the-badge&logo=yaml&logoColor=white)

Sistema de configuración modular para clusters Talos Linux que define arquitectura de nodos, separación de workloads y configuraciones air-gapped.

## ¿Qué es?

Conjunto de patches de configuración YAML que define la topología completa de un cluster Talos Linux. Cada archivo tiene un propósito específico para crear una arquitectura multi-tier con separación de workloads y capacidades air-gapped.

### Beneficios Principales

- **Arquitectura definida**: Separación clara entre infrastructure y application workloads
- **Configuración air-gapped**: Registry privado y DNS customizado incluido
- **Alta disponibilidad**: VIP automático y interfaces de red redundantes
- **Escalabilidad**: Templates reutilizables para múltiples nodos
- **Production ready**: Labels, taints y políticas preconfiguradas
- **Modularidad**: Cada archivo define un aspecto específico del cluster

## Prerequisitos

- Comprensión de arquitectura Kubernetes
- Conocimiento de networking dual (management + cluster)
- Certificados CA para registries privados
- Planificación de IPs y VLANs

## Estructura de Configuraciones

```
customs/
├── custom.yml                 # Configuración base compartida
├── controlplane-patch-1.yml   # Control plane con HA y DNS
├── worker-patch-1.yml         # Worker infrastructure tipo A
├── worker-patch-2.yml         # Worker infrastructure tipo B  
├── worker-patch-3.yml         # Worker infrastructure tipo C
├── worker-patch-5.yml         # Worker application production
├── registry-mirrors.yml       # Mirrors para registries públicos
└── storage.yml                # Configuración de volúmenes adicionales
```

## Arquitectura de Configuraciones

### Base Configuration (custom.yml)

**Propósito**: Configuración compartida aplicada a todos los nodos del cluster.

**Componentes principales**:
- **extraHostEntries**: Define resolución DNS local para servicios air-gapped (Harbor registry, Gitea)
- **imageCache**: Habilita cache local de imágenes para instalaciones offline
- **TrustedRootsConfig**: Integra certificados CA personalizados para registries privados
- **VolumeConfig**: Configura volúmenes específicos como IMAGECACHE para optimización

**Función en la arquitectura**: Establece las bases para operación air-gapped y trust chain de certificados.

### Control Plane Configuration (controlplane-patch-1.yml)

**Propósito**: Define el nodo maestro con alta disponibilidad y servicios core customizados.

**Componentes clave**:
- **VIP (Virtual IP)**: IP flotante `192.168.253.100` para alta disponibilidad del API server
- **Dual networking**: Interface primaria (ens18) + secundaria (ens19) para separación de tráfico
- **CoreDNS inline manifest**: ConfigMap customizado que integra hosts air-gapped directamente en CoreDNS
- **Prometheus metrics**: Configuración de controller-manager y scheduler para observabilidad
- **Node classification**: Labels específicos `workload-type: infrastructure` y tier `control-plane`

**Función en la arquitectura**: Punto de control central con capacidades air-gapped y HA nativa.

### Infrastructure Workers (worker-patch-1/2/3.yml)

**Propósito**: Nodos dedicados para workloads de infraestructura del cluster (monitoring, logging, ingress, storage).

**Características comunes**:
- **Hostnames únicos**: `talos-dt-01/02/03` para identificación clara
- **Networking dual**: Misma estrategia que control plane (ens18 + ens19)
- **Node labels**: `workload-type: infrastructure` y `tier: infrastructure`
- **Taints específicos**: `workload-type=infrastructure:PreferNoSchedule` para reservar recursos
- **IP assignment**: Rango `192.168.253.111-113` en red cluster

**Función en la arquitectura**: Tier dedicado para componentes críticos del cluster, separado de aplicaciones de usuario.

### Application Workers (worker-patch-5.yml)

**Propósito**: Nodos especializados para workloads de aplicación production con políticas estrictas.

**Características distintivas**:
- **Labels extendidos**: `workload-type: application`, `environment: production`, `criticality: high`
- **Multi-taint strategy**: Combinación de taints application + production para aislamiento total
- **Resource isolation**: Separación completa de workloads de infraestructura
- **Production hardening**: Configuración optimizada para cargas críticas

**Función en la arquitectura**: Tier aislado para aplicaciones de usuario con SLA estrictos.

### Registry Mirrors Configuration (registry-mirrors.yml)

**Propósito**: Define mirrors para registries públicos a través de Harbor registry privado como proxy.

**Componentes específicos**:
- **docker.io mirror**: Redirecciona pulls de Docker Hub a `https://registry.harbor.local/v2/proxy-docker`
- **ghcr.io mirror**: Redirecciona GitHub Container Registry a `https://registry.harbor.local/v2/proxy-ghcr`  
- **registry.k8s.io mirror**: Redirecciona Kubernetes registry a `https://registry.harbor.local/v2/proxy-k8s`
- **overridePath**: Fuerza redirección completa del path original

**Función en la arquitectura**: Habilita operación completamente air-gapped utilizando Harbor como proxy cache para registries externos.

### Storage Configuration (storage.yml)

**Propósito**: Configura volúmenes de usuario adicionales en nodos que tengan discos secundarios.

**Componentes de configuración**:
- **UserVolumeConfig**: Define volumen llamado `sdb-storage` para uso específico
- **diskSelector**: Selecciona automáticamente `/dev/sdb` que no sea disco del sistema
- **Size constraints**: Limita volumen entre 18-19GB para control de recursos  
- **Filesystem type**: Utiliza XFS para performance y confiabilidad

**Función en la arquitectura**: Proporciona almacenamiento adicional estructurado para workloads que requieren persistent volumes.

## Conceptos de Configuración

### Separación de Workloads por Tiers

#### **Infrastructure Tier**
```yaml
nodeLabels:
  workload-type: "infrastructure"
  node.talos.dev/tier: "infrastructure"
nodeTaints:
  workload-type: "infrastructure:PreferNoSchedule"
```
**Propósito**: Garantiza que componentes como Prometheus, Grafana, Ingress Controllers, y storage systems ejecuten en nodos dedicados.

#### **Application Tier**  
```yaml
nodeLabels:
  workload-type: "application" 
  environment: "production"
  criticality: "high"
nodeTaints:
  workload-type: "application:PreferNoSchedule"
  environment: "production:PreferNoSchedule"
```
**Propósito**: Aísla completamente las aplicaciones de usuario de componentes de infraestructura.

### Networking Architecture

#### **Dual Interface Strategy**
- **ens18**: Red cluster primaria (192.168.253.x/24) - Tráfico Kubernetes
- **ens19**: Red management secundaria (192.168.141.x/24) - Administración y backup

#### **VIP Implementation**
```yaml
vip:
  ip: 192.168.253.100
```
**Función**: Proporciona endpoint único para API server con failover automático entre control planes.

### Air-Gapped DNS Integration

#### **CoreDNS Inline Manifest**
```yaml
hosts {
  192.168.253.6   gitea.aerr.com
  192.168.253.7   registry.harbor.local harbor.local
  fallthrough
}
```
**Propósito**: Integra resolución DNS customizada directamente en CoreDNS sin dependencias externas.

## Relaciones entre Configuraciones

### Flujo de Aplicación de Patches

1. **custom.yml** → Se aplica a TODOS los nodos (base común)
2. **controlplane-patch-1.yml** → Se combina con custom.yml para control plane
3. **worker-patch-X.yml** → Se combina con custom.yml para cada worker específico

### Interdependencias

- **custom.yml** define CA certificates necesarios para todos los nodos
- **controlplane-patch-1.yml** establece VIP que otros nodos usan como endpoint
- **worker patches** referencian subnets y gateways definidos en la arquitectura general
- **CoreDNS config** en control plane proporciona resolución para hosts definidos en custom.yml
- **registry-mirrors.yml** requiere CA certificates de custom.yml para comunicación con Harbor
- **storage.yml** se aplica solo a nodos que tengan el disco `/dev/sdb` disponible

## Estrategias de Escalabilidad

### Template-Based Workers

Los worker-patch-1/2/3.yml siguen el mismo template con variaciones mínimas:
- **Hostname**: Incremento secuencial (`talos-dt-01`, `talos-dt-02`)  
- **IP addresses**: Incremento en ambas redes (253.111→112→113, 141.11→12→13)
- **Configuración idéntica**: Labels, taints, y kubelet settings consistentes

### Application Worker Templates

worker-patch-5.yml establece el patrón para workers de aplicación:
- **Labels específicos**: environment, criticality tags
- **Taint strategy**: Multiple taints para aislamiento
- **Naming pattern**: Preparado para worker-patch-6, 7, etc.

## Configuraciones Futuras

### registry-mirrors.yml
**Propósito planificado**: Definir mirrors para registries públicos en entornos air-gapped.

### storage.yml  
**Propósito planificado**: Configuraciones específicas de storage classes y persistent volumes.

---

**Nota**: Esta arquitectura implementa un cluster production-ready con separación completa de workloads, capacidades air-gapped, y alta disponibilidad nativa mediante VIP y dual networking.
