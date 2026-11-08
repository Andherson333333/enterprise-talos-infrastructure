# Loki - Log Aggregation
![Loki](https://img.shields.io/badge/Loki-3.7.8-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Mode](https://img.shields.io/badge/Mode-SingleBinary-4B8BBE?style=for-the-badge)
![Chart](https://img.shields.io/badge/Chart-18.13.4-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Wrapper chart de Grafana Loki en modo **SingleBinary** con storage en filesystem (Longhorn), para agregación de logs del cluster en un entorno de laboratorio.

## Componentes

| Componente | Detalle |
|------------|---------|
| Chart base | `loki` 18.13.4, vía OCI desde `oci://registry.harbor.local/helm-charts` |
| Imagen | `registry.harbor.local/proxy-docker/grafana/loki` |
| Modo | `SingleBinary`, 1 réplica (read/write/backend en 0) |
| Storage | `filesystem` sobre PVC 2Gi (`loki-longhorn`) |
| Schema | `tsdb` v13, índice cada 24h |
| Retención | `4h`, aplicada por el compactor |
| Ingesta | 16 MB/s (burst 32), 10000 streams, líneas hasta 256kb |
| Auth | Deshabilitado (`auth_enabled: false`, single tenant) |
| ServiceMonitor | Habilitado para scraping desde Prometheus |

### Componentes deshabilitados

| Componente | Motivo |
|------------|--------|
| `chunksCache` / `resultsCache` | No necesarios en SingleBinary de laboratorio |
| `gateway` | Se expone vía HTTPRoute directo |
| `selfMonitoring`, `lokiCanary`, `test` | Reducir consumo de recursos |

### Scheduling

- `nodeSelector`: `workload-type: infrastructure` + `node.talos.dev/tier: infrastructure`
- Toleration `workload-type=infrastructure:PreferNoSchedule`

## Orden de Despliegue

### 1. Requisitos previos
- Longhorn y la StorageClass `loki-longhorn` creadas
- Prometheus Stack desplegado (CRD `ServiceMonitor`)
- Chart `loki` 18.13.4 subido a Harbor

### 2. Instalar/Actualizar el Release
```bash
cd infrastructure-applications/loki/
helm dependency update
helm upgrade --install loki . -n monitoring --create-namespace
```

## Estado de Preparación

Al completar el despliegue tendrás:
- **Loki** recibiendo logs en el puerto `3100`
- Retención automática de 4h
- Métricas de Loki disponibles en Prometheus

## Verificación

```bash
kubectl get pods -n monitoring -l app.kubernetes.io/name=loki
```

```bash
kubectl get pvc -n monitoring | grep loki
```

```bash
kubectl port-forward -n monitoring svc/loki 3100:3100
```

```bash
curl -s http://localhost:3100/ready
```

## Siguiente Paso

Desplegar Grafana Alloy (`../grafana-alloy/`) para enviar los logs de los nodos y pods a Loki.

## Dependencias

- **Longhorn** (`../longhorn/`) para el PVC
- **Prometheus Stack** (`../prometheus-stack/`) para el ServiceMonitor y Grafana
