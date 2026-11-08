# Infrastructure Applications
![Kubernetes](https://img.shields.io/badge/Kubernetes-Talos-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Charts_OCI-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Harbor](https://img.shields.io/badge/Registry-Harbor-60B932?style=for-the-badge&logo=harbor&logoColor=white)

Aplicaciones de plataforma que corren dentro del cluster Talos. Los charts e imágenes se sirven desde Harbor (`oci://registry.harbor.local/helm-charts`), sin acceso a internet.

## Aplicaciones

| Orden | App | Propósito | README |
|-------|-----|-----------|--------|
| 1 | Gateway API | CRDs de Gateway API, requeridas por Cilium | [`gateway-api/`](./gateway-api/Readme.md) |
| 2 | Cilium | CNI sin kube-proxy, BGP Control Plane, Gateway API, Hubble | [`cilium/`](./cilium/Readme.md) |
| 3 | Longhorn | Storage distribuido (PVs) | [`longhorn/`](./longhorn/Readme.md) |
| 4 | ArgoCD (imagen) | Imagen custom con `argocd-vault-plugin` | [`argocd-docker-build/`](./argocd-docker-build/Readme.md) |
| 5 | ArgoCD | GitOps en HA, secrets desde OpenBao vía AVP | [`argocd/`](./argocd/Readme.md) |
| 6 | Prometheus Stack | Métricas, alertas y Grafana | [`prometheus-stack/`](./prometheus-stack/Readme.md) |
| 7 | Loki | Logs | [`loki/`](./loki/Readme.md) |
| 8 | Tempo | Trazas | [`tempo/`](./tempo/Readme.md) |
| 9 | Grafana Alloy | Recolección de logs, métricas y trazas | [`grafana-alloy/`](./grafana-alloy/Readme.md) |
| 10 | Tetragon | Seguridad y observabilidad eBPF | [`tetragon/`](./tetragon/Readme.md) |
| 11 | OTel Demo | App de ejemplo (Astronomy Shop) para validar el stack | [`otel-demo/`](./otel-demo/Readme.md) |

## Orden de Despliegue

### 1. Red (obligatorio)
Gateway API → Cilium. Hasta instalar Cilium los nodos quedan `NotReady` (el cluster arranca sin CNI).

### 2. Storage
Longhorn, antes de cualquier app que use PVCs.

### 3. GitOps
Imagen de ArgoCD → ArgoCD. Requiere OpenBao operativo (`../services/openbao-server/`).

### 4. Observabilidad
Prometheus Stack → Loki y Tempo → Grafana Alloy.

### 5. Seguridad y demo
Tetragon y OTel Demo.

## Verificación

```bash
kubectl get nodes
```

```bash
helm list -A
```

```bash
kubectl get pods -A | grep -vE 'Running|Completed'
```

## Dependencias

- Cluster Talos levantado (`../talos-linux/`)
- Harbor con los charts e imágenes cargados (`../services/harbor-server/`)
- FRR como peer BGP para Cilium (`../services/frr-server/`)
- OpenBao para ArgoCD (`../services/openbao-server/`)
