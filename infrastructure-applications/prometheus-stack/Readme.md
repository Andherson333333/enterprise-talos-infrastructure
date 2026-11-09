**English** | [Español](./Readme.es.md)

# Prometheus Stack (kube-prometheus-stack)
![Prometheus](https://img.shields.io/badge/Prometheus-Metrics-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-Dashboards-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Alertmanager](https://img.shields.io/badge/Alertmanager-Alerts-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Chart](https://img.shields.io/badge/Chart-92.3.0-0F1689?style=for-the-badge&logo=helm&logoColor=white)

`kube-prometheus-stack` wrapper chart with Prometheus, Grafana and Alertmanager, deployed on the infrastructure nodes and exposed via Gateway API.

## Components

| Component | Detail |
|-----------|--------|
| Base chart | `kube-prometheus-stack` 92.3.0, via OCI from `oci://registry.harbor.local/helm-charts` |
| Prometheus | `4h` retention, 2Gi PVC (`prometheus-longhorn`), `enableRemoteWriteReceiver: true` |
| Grafana | 2Gi PVC (`grafana-longhorn`), datasource sidecar (label `grafana_datasource: "1"`), Drilldown apps enabled |
| Alertmanager | `4h` retention, 1Gi PVC (`longhorn`) |
| Prometheus Operator | Infrastructure nodes |
| kube-state-metrics | Infrastructure nodes |
| Node Exporter | DaemonSet on **all** nodes (`tolerations: Exists`) |

### Scheduling

Every component (except Node Exporter) uses:
- `nodeSelector`: `workload-type: infrastructure` + `node.talos.dev/tier: infrastructure`
- Toleration `workload-type=infrastructure:PreferNoSchedule`

### Remote Write

`enableRemoteWriteReceiver` enables the `/api/v1/write` endpoint so Grafana Alloy and Tempo (metrics generator) can push metrics to Prometheus.

### Datasources

The Grafana sidecar automatically loads `ConfigMap`s labelled `grafana_datasource: "1"`. Loki and Tempo are defined in `templates/datasources.yaml`.

## Templates

| File | Detail |
|------|--------|
| `templates/https.yaml` | `HTTPRoute` via `infra-gateway` (`https` section) + HTTP → HTTPS redirect (`http` section) |
| `templates/datasources.yaml` | ConfigMap with the Loki and Tempo datasources (fixed UIDs, traces→logs and service map) |

| Host | Service | Port |
|------|---------|------|
| `grafana.local` | `prometheus-stack-grafana` | 80 |
| `prometheus.local` | `prometheus-stack-kube-prom-prometheus` | 9090 |
| `alertmanager.local` | `prometheus-stack-kube-prom-alertmanager` | 9093 |

## Deployment Order

### 1. Prerequisites
- Longhorn and the `prometheus-longhorn` / `grafana-longhorn` StorageClasses created
- Gateway API and `infra-gateway` deployed
- `kube-prometheus-stack` 92.3.0 chart pushed to Harbor

### 2. Install/Upgrade the Release
The release name must be `prometheus-stack` (the routes' Service names depend on it).

```bash
cd infrastructure-applications/prometheus-stack/
helm dependency update
helm upgrade --install prometheus-stack . -n monitoring --create-namespace --set kube-prometheus-stack.grafana.adminPassword=YOUR_PASSWORD
```

## Readiness State

After the deployment you will have:
- **Prometheus** scraping cluster metrics and receiving remote write
- **Grafana** at `grafana.local` with the Loki and Tempo datasources
- **Alertmanager** at `alertmanager.local`
- **Node Exporter** on every node

## Verification

```bash
kubectl get pods -n monitoring -o wide
```

```bash
kubectl get pvc -n monitoring
```

```bash
kubectl get httproute -n monitoring
```

![Prometheus targets](../../images/prometheus-targets.png)

## Next Step

Deploy Loki and Tempo (`../loki/`, `../tempo/`) and then Grafana Alloy (`../grafana-alloy/`) to complete the observability stack.

## Dependencies

- **Longhorn** (`../longhorn/`) and the custom StorageClasses for the PVCs
- **Gateway API** (`../gateway-api/`) for the routes
- The Grafana `adminPassword` is a placeholder (`CHANGE_ME`): pass it with `--set` at install time
