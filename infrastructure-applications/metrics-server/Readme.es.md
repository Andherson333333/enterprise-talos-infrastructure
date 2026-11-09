[English](./Readme.md) | **Español**

# Metrics Server - Resource Metrics API
![Metrics Server](https://img.shields.io/badge/Metrics_Server-metrics.k8s.io-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Chart](https://img.shields.io/badge/Chart-3.13.0-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Wrapper chart de Metrics Server, que expone la API `metrics.k8s.io` con el uso de CPU/memoria de nodos y pods. Lo usan `kubectl top` y el HorizontalPodAutoscaler.

## Componentes

| Componente | Detalle |
|------------|---------|
| Chart base | `metrics-server` 3.13.0, vía OCI desde `oci://registry.harbor.local/helm-charts` |
| APIService | `v1beta1.metrics.k8s.io` creado, con `insecureSkipTLSVerify: true` |
| Kubelet TLS | `--kubelet-insecure-tls` (los kubelets de Talos usan certificados autofirmados) |
| Address types | `InternalIP`, `ExternalIP`, `Hostname` |

### Scheduling

- `nodeSelector`: `workload-type: infrastructure` + `node.talos.dev/type: worker`
- Toleration `workload-type=infrastructure:PreferNoSchedule`

## Orden de Despliegue

### 1. Requisitos previos
- Cilium operativo (CNI)
- Chart `metrics-server` 3.13.0 subido a Harbor

### 2. Instalar/Actualizar el Release
```bash
cd infrastructure-applications/metrics-server/
helm dependency update
helm upgrade --install metrics-server . -n kube-system
```

## Estado de Preparación

Al completar el despliegue tendrás:
- API `metrics.k8s.io` disponible
- `kubectl top nodes` / `kubectl top pods` funcionando
- Base para HPA

## Verificación

```bash
kubectl get apiservice v1beta1.metrics.k8s.io
```

```bash
kubectl top nodes
```

## Dependencias

- **Cilium** (`../cilium/`) para la red del cluster
