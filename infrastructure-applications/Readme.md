**English** | [Español](./Readme.es.md)

# Infrastructure Applications
![Kubernetes](https://img.shields.io/badge/Kubernetes-Talos-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Charts_OCI-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Harbor](https://img.shields.io/badge/Registry-Harbor-60B932?style=for-the-badge&logo=harbor&logoColor=white)

Platform applications running inside the Talos cluster. Charts and images are served from Harbor (`oci://registry.harbor.local/helm-charts`), without internet access.

## Applications

| Order | App | Purpose | README |
|-------|-----|---------|--------|
| 1 | Cilium | kube-proxy-free CNI, BGP Control Plane, Gateway API, Hubble | [`cilium/`](./cilium/Readme.md) |
| 2 | Gateway API | `infra-gateway`/`apps-gateway` Gateways, IP pools and TLS (requires Cilium) | [`gateway-api/`](./gateway-api/Readme.md) |
| 3 | Longhorn | Distributed storage (PVs) | [`longhorn/`](./longhorn/Readme.md) |
| 3 | Metrics Server | `metrics.k8s.io` API (`kubectl top`, HPA) | [`metrics-server/`](./metrics-server/Readme.md) |
| 4 | ArgoCD (image) | Custom image with `argocd-vault-plugin` | [`argocd-docker-build/`](./argocd-docker-build/Readme.md) |
| 5 | ArgoCD | HA GitOps, secrets from OpenBao via AVP | [`argocd/`](./argocd/Readme.md) |
| 6 | Prometheus Stack | Metrics, alerts and Grafana | [`prometheus-stack/`](./prometheus-stack/Readme.md) |
| 7 | Loki | Logs | [`loki/`](./loki/Readme.md) |
| 8 | Tempo | Traces | [`tempo/`](./tempo/Readme.md) |
| 9 | Grafana Alloy | Log, metric and trace collection | [`grafana-alloy/`](./grafana-alloy/Readme.md) |
| 10 | Tetragon | eBPF security and observability | [`tetragon/`](./tetragon/Readme.md) |
| 11 | OTel Demo | Sample app (Astronomy Shop) to validate the stack | [`otel-demo/`](./otel-demo/Readme.md) |

## Deployment Order

### 1. Network (required)
Cilium → Gateway API (Gateways and IP pools). Until Cilium is installed the nodes stay `NotReady` (the cluster boots without a CNI).

### 2. Storage
Longhorn (before any app that uses PVCs) and Metrics Server.

### 3. GitOps
ArgoCD image → ArgoCD → [`argocd-applications/`](./argocd-applications/Readme.md) (`kubectl apply -f`). Requires OpenBao running (`../services/openbao-server/`).

### 4. Observability
Prometheus Stack → Loki and Tempo → Grafana Alloy.

### 5. Security and demo
Tetragon and OTel Demo.

## Verification

```bash
kubectl get nodes
```

```bash
helm list -A
```

```bash
kubectl get pods -A | grep -vE 'Running|Completed'
```

## Dependencies

- Talos cluster up (`../talos-linux/`)
- Harbor with charts and images loaded (`../services/harbor-server/`)
- FRR as BGP peer for Cilium (`../services/frr-server/`)
- OpenBao for ArgoCD (`../services/openbao-server/`)
