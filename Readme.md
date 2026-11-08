# Enterprise Talos Infrastructure (Air-Gapped)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Talos](https://img.shields.io/badge/Talos-Linux-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Cilium](https://img.shields.io/badge/Cilium-CNI_%2B_BGP-F8C517?style=for-the-badge&logo=cilium&logoColor=black)
![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)

Plataforma Kubernetes on-premise sobre **Proxmox VE** con **Talos Linux**, diseñada para funcionar en entorno **air-gapped**: todas las imágenes, paquetes, charts y actions se sirven desde servicios internos (Harbor, Gitea, apt-cacher-ng), sin depender de internet una vez preparado el entorno.

## Arquitectura

![Arquitectura general](./images/Arquitectura%20general%20-1.png)
![Arquitectura general](./images/Arquitectura%20general%20-2.png)

## Componentes

| Capa | Componente | Propósito |
|------|------------|-----------|
| Hipervisor | Proxmox VE | Host de todas las VMs |
| IaC | Terraform (provider BPG) | Provisión de VMs desde templates |
| Configuración | Ansible | Instalación de servicios en las VMs de soporte |
| Registry | Harbor (+ Trivy) | Imágenes OCI y Helm charts, proxy cache de Docker Hub |
| Git / CI | Gitea + act_runner | Repositorios, Gitea Actions con actions mirroreadas offline |
| Paquetes | apt-cacher-ng | Cache APT para las VMs Debian |
| Secrets | OpenBao (Raft x3 + HAProxy) | Gestión de secrets, integrado con ArgoCD (AVP) |
| Routing | FRR x2 | Peers BGP para Cilium (anuncio de IPs LoadBalancer vía ECMP) |
| Kubernetes | Talos Linux | Control plane + workers de infraestructura y de aplicación |
| CNI | Cilium | CNI sin kube-proxy, BGP Control Plane, Gateway API, Hubble |
| GitOps | ArgoCD | Despliegue de aplicaciones del cluster |
| Plataforma | Longhorn, Prometheus, Loki, Tempo, Alloy, Tetragon | Storage, observabilidad y seguridad |

## Estructura del Repositorio

| Carpeta | Contenido | README |
|---------|-----------|--------|
| `requirements/` | ISOs, herramientas, bundle Terraform offline, token API Proxmox, CA/certificados, template Debian 12 | [`requirements/Readme.md`](./requirements/Readme.md) |
| `terraform/` | Conexión a Proxmox y definición de las VMs | [`terraform/code/Readme.md`](./terraform/code/Readme.md) |
| `services/` | Roles Ansible de los servicios de soporte (Harbor, Gitea, apt-cacher-ng, FRR, OpenBao) | [`services/Readme.md`](./services/Readme.md) |
| `talos-linux/` | ISO air-gapped, installer con extensions y configuración del cluster | [`talos-linux/Readme.md`](./talos-linux/Readme.md) |
| `infrastructure-applications/` | Charts y manifiestos que corren dentro del cluster | Ver README de cada app |
| `images/` | Diagramas y capturas de evidencia | — |

## Orden de Despliegue

### 1. Requisitos
**Carpeta**: [`requirements/`](./requirements/)

ISOs, herramientas de trabajo, bundle Terraform offline, token de API de Proxmox, certificados y template Debian 12.

### 2. Provisionar VMs
**Carpeta**: [`terraform/`](./terraform/)

```bash
cd terraform/proxmox-connection/
# Configurar conexión (ver README)
cd ../code/
terraform init
terraform plan
terraform apply
```

### 3. Servicios de Soporte
**Carpeta**: [`services/`](./services/)

`shared-infrastructure` (proxy APT, Docker, certificados) → Harbor → Gitea → apt-cacher-ng → FRR → OpenBao.

### 4. Cluster Talos
**Carpeta**: [`talos-linux/`](./talos-linux/)

ISO air-gapped → installer con extensions → configs y bootstrap del cluster.

### 5. Aplicaciones de Infraestructura
**Carpeta**: [`infrastructure-applications/`](./infrastructure-applications/)

| Orden | App | README |
|-------|-----|--------|
| 1 | Gateway API CRDs | [`gateway-api/`](./infrastructure-applications/gateway-api/Readme.md) |
| 2 | Cilium (CNI + BGP) | [`cilium/`](./infrastructure-applications/cilium/Readme.md) |
| 3 | Longhorn | [`longhorn/`](./infrastructure-applications/longhorn/Readme.md) |
| 4 | ArgoCD (+ imagen con AVP) | [`argocd/`](./infrastructure-applications/argocd/Readme.md), [`argocd-docker-build/`](./infrastructure-applications/argocd-docker-build/Readme.md) |
| 5 | Prometheus Stack | [`prometheus-stack/`](./infrastructure-applications/prometheus-stack/Readme.md) |
| 6 | Loki, Tempo, Grafana Alloy | [`loki/`](./infrastructure-applications/loki/Readme.md), [`tempo/`](./infrastructure-applications/tempo/Readme.md), [`grafana-alloy/`](./infrastructure-applications/grafana-alloy/Readme.md) |
| 7 | Tetragon | [`tetragon/`](./infrastructure-applications/tetragon/Readme.md) |
| 8 | OTel Demo | [`otel-demo/`](./infrastructure-applications/otel-demo/Readme.md) |

## Estado Final

Al completar todos los pasos tendrás:
- **Servicios de soporte** air-gapped: registry, Git/CI, cache APT, secrets y routing BGP
- **Cluster Talos** separado en tiers de infraestructura y aplicación
- **Cilium** como CNI con IPs LoadBalancer anunciadas por BGP hacia FRR
- **GitOps** con ArgoCD leyendo secrets desde OpenBao
- **Observabilidad** completa: métricas, logs y trazas

## Notas de Seguridad

No subir al repositorio archivos con secrets (`talosconfig`, configs generadas en `_out/`, llaves `*.key`, passwords o tokens). Ver `.gitignore`.
