**English** | [Español](./Readme.es.md)

# OpenBao - Raft Node Installation
![OpenBao](https://img.shields.io/badge/OpenBao-Vault_Fork-FFEC6E?style=for-the-badge)
![Raft](https://img.shields.io/badge/Storage-Raft_Integrated-4B8BBE?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-13-A81D33?style=for-the-badge&logo=debian&logoColor=white)

This README applies to all 3 cluster nodes (`open-bao-1`, `open-bao-2`, `open-bao-3`). The procedure is identical — only the IP, hostname and `node_id` in `openbao.hcl` change. It is not repeated in the other folders.

## Per-node Specifications

| Node | IP | node_id |
|------|-----|---------|
| open-bao-1 | 192.168.253.30 | open-bao-1 |
| open-bao-2 | 192.168.253.31 | open-bao-2 |
| open-bao-3 | 192.168.253.32 | open-bao-3 |

- VM: Debian 13, 2 vCPU / 2GB RAM
- Storage: dedicated 10GB disk, partitioned and mounted at `/opt/openbao/data`

## Deployment Order

### 1. Provision the VM
See `../../../terraform/` for the base deployment, or create it manually from the Debian 13 template.

### 2. Generate a Multi-SAN Certificate
**Folder**: [`../../../requirements/certificate-server-config/`](../../../requirements/certificate-server-config/)

A single certificate covering the 3 IPs + hostnames (without SANs, Go TLS rejects validation):
```bash
# Generated on certificate-server with mkcert + Harbor CA
# Output in /opt/generated_certs/openbao/
```

### 3. Install OpenBao
```bash
# Download the binary/package on pve-1 (internet) and transfer it, or via apt-cacher-ng
apt install openbao
```

### 4. Apply Configuration
Copy `openbao.hcl` from this folder (adjusting IP/node_id for each node) to `/etc/openbao/openbao.hcl`:
```bash
systemctl enable --now openbao
```

### 5. Initialize the Cluster (only once, from open-bao-1)
```bash
bao operator init
# 5 Shamir unseal keys, threshold 3
```

### 6. Join and Unseal the Other Nodes
```bash
# On open-bao-2 and open-bao-3
bao operator raft join https://192.168.253.30:8200
bao operator unseal
```

### 7. Enable the Secrets Engine and AppRole
```bash
bao secrets enable -path=secret kv-v2
bao auth enable approle
# Read-only policy on secret/data/* and secret/metadata/* for ArgoCD
```

## Readiness State

After all the steps you will have:
- **3 nodes** in a Raft cluster, unsealed
- **KV v2** enabled at `secret/`
- **AppRole** ready for ArgoCD

## Verification

```bash
bao operator status
bao kv get secret/test
```

## Next Step

- **`../proxy-open-bao/`** - Configure HAProxy as the HA endpoint

## Dependencies

- **Step 2** requires certificates generated before installing
- **Step 5** runs only once, from the first node brought up
- **Step 6** requires open-bao-1 to be already initialized
