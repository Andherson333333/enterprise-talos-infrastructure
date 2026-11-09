**English** | [Español](./Readme.es.md)

# Enterprise Talos Infrastructure (Air-Gapped)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Talos](https://img.shields.io/badge/Talos-Linux-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Cilium](https://img.shields.io/badge/Cilium-CNI_%2B_BGP-F8C517?style=for-the-badge&logo=cilium&logoColor=black)
![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)

On-premise Kubernetes platform on **Proxmox VE** with **Talos Linux**, designed to run in an **air-gapped** environment: every image, package, chart and CI action is served from internal services (Harbor, Gitea, apt-cacher-ng), with no internet dependency once the environment is prepared.

## Architecture

![General architecture](./images/Arquitectura%20general%20-1.png)
![General architecture](./images/Arquitectura%20general%20-2.png)

## Components

| Layer | Component | Purpose |
|-------|-----------|---------|
| Hypervisor | Proxmox VE | Hosts every VM |
| IaC | Terraform (BPG provider) | VM provisioning from templates |
| Configuration | Ansible | Service installation on the support VMs |
| Registry | Harbor (+ Trivy) | OCI images and Helm charts, Docker Hub proxy cache |
| Git / CI | Gitea + act_runner | Repositories, Gitea Actions with offline-mirrored actions |
| Packages | apt-cacher-ng | APT cache for the Debian VMs |
| Secrets | OpenBao (Raft x3 + HAProxy) | Secrets management, integrated with ArgoCD (AVP) |
| Routing | FRR x2 | BGP peers for Cilium (LoadBalancer IPs advertised via ECMP) |
| Kubernetes | Talos Linux | Control plane + infrastructure and application workers |
| CNI | Cilium | kube-proxy-free CNI, BGP Control Plane, Gateway API, Hubble |
| GitOps | ArgoCD | Cluster application delivery |
| Platform | Longhorn, Prometheus, Loki, Tempo, Alloy, Tetragon | Storage, observability and security |

## Repository Structure

| Folder | Contents | README |
|--------|----------|--------|
| `requirements/` | ISOs, tooling, offline Terraform bundle, Proxmox API token, CA/certificates, Debian 12 template | [`requirements/Readme.md`](./requirements/Readme.md) |
| `terraform/` | Proxmox connection and VM definitions | [`terraform/Readme.md`](./terraform/Readme.md) |
| `services/` | Ansible roles for the support services (Harbor, Gitea, apt-cacher-ng, FRR, OpenBao) | [`services/Readme.md`](./services/Readme.md) |
| `talos-linux/` | Air-gapped ISO, installer with extensions and cluster configuration | [`talos-linux/Readme.md`](./talos-linux/Readme.md) |
| `infrastructure-applications/` | Charts and manifests running inside the cluster | [`infrastructure-applications/Readme.md`](./infrastructure-applications/Readme.md) |
| `images/` | Diagrams and evidence screenshots | — |

## Deployment Order

### 1. Requirements
**Folder**: [`requirements/`](./requirements/)

ISOs, workstation tools, offline Terraform bundle, Proxmox API token, certificates and the Debian 12 template.

### 2. Provision the VMs
**Folder**: [`terraform/`](./terraform/)

```bash
cd terraform/proxmox-connection/
# Configure the connection (see README)
cd ../code/
terraform init
terraform plan
terraform apply
```

### 3. Support Services
**Folder**: [`services/`](./services/)

`shared-infrastructure` (APT proxy, Docker, certificates) → Harbor → Gitea → apt-cacher-ng → FRR → OpenBao.

### 4. Talos Cluster
**Folder**: [`talos-linux/`](./talos-linux/)

Air-gapped ISO → installer with extensions → cluster configs and bootstrap.

### 5. Infrastructure Applications
**Folder**: [`infrastructure-applications/`](./infrastructure-applications/)

| Order | App | README |
|-------|-----|--------|
| 1 | Cilium (CNI + BGP) | [`cilium/`](./infrastructure-applications/cilium/Readme.md) |
| 2 | Gateway API (Gateways, IP pools) | [`gateway-api/`](./infrastructure-applications/gateway-api/Readme.md) |
| 3 | Longhorn, Metrics Server | [`longhorn/`](./infrastructure-applications/longhorn/Readme.md), [`metrics-server/`](./infrastructure-applications/metrics-server/Readme.md) |
| 4 | ArgoCD (+ AVP image) and its Applications | [`argocd/`](./infrastructure-applications/argocd/Readme.md), [`argocd-docker-build/`](./infrastructure-applications/argocd-docker-build/Readme.md), [`argocd-applications/`](./infrastructure-applications/argocd-applications/Readme.md) |
| 5 | Prometheus Stack | [`prometheus-stack/`](./infrastructure-applications/prometheus-stack/Readme.md) |
| 6 | Loki, Tempo, Grafana Alloy | [`loki/`](./infrastructure-applications/loki/Readme.md), [`tempo/`](./infrastructure-applications/tempo/Readme.md), [`grafana-alloy/`](./infrastructure-applications/grafana-alloy/Readme.md) |
| 7 | Tetragon | [`tetragon/`](./infrastructure-applications/tetragon/Readme.md) |
| 8 | OTel Demo | [`otel-demo/`](./infrastructure-applications/otel-demo/Readme.md) |

## End State

After all the steps you will have:
- **Air-gapped support services**: registry, Git/CI, APT cache, secrets and BGP routing
- **Talos cluster** split into infrastructure and application tiers
- **Cilium** as CNI with LoadBalancer IPs advertised via BGP to FRR
- **GitOps** with ArgoCD reading secrets from OpenBao
- **Full observability**: metrics, logs and traces
