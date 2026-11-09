# Tempo - Distributed Tracing
![Tempo](https://img.shields.io/badge/Tempo-2.10.1-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Mode](https://img.shields.io/badge/Mode-Monolithic-4B8BBE?style=for-the-badge)
![Chart](https://img.shields.io/badge/Chart-2.0.0-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Wrapper chart de Grafana Tempo en modo monolítico, backend de trazas del cluster. Recibe trazas OTLP desde Grafana Alloy y genera métricas (service graphs, span metrics) que envía a Prometheus vía remote write.

## Componentes

| Componente | Detalle |
|------------|---------|
| Chart base | `grafana-community/tempo` 2.0.0, vía OCI desde `oci://registry.harbor.local/helm-charts` |
| Imagen | `grafana/tempo:2.10.1` |
| Réplicas | 1 (monolítico) |
| Storage | Backend `local` sobre PVC 4Gi (`tempo-longhorn`) |
| Retención | `168h` (7 días) |
| Receivers | OTLP gRPC `:4317` / HTTP `:4318`, Jaeger thrift_http `:14268` / gRPC `:14250` |
| API | `:3200` (query desde Grafana) |
| ServiceMonitor | Habilitado (`release: prometheus-stack`) |

### Metrics Generator

| Processor | Dimensiones |
|-----------|-------------|
| `service-graphs` | `k8s.namespace.name`, `k8s.deployment.name` |
| `span-metrics` | `k8s.namespace.name`, `k8s.deployment.name`, `service.name` |
| `local-blocks` | `filter_server_spans: false` (TraceQL metrics) |

Remote write: `http://prometheus-stack-kube-prom-prometheus.monitoring.svc.cluster.local:9090/api/v1/write` (requiere `enableRemoteWriteReceiver` en Prometheus). Límite de 100000 series activas.

### Estructura del values

El chart usa doble anidado:

```yaml
tempo:          # dependencia → top-level del subchart (replicas, persistence, ...)
  tempo:        # .Values.tempo.* del subchart (imagen, receivers, storage, ...)
```

### Scheduling

- `nodeSelector`: `workload-type: infrastructure` + `node.talos.dev/tier: infrastructure`
- Toleration `workload-type=infrastructure:PreferNoSchedule`

## Orden de Despliegue

### 1. Requisitos previos
- Longhorn y la StorageClass `tempo-longhorn` creadas
- Prometheus Stack con `enableRemoteWriteReceiver: true`
- Chart `tempo` 2.0.0 subido a Harbor

### 2. Instalar/Actualizar el Release
El release y el namespace deben coincidir con el endpoint que usa Alloy (`tempo.tempo-system.svc`).

```bash
cd infrastructure-applications/tempo/
helm dependency update
helm upgrade --install tempo . -n tempo-system --create-namespace
```

## Estado de Preparación

Al completar el despliegue tendrás:
- **Tempo** recibiendo trazas OTLP y Jaeger
- **Service graphs** y **span metrics** en Prometheus
- Trazas consultables desde Grafana (datasource Tempo, puerto `3200`)

## Verificación

```bash
kubectl get pods,pvc -n tempo-system
```

```bash
kubectl port-forward -n tempo-system svc/tempo 3200:3200
```

```bash
curl -s http://localhost:3200/ready
```

![Trazas en Tempo](../../images/tempo-traces.png)
![Service graph](../../images/tempo-service-graph-2.png)

## Siguiente Paso

Desplegar Grafana Alloy (`../grafana-alloy/`) para enviar trazas a Tempo.

## Dependencias

- **Longhorn** (`../longhorn/`) para el PVC
- **Prometheus Stack** (`../prometheus-stack/`) para remote write y ServiceMonitor
