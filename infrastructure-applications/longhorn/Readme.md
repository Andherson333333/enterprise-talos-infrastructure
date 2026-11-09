**English** | [Español](./Readme.es.md)

# Longhorn - Distributed Storage
![Longhorn](https://img.shields.io/badge/Longhorn-v1.12.1-5F224B?style=for-the-badge&logo=rancher&logoColor=white)
![Talos](https://img.shields.io/badge/Talos-UserVolume_sdb-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Chart](https://img.shields.io/badge/Chart-1.12.1-0F1689?style=for-the-badge&logo=helm&logoColor=white)

Longhorn wrapper chart as the cluster's distributed block storage, using a dedicated disk (`/dev/sdb`) on each Talos node.

## Components

| Component | Detail |
|-----------|--------|
| Base chart | `longhorn` 1.12.1, via OCI from `oci://registry.harbor.local/helm-charts` |
| Data path | `/var/mnt/sdb-storage` (Talos `sdb-storage` volume) |
| Minimum free space | 2% (`storageMinimalAvailablePercentage`) |
| Over-provisioning | 100% (`storageOverProvisioningPercentage`) |
| Pre-upgrade checker | Disabled (`preUpgradeChecker.jobEnabled: false`) |
| UI | `ClusterIP` Service `longhorn-frontend`, exposed via Gateway API |

### Disk on Talos

The `../../talos-linux/talos-cluster-configs/customs/storage.yml` patch defines a `UserVolumeConfig` named `sdb-storage` on `/dev/sdb` (xfs, 18–32GB). Talos mounts it at `/var/mnt/sdb-storage`, which is Longhorn's `defaultDataPath`.

### Required extensions

The Talos installer includes `iscsi-tools` and `util-linux-tools` (see `../../talos-linux/talos-extensions/`), required by Longhorn.

### Scheduling

The `global` block (infrastructure nodeSelector/tolerations) is commented out in `values.yaml`: Longhorn runs on every node.

## Templates

| File | Detail |
|------|--------|
| `templates/https.yaml` | `HTTPRoute` for `longhorn.local` → `longhorn-frontend:80` via `infra-gateway`, plus HTTP → HTTPS redirect |

## Deployment Order

### 1. Prerequisites
- Talos nodes with the `storage.yml` patch and the installer with extensions
- Gateway API and `infra-gateway` deployed
- `longhorn` 1.12.1 chart pushed to Harbor

### 2. Install/Upgrade the Release
```bash
cd infrastructure-applications/longhorn/
helm dependency update
helm upgrade --install longhorn . -n longhorn-system --create-namespace
```

## Readiness State

After the deployment you will have:
- **Longhorn** managing the `sdb` disk of each node
- `longhorn` StorageClass available for PVCs
- UI at `longhorn.local`

## Verification

```bash
kubectl get pods -n longhorn-system
```

```bash
kubectl get nodes.longhorn.io -n longhorn-system
```

```bash
kubectl get storageclass
```

![Longhorn dashboard](../../images/longhorn-dashboard.png)

## Next Step

Apply the custom StorageClasses from [`storage-classes/`](./storage-classes/Readme.md) (`prometheus-longhorn`, `grafana-longhorn`, `loki-longhorn`, `tempo-longhorn`) used by the observability stack.

## Dependencies

- **Talos** with `storage.yml` and extensions (`../../talos-linux/`)
- **Gateway API** (`../gateway-api/`) for the route
