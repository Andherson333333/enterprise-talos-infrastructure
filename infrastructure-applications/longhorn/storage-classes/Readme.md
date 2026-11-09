**English** | [Español](./Readme.es.md)

# Storage Classes - Observability
![Longhorn](https://img.shields.io/badge/Longhorn-StorageClass-5F224B?style=for-the-badge&logo=rancher&logoColor=white)

Longhorn StorageClasses dedicated to the observability stack, with replicas only on infrastructure nodes.

## Resources

| File | StorageClass | Used by |
|------|--------------|---------|
| `prometheus-storageclass.yaml` | `prometheus-longhorn` | Prometheus (`../../prometheus-stack/`) |
| `grafana-storageclass.yaml` | `grafana-longhorn` | Grafana (`../../prometheus-stack/`) |
| `loki-storageclass.yaml` | `loki-longhorn` | Loki (`../../loki/`) |
| `tempo-storageclass.yaml` | `tempo-longhorn` | Tempo (`../../tempo/`) |

## Common parameters

| Parameter | Value | Detail |
|-----------|-------|--------|
| `numberOfReplicas` | `2` | Replicas per volume |
| `nodeSelector` | `infrastructure` | Replicas only on Longhorn nodes tagged `infrastructure` |
| `dataLocality` | `best-effort` | Tries to keep one replica on the pod's node |
| `fsType` | `ext4` | |
| `reclaimPolicy` | `Retain` | The volume is not deleted when the PVC is removed |
| `allowVolumeExpansion` | `true` | |

`tempo-longhorn` also attaches its volumes to the `prometheus-monitoring` recurring job group (commented out in `loki-longhorn`).

## Longhorn node tags

The StorageClasses' `nodeSelector: "infrastructure"` refers to Longhorn node tags (not Kubernetes labels):

| Node | Tag |
|------|-----|
| `talos-infrastructure-dt-01` | `infrastructure` |
| `talos-infrastructure-dt-02` | `infrastructure` |
| `talos-infrastructure-dt-03` | `infrastructure` |
| `talos-application-dt-01` / `02` | — |

Assign the tag (or via UI → Node → Edit node → Node Tags):

```bash
for n in 01 02 03; do kubectl -n longhorn-system patch nodes.longhorn.io talos-infrastructure-dt-$n --type merge -p '{"spec":{"tags":["infrastructure"]}}'; done
```

Verify:

```bash
kubectl -n longhorn-system get nodes.longhorn.io -o custom-columns=NAME:.metadata.name,TAGS:.spec.tags
```

## Deployment

```bash
kubectl apply -f infrastructure-applications/longhorn/storage-classes/
```

## Verification

```bash
kubectl get storageclass
```

![StorageClasses](../../../images/storage-classes.png)

## Dependencies

- Longhorn deployed (`../`)
- Infrastructure nodes tagged `infrastructure` in Longhorn (UI → Node → Edit node → Node Tags)
- `prometheus-monitoring` recurring job group created in Longhorn, for `tempo-longhorn`
- With `reclaimPolicy: Retain`, released PVs must be deleted manually
