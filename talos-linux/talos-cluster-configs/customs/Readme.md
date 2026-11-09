**English** | [Español](./Readme.es.md)

# Talos Cluster Configuration Architecture

![Talos](https://img.shields.io/badge/Talos-Linux_OS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Container_Platform-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-Configuration-CB171E?style=for-the-badge&logo=yaml&logoColor=white)

Modular configuration system for Talos Linux clusters that defines the node architecture, workload separation and air-gapped settings.

## What is it?

A set of YAML configuration patches that define the full topology of a Talos Linux cluster. Each file has a specific purpose, building a multi-tier architecture with workload separation and air-gapped capabilities.

### Main Benefits

- **Defined architecture**: Clear separation between infrastructure and application workloads
- **Air-gapped configuration**: Private registry and custom DNS included
- **High availability**: Automatic VIP and redundant network interfaces
- **Scalability**: Reusable templates for multiple nodes
- **Production ready**: Preconfigured labels, taints and policies
- **Modularity**: Each file defines one specific aspect of the cluster

## Prerequisites

- Understanding of Kubernetes architecture
- Knowledge of dual networking (management + cluster)
- CA certificates for private registries
- IP and VLAN planning

## Configuration Structure

```
customs/
├── custom.yml                 # Shared base configuration
├── controlplane-patch-1.yml   # Control plane with HA and DNS
├── worker-patch-1.yml         # Infrastructure worker type A
├── worker-patch-2.yml         # Infrastructure worker type B  
├── worker-patch-3.yml         # Infrastructure worker type C
├── worker-patch-5.yml         # Production application worker
├── registry-mirrors.yml       # Mirrors for public registries
└── storage.yml                # Extra volume configuration
```

## Configuration Architecture

### Base Configuration (custom.yml)

**Purpose**: Shared configuration applied to every node in the cluster.

**Main components**:
- **extraHostEntries**: Defines local DNS resolution for air-gapped services (Harbor registry, Gitea)
- **imageCache**: Enables the local image cache for offline installations
- **TrustedRootsConfig**: Integrates custom CA certificates for private registries
- **VolumeConfig**: Configures specific volumes such as IMAGECACHE for optimization

**Role in the architecture**: Lays the foundation for air-gapped operation and the certificate trust chain.

### Control Plane Configuration (controlplane-patch-1.yml)

**Purpose**: Defines the master node with high availability and customized core services.

**Key components**:
- **VIP (Virtual IP)**: Floating IP `192.168.253.100` for API server high availability
- **Dual networking**: Primary (ens18) + secondary (ens19) interface for traffic separation
- **CoreDNS inline manifest**: Custom ConfigMap that adds the air-gapped hosts directly to CoreDNS
- **Prometheus metrics**: controller-manager and scheduler configuration for observability
- **Node classification**: Specific labels `workload-type: infrastructure` and tier `control-plane`

**Role in the architecture**: Central control point with air-gapped capabilities and native HA.

### Infrastructure Workers (worker-patch-1/2/3.yml)

**Purpose**: Nodes dedicated to cluster infrastructure workloads (monitoring, logging, ingress, storage).

**Common features**:
- **Unique hostnames**: `talos-dt-01/02/03` for clear identification
- **Dual networking**: Same strategy as the control plane (ens18 + ens19)
- **Node labels**: `workload-type: infrastructure` and `tier: infrastructure`
- **Specific taints**: `workload-type=infrastructure:PreferNoSchedule` to reserve resources
- **IP assignment**: Range `192.168.253.111-113` on the cluster network

**Role in the architecture**: Dedicated tier for critical cluster components, separated from user applications.

### Application Workers (worker-patch-5.yml)

**Purpose**: Nodes specialized for production application workloads with strict policies.

**Distinctive features**:
- **Extended labels**: `workload-type: application`, `environment: production`, `criticality: high`
- **Multi-taint strategy**: Combination of application + production taints for full isolation
- **Resource isolation**: Full separation from infrastructure workloads
- **Production hardening**: Configuration optimized for critical loads

**Role in the architecture**: Isolated tier for user applications with strict SLAs.

### Registry Mirrors Configuration (registry-mirrors.yml)

**Purpose**: Defines mirrors for public registries through the private Harbor registry acting as a proxy.

**Specific components**:
- **docker.io mirror**: Redirects Docker Hub pulls to `https://registry.harbor.local/v2/proxy-docker`
- **ghcr.io mirror**: Redirects GitHub Container Registry to `https://registry.harbor.local/v2/proxy-ghcr`  
- **registry.k8s.io mirror**: Redirects the Kubernetes registry to `https://registry.harbor.local/v2/proxy-k8s`
- **overridePath**: Forces full redirection of the original path

**Role in the architecture**: Enables fully air-gapped operation using Harbor as a proxy cache for external registries.

### Storage Configuration (storage.yml)

**Purpose**: Configures extra user volumes on nodes that have secondary disks.

**Configuration components**:
- **UserVolumeConfig**: Defines a volume named `sdb-storage` for a specific use
- **diskSelector**: Automatically selects `/dev/sdb` as long as it is not the system disk
- **Size constraints**: Limits the volume to 18-19GB for resource control  
- **Filesystem type**: Uses XFS for performance and reliability

**Role in the architecture**: Provides structured extra storage for workloads that need persistent volumes.

## Configuration Concepts

### Workload Separation by Tiers

#### **Infrastructure Tier**
```yaml
nodeLabels:
  workload-type: "infrastructure"
  node.talos.dev/tier: "infrastructure"
nodeTaints:
  workload-type: "infrastructure:PreferNoSchedule"
```
**Purpose**: Ensures components such as Prometheus, Grafana, Ingress Controllers and storage systems run on dedicated nodes.

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
**Purpose**: Fully isolates user applications from infrastructure components.

### Networking Architecture

#### **Dual Interface Strategy**
- **ens18**: Primary cluster network (192.168.253.x/24) - Kubernetes traffic
- **ens19**: Secondary management network (192.168.141.x/24) - Administration and backup

#### **VIP Implementation**
```yaml
vip:
  ip: 192.168.253.100
```
**Role**: Provides a single API server endpoint with automatic failover between control planes.

### Air-Gapped DNS Integration

#### **CoreDNS Inline Manifest**
```yaml
hosts {
  192.168.253.6   gitea.aerr.com
  192.168.253.7   registry.harbor.local harbor.local
  fallthrough
}
```
**Purpose**: Adds custom DNS resolution directly in CoreDNS with no external dependencies.

## Relationships Between Configurations

### Patch Application Flow

1. **custom.yml** → Applied to ALL nodes (common base)
2. **controlplane-patch-1.yml** → Combined with custom.yml for the control plane
3. **worker-patch-X.yml** → Combined with custom.yml for each specific worker

### Interdependencies

- **custom.yml** defines the CA certificates every node needs
- **controlplane-patch-1.yml** sets the VIP that other nodes use as endpoint
- **worker patches** reference subnets and gateways defined in the overall architecture
- **CoreDNS config** on the control plane resolves the hosts defined in custom.yml
- **registry-mirrors.yml** needs the CA certificates from custom.yml to talk to Harbor
- **storage.yml** applies only to nodes that have the `/dev/sdb` disk available

## Scalability Strategies

### Template-Based Workers

worker-patch-1/2/3.yml follow the same template with minimal variations:
- **Hostname**: Sequential increment (`talos-dt-01`, `talos-dt-02`)  
- **IP addresses**: Increment on both networks (253.111→112→113, 141.11→12→13)
- **Identical configuration**: Consistent labels, taints and kubelet settings

### Application Worker Templates

worker-patch-5.yml sets the pattern for application workers:
- **Specific labels**: environment, criticality tags
- **Taint strategy**: Multiple taints for isolation
- **Naming pattern**: Ready for worker-patch-6, 7, etc.

## Future Configurations

### registry-mirrors.yml
**Planned purpose**: Define mirrors for public registries in air-gapped environments.

### storage.yml  
**Planned purpose**: Specific storage class and persistent volume configurations.

---

**Note**: This architecture implements a production-ready cluster with full workload separation, air-gapped capabilities and native high availability through VIP and dual networking.
