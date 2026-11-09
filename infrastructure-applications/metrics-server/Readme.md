**English** | [Español](./Readme.es.md)

# Metrics Server - Resource Metrics API
![Metrics Server](https://img.shields.io/badge/Metrics_Server-metrics.k8s.io-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Chart](https://img.shields.io/badge/Chart-3.13.0-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Metrics Server wrapper chart, exposing the `metrics.k8s.io` API with node and pod CPU/memory usage. Used by `kubectl top` and the HorizontalPodAutoscaler.

## Components

| Component | Detail |
|-----------|--------|
| Base chart | `metrics-server` 3.13.0, via OCI from `oci://registry.harbor.local/helm-charts` |
| APIService | `v1beta1.metrics.k8s.io` created, with `insecureSkipTLSVerify: true` |
| Kubelet TLS | `--kubelet-insecure-tls` (Talos kubelets use self-signed certificates) |
| Address types | `InternalIP`, `ExternalIP`, `Hostname` |

### Scheduling

- `nodeSelector`: `workload-type: infrastructure` + `node.talos.dev/type: worker`
- Toleration `workload-type=infrastructure:PreferNoSchedule`

## Deployment Order

### 1. Prerequisites
- Cilium running (CNI)
- `metrics-server` 3.13.0 chart pushed to Harbor

### 2. Install/Upgrade the Release
```bash
cd infrastructure-applications/metrics-server/
helm dependency update
helm upgrade --install metrics-server . -n kube-system
```

## Readiness State

After the deployment you will have:
- `metrics.k8s.io` API available
- `kubectl top nodes` / `kubectl top pods` working
- Foundation for HPA

## Verification

```bash
kubectl get apiservice v1beta1.metrics.k8s.io
```

```bash
kubectl top nodes
```

## Dependencies

- **Cilium** (`../cilium/`) for cluster networking
