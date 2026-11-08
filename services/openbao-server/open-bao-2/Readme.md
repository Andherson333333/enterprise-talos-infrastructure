# OpenBao - open-bao-2

Nodo Raft `open-bao-2` (`192.168.253.31`). El procedimiento de instalación es el mismo que en [`open-bao-1`](../open-bao-1/Readme.md).

Solo cambia `openbao.hcl` de esta carpeta: `node_id`, `api_addr`, `cluster_addr` y las IPs de `retry_join`.

Se une al cluster con:

```bash
bao operator raft join https://192.168.253.30:8200
```

```bash
bao operator unseal
```
