**English** | [Español](./Readme.es.md)

# Tetragon - eBPF Security Enforcement
![Tetragon](https://img.shields.io/badge/Tetragon-1.7.1-F8C517?style=for-the-badge&logo=cilium&logoColor=black)
![eBPF](https://img.shields.io/badge/eBPF-Runtime_Security-4B8BBE?style=for-the-badge)
![Chart](https://img.shields.io/badge/Chart-1.7.1-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Tetragon wrapper chart for eBPF-based runtime security observability and enforcement (processes, syscalls, network and files) on every cluster node.

## Components

| Component | Detail |
|-----------|--------|
| Base chart | `tetragon` 1.7.1, via OCI from `oci://registry.harbor.local/helm-charts` |
| Agent | DaemonSet on **all** nodes (`tolerations: Exists`), image `registry.harbor.local/proxy-ghcr/cilium/tetragon` |
| Operator | Image `registry.harbor.local/proxy-ghcr/cilium/tetragon-operator`, infrastructure nodes |
| Export | JSON export file disabled (`exportFilename: ""`) |
| Metrics | Agent on `:2112`, ServiceMonitor enabled |

### Resources

| Component | Requests | Limits |
|-----------|----------|--------|
| Agent | 100m / 128Mi | 500m / 512Mi |
| Operator | 50m / 64Mi | 200m / 256Mi |

## Deployment Order

### 1. Prerequisites
- Prometheus Stack deployed (`ServiceMonitor` CRD)
- `tetragon` 1.7.1 chart pushed to Harbor

### 2. Install/Upgrade the Release
```bash
cd infrastructure-applications/tetragon/
helm dependency update
helm upgrade --install tetragon . -n tetragon
```

## Readiness State

After the deployment you will have:
- **Tetragon** observing security events on every node
- **TracingPolicy** CRDs available to define policies
- Metrics in Prometheus

## Verification

```bash
kubectl get ds,deploy -n tetragon | grep tetragon
```

```bash
kubectl get crd | grep cilium.io | grep -i tracingpolic
```

```bash
kubectl logs -n tetragon ds/tetragon -c export-stdout --tail 5
```

![Tetragon events (real-time process/exit)](../../images/tetragon-events.png)

## Dependencies

- **Prometheus Stack** (`../prometheus-stack/`) for the ServiceMonitors
