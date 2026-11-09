**English** | [Español](./Readme.es.md)

# Talos Linux - Air-Gapped Kubernetes Cluster
![Talos](https://img.shields.io/badge/Talos-v1.10-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Air-Gapped](https://img.shields.io/badge/Mode-Air--Gapped-4B8BBE?style=for-the-badge)

Everything needed to bring up the Talos cluster without internet access: ISO with cached images, installer with system extensions and node configuration.

![Talos VM](../images/talos-linux-vm.png)

## Contents

| Folder | Purpose | README |
|--------|---------|--------|
| `talos-base-airgap/` | Builds the Talos ISO with an OCI cache of the base images | [`talos-base-airgap/Readme.md`](./talos-base-airgap/Readme.md) |
| `talos-extensions/` | Builds a custom installer with system extensions, pushed to Harbor | [`talos-extensions/Readme.md`](./talos-extensions/Readme.md) |
| `talos-cluster-configs/` | Config generation, per-node patches, bootstrap and kubeconfig | [`talos-cluster-configs/Readme.md`](./talos-cluster-configs/Readme.md) |
| `talos-cluster-configs/customs/` | Patches: base, control plane, infra/app workers, registry mirrors, storage, CNI none, logging | [`customs/Readme.md`](./talos-cluster-configs/customs/Readme.md) |

## Topology

| Node | IP | Role |
|------|-----|------|
| API VIP | 192.168.253.100 | Endpoint `https://192.168.253.100:6443` |
| control-plane-1 | 192.168.253.101 | Control plane |
| worker-1..n | 192.168.253.111+ | Workers (`workload-type: infrastructure` / `application`) |

The VMs are created with Terraform (`../terraform/code/vm-taloscp-infra.tf`, `vm-talosdt-infra.tf`, `vm-talosdt-application.tf`) from template 9000.

## Deployment Order

### 1. Build the air-gapped ISO
```bash
cd talos-base-airgap/
# Follow the README: extract images → OCI cache → ISO
```

### 2. Build the installer with extensions
```bash
cd talos-extensions/
# Follow the README: cache → installer → push to Harbor
```

### 3. Configure and bring up the cluster
```bash
cd talos-cluster-configs/
talosctl gen config promox-cluster https://192.168.253.100:6443 \
  -f --with-docs=false --install-disk /dev/sda --output-dir _out
# Apply configs with the customs/ patches (see comands and README)
talosctl bootstrap --nodes 192.168.253.101
talosctl kubeconfig --nodes 192.168.253.101
```

The cluster boots **without a CNI** (`cni-none.yaml`); nodes stay `NotReady` until Cilium is installed.

## Verification

```bash
talosctl health --nodes 192.168.253.101
```

```bash
kubectl get nodes -o wide
```

## Next Step

Install Cilium and then Gateway API from [`../infrastructure-applications/`](../infrastructure-applications/).

## Dependencies

- Harbor running (registry mirrors and custom installer)
- VMs created with Terraform
- **Important**: `_out/` contains the cluster CAs and tokens, it must not be committed to Git
