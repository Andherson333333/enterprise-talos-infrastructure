# OTel Demo - Astronomy Shop
![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-Demo_2.2.0-425CC7?style=for-the-badge&logo=opentelemetry&logoColor=white)
![Chart](https://img.shields.io/badge/Chart-0.40.7-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Wrapper chart del OpenTelemetry Demo (Astronomy Shop): una tienda de microservicios instrumentada con OpenTelemetry, usada para validar el stack de observabilidad (Alloy → Tempo / Loki / Prometheus) con tráfico real.

## Componentes

| Componente | Detalle |
|------------|---------|
| Chart base | `opentelemetry-demo` 0.40.7, vía OCI desde `oci://registry.harbor.local/helm-charts` |
| Microservicios | Astronomy Shop en nodos de **aplicación** (`default.schedulingRules`) |
| Collector | OpenTelemetry Collector en modo `deployment`, en nodos de aplicación |
| Frontend | `frontend-proxy` como `ClusterIP` |

### Componentes deshabilitados

El demo trae su propio stack de observabilidad; se deshabilita para usar el del cluster:

| Componente | Reemplazado por |
|------------|-----------------|
| `jaeger` | Tempo (`../tempo/`) |
| `prometheus` | Prometheus Stack (`../prometheus-stack/`) |
| `grafana` | Grafana del Prometheus Stack |
| `opensearch` | Loki (`../loki/`) |

También se deshabilitan los presets del collector (`hostMetrics`, `kubeletMetrics`, `kubernetesAttributes`, `clusterMetrics`).

### Pipelines del Collector

Todo se envía por OTLP a Grafana Alloy (`grafana-alloy.grafana-alloy.svc.cluster.local:4317`):

| Pipeline | Receivers | Exporters |
|----------|-----------|-----------|
| `traces` | `otlp` | `otlp/alloy`, `debug`, `spanmetrics` |
| `metrics` | `spanmetrics` (con exemplars) | `otlp/alloy` |
| `logs` | `otlp` | `otlp/alloy` |

### Scheduling

- `nodeSelector`: `workload-type: application` + `node.talos.dev/tier: application`
- Toleration `workload-type=application:PreferNoSchedule`

## Orden de Despliegue

### 1. Requisitos previos
- Grafana Alloy, Tempo, Loki y Prometheus Stack desplegados
- Workers de aplicación disponibles
- Chart `opentelemetry-demo` 0.40.7 subido a Harbor

### 2. Instalar/Actualizar el Release
```bash
cd infrastructure-applications/otel-demo/
helm dependency update
helm upgrade --install otel-demo . -n otel-demo --create-namespace
```

## Estado de Preparación

Al completar el despliegue tendrás:
- **Astronomy Shop** generando tráfico con el load generator
- **Trazas** en Tempo y **logs** en Loki, consultables desde Grafana
- Service graphs y span metrics (generados por Tempo) en Prometheus

## Verificación

```bash
kubectl get pods -n otel-demo -o wide
```

```bash
kubectl port-forward -n otel-demo svc/frontend-proxy 8080:8080
```

Abrir `http://localhost:8080`. En Grafana → Explore → Tempo, buscar trazas del servicio `frontend`.

## Dependencias

- **Grafana Alloy** (`../grafana-alloy/`) como receptor OTLP
- **Tempo**, **Loki** y **Prometheus Stack** como backends
