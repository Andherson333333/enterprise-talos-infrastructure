# BGP Control Plane
![BGP](https://img.shields.io/badge/BGP-Control_Plane-4B8BBE?style=for-the-badge)
![ECMP](https://img.shields.io/badge/ECMP-Load_Distribution-60B932?style=for-the-badge)

Manifiestos de Cilium BGP Control Plane, en reemplazo de L2 announcements, para anunciar IPs de LoadBalancer vía ECMP hacia FRR.

## Recursos

| Archivo | Kind | Detalle |
|---------|------|---------|
| `bgp-cluster-infra.yaml` | `CiliumBGPClusterConfig` | Nodos `workload-type: infrastructure`, ASN local 65001 |
| `bgp-cluster-app.yaml` | `CiliumBGPClusterConfig` | Nodos `workload-type: application`, ASN local 65001 |
| `bgp-peer-config-infra.yaml` | `CiliumBGPPeerConfig` | Graceful restart, timers, selector de advertisements `bgp-infra` |
| `bgp-peer-config-app.yaml` | `CiliumBGPPeerConfig` | Graceful restart, timers, selector de advertisements `bgp-app` |
| `bgp-advertisement-infra.yaml` | `CiliumBGPAdvertisement` | Anuncia `LoadBalancerIP` de Services que matchean `infra-gateway` |
| `bgp-advertisement-app.yaml` | `CiliumBGPAdvertisement` | Anuncia `LoadBalancerIP` de Services que matchean `apps-gateway` |

## Peers BGP

| Peer | IP | ASN |
|------|-----|-----|
| frr-01 | 192.168.253.20 | 65000 |
| frr-02 | 192.168.253.21 | 65000 |

Nodos Cilium: ASN 65001. Timers: `connectRetry` 5s, `holdTime` 9s, `keepAlive` 3s, graceful restart 120s.

## Verificación

```bash
cilium bgp peers
cilium bgp routes
```

## Dependencias

- FRR (`frr-01`/`frr-02`) configurado como peer BGP en AS 65000, fuera de este repo
- Los `CiliumBGPAdvertisement` requieren Services con labels que matcheen `gateway.networking.k8s.io/gateway-name` (ver `../../gateway-api/`)
