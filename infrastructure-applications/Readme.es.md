[English](./Readme.md) | **Español**

# Infrastructure Applications
![Kubernetes](https://img.shields.io/badge/Kubernetes-Talos-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Charts_OCI-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Harbor](https://img.shields.io/badge/Registry-Harbor-60B932?style=for-the-badge&logo=harbor&logoColor=white)

Aplicaciones de plataforma que corren dentro del cluster Talos. Los charts e imágenes se sirven desde Harbor (`oci://registry.harbor.local/helm-charts`), sin acceso a internet.

## Aplicaciones

| Orden | App | Propósito | README |
|-------|-----|-----------|--------|
| 1 | Cilium | CNI sin kube-proxy, BGP Control Plane, Gateway API, Hubble | [`cilium/`](./cilium/Readme.es.md) |
| 2 | Gateway API | Gateways `infra-gateway`/`apps-gateway`, IP pools y TLS (requiere Cilium) | [`gateway-api/`](./gateway-api/Readme.es.md) |
| 3 | Longhorn | Storage distribuido (PVs) | [`longhorn/`](./longhorn/Readme.es.md) |
| 3 | Metrics Server | API `metrics.k8s.io` (`kubectl top`, HPA) | [`metrics-server/`](./metrics-server/Readme.es.md) |
| 4 | ArgoCD (imagen) | Imagen custom con `argocd-vault-plugin` | [`argocd-docker-build/`](./argocd-docker-build/Readme.es.md) |
| 5 | ArgoCD | GitOps en HA, secrets desde OpenBao vía AVP | [`argocd/`](./argocd/Readme.es.md) |
| 6 | Prometheus Stack | Métricas, alertas y Grafana | [`prometheus-stack/`](./prometheus-stack/Readme.es.md) |
| 7 | Loki | Logs | [`loki/`](./loki/Readme.es.md) |
| 8 | Tempo | Trazas | [`tempo/`](./tempo/Readme.es.md) |
| 9 | Grafana Alloy | Recolección de logs, métricas y trazas | [`grafana-alloy/`](./grafana-alloy/Readme.es.md) |
| 10 | Tetragon | Seguridad y observabilidad eBPF | [`tetragon/`](./tetragon/Readme.es.md) |
| 11 | OTel Demo | App de ejemplo (Astronomy Shop) para validar el stack | [`otel-demo/`](./otel-demo/Readme.es.md) |

## Orden de Despliegue

### 1. Red (obligatorio)
Cilium → Gateway API (Gateways e IP pools). Hasta instalar Cilium los nodos quedan `NotReady` (el cluster arranca sin CNI).

### 2. Storage
Longhorn (antes de cualquier app que use PVCs) y Metrics Server.

### 3. GitOps
Imagen de ArgoCD → ArgoCD → [`argocd-applications/`](./argocd-applications/Readme.es.md) (`kubectl apply -f`). Requiere OpenBao operativo (`../services/openbao-server/`).

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
