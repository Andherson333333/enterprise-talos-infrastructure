**English** | [Español](./Readme.es.md)

# OpenBao - open-bao-3

Raft node `open-bao-3` (`192.168.253.32`). The installation procedure is the same as in [`open-bao-1`](../open-bao-1/Readme.md).

Only `openbao.hcl` in this folder changes: `node_id`, `api_addr`, `cluster_addr` and the `retry_join` IPs.

Join the cluster with:

```bash
bao operator raft join https://192.168.253.30:8200
```

```bash
bao operator unseal
```
