**English** | [Español](./Readme.es.md)

# ArgoCD Applications
![ArgoCD](https://img.shields.io/badge/ArgoCD-Applications-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Gitea](https://img.shields.io/badge/Source-Gitea-609926?style=for-the-badge&logo=gitea&logoColor=white)
![GitOps](https://img.shields.io/badge/GitOps-Auto_Sync-4B8BBE?style=for-the-badge)

ArgoCD `Application` definitions for the platform applications. Each one points to a Gitea repo (`gitea.server.local`) containing the matching wrapper chart from `../<app>/`.

## Applications

| File | Application | Gitea repo | Namespace | Chart in this repo |
|------|-------------|------------|-----------|--------------------|
| `grafana-alloy.yaml` | `grafana-alloy` | `grafana-alloy` | `grafana-alloy` | [`../grafana-alloy/`](../grafana-alloy/Readme.md) |
| `loki.yaml` | `loki` | `loki-helm` | `loki-system` | [`../loki/`](../loki/Readme.md) |
| `longhorn.yaml` | `longhorn` | `longhorn-helm` | `longhorn-system` | [`../longhorn/`](../longhorn/Readme.md) |
| `storage-classes.yaml` | `storage-classs` | `storage-classs` | `default` | [`../longhorn/storage-classes/`](../longhorn/storage-classes/Readme.md) |
| `prometheus-stack.yaml` | `prometheus-stack` | `prometheus-stack-helm` | `monitoring` | [`../prometheus-stack/`](../prometheus-stack/Readme.md) |
| `tempo.yaml` | `tempo` | `tempo-helm` | `tempo-system` | [`../tempo/`](../tempo/Readme.md) |
| `tetragon.yaml` | `tetragon` | `tetradragon-helm` | `tetragon` | [`../tetragon/`](../tetragon/Readme.md) |
| `otel-demo.yaml` | `otel-demo` | `otel-demo` | `otel-demo` | [`../otel-demo/`](../otel-demo/Readme.md) |

Cilium, Gateway API, ArgoCD and Metrics Server are installed directly with `helm`/`kubectl` (they are prerequisites of ArgoCD or of the cluster).

## Common configuration

| Field | Value | Detail |
|-------|-------|--------|
| `targetRevision` | `HEAD` | Default branch of the Gitea repo |
| `syncPolicy.automated` | `prune: true`, `selfHeal: true` | Automatic sync; removes orphaned resources and reverts manual changes |
| `syncOptions` | `CreateNamespace=true`, `ServerSideApply=true` | Creates the namespace; SSA avoids conflicts with large CRDs |
| `managedNamespaceMetadata` | `pod-security.kubernetes.io/*: privileged` | Required by eBPF/host components (Tetragon, Alloy, Longhorn) |
| `ignoreDifferences` | `HTTPRoute` default fields | Avoids a permanent `OutOfSync` caused by defaults added by the API server |

## Deployment

```bash
kubectl apply -f infrastructure-applications/argocd-applications/
```

## Verification

```bash
kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

All of them must end up `Synced` / `Healthy`.

## Operational note: after rebooting the host

If ArgoCD starts before Harbor (OCI charts) or OpenBao (AVP), apps stay `Unknown` with a cached error (`connection refused` to `registry.harbor.local`). Once Harbor and OpenBao are up:

```bash
kubectl -n argocd annotate application --all argocd.argoproj.io/refresh=hard --overwrite
```

## Dependencies

- **ArgoCD** installed (`../argocd/`) with the Gitea repo credentials configured
- **Harbor** with the charts at `oci://registry.harbor.local/helm-charts`
- **OpenBao** unsealed (for apps using AVP)
