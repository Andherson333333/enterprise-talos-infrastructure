[English](./Readme.md) | **Español**

# ArgoCD Applications
![ArgoCD](https://img.shields.io/badge/ArgoCD-Applications-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Gitea](https://img.shields.io/badge/Source-Gitea-609926?style=for-the-badge&logo=gitea&logoColor=white)
![GitOps](https://img.shields.io/badge/GitOps-Auto_Sync-4B8BBE?style=for-the-badge)

Definiciones `Application` de ArgoCD para las aplicaciones de plataforma. Cada una apunta a un repo de Gitea (`gitea.server.local`) que contiene el wrapper chart correspondiente de `../<app>/`.

## Aplicaciones

| Archivo | Application | Repo Gitea | Namespace | Chart en este repo |
|---------|-------------|------------|-----------|--------------------|
| `grafana-alloy.yaml` | `grafana-alloy` | `grafana-alloy` | `grafana-alloy` | [`../grafana-alloy/`](../grafana-alloy/Readme.es.md) |
| `loki.yaml` | `loki` | `loki-helm` | `loki-system` | [`../loki/`](../loki/Readme.es.md) |
| `longhorn.yaml` | `longhorn` | `longhorn-helm` | `longhorn-system` | [`../longhorn/`](../longhorn/Readme.es.md) |
| `storage-classes.yaml` | `storage-classs` | `storage-classs` | `default` | [`../longhorn/storage-classes/`](../longhorn/storage-classes/Readme.es.md) |
| `prometheus-stack.yaml` | `prometheus-stack` | `prometheus-stack-helm` | `monitoring` | [`../prometheus-stack/`](../prometheus-stack/Readme.es.md) |
| `tempo.yaml` | `tempo` | `tempo-helm` | `tempo-system` | [`../tempo/`](../tempo/Readme.es.md) |
| `tetragon.yaml` | `tetragon` | `tetradragon-helm` | `tetragon` | [`../tetragon/`](../tetragon/Readme.es.md) |
| `otel-demo.yaml` | `otel-demo` | `otel-demo` | `otel-demo` | [`../otel-demo/`](../otel-demo/Readme.es.md) |

Cilium, Gateway API, ArgoCD y Metrics Server se instalan con `helm`/`kubectl` directamente (son prerequisitos de ArgoCD o del cluster).

## Configuración común

| Campo | Valor | Detalle |
|-------|-------|---------|
| `targetRevision` | `HEAD` | Rama por defecto del repo de Gitea |
| `syncPolicy.automated` | `prune: true`, `selfHeal: true` | Sincronización automática; borra recursos huérfanos y revierte cambios manuales |
| `syncOptions` | `CreateNamespace=true`, `ServerSideApply=true` | Crea el namespace; SSA evita conflictos con CRDs grandes |
| `managedNamespaceMetadata` | `pod-security.kubernetes.io/*: privileged` | Necesario para componentes eBPF/host (Tetragon, Alloy, Longhorn) |
| `ignoreDifferences` | Campos por defecto de `HTTPRoute` | Evita `OutOfSync` permanente por defaults que agrega el API server |

## Despliegue

```bash
kubectl apply -f infrastructure-applications/argocd-applications/
```

## Verificación

```bash
kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

Todas deben quedar `Synced` / `Healthy`.

## Nota operacional: después de reiniciar el host

Si ArgoCD arranca antes que Harbor (charts OCI) u OpenBao (AVP), las apps quedan en `Unknown` con el error cacheado (`connection refused` a `registry.harbor.local`). Una vez Harbor y OpenBao estén arriba:

```bash
kubectl -n argocd annotate application --all argocd.argoproj.io/refresh=hard --overwrite
```

## Dependencias

- **ArgoCD** instalado (`../argocd/`) con credenciales del repo de Gitea configuradas
- **Harbor** con los charts en `oci://registry.harbor.local/helm-charts`
- **OpenBao** unsealed (para apps que usan AVP)
