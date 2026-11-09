**English** | [Español](./Readme.es.md)

# BGP Control Plane
![BGP](https://img.shields.io/badge/BGP-Control_Plane-4B8BBE?style=for-the-badge)
![ECMP](https://img.shields.io/badge/ECMP-Load_Distribution-60B932?style=for-the-badge)

Cilium BGP Control Plane manifests, replacing L2 announcements, to advertise LoadBalancer IPs via ECMP towards FRR.

## Resources

| File | Kind | Detail |
|------|------|--------|
| `bgp-cluster-infra.yaml` | `CiliumBGPClusterConfig` | `workload-type: infrastructure` nodes, local ASN 65001 |
| `bgp-cluster-app.yaml` | `CiliumBGPClusterConfig` | `workload-type: application` nodes, local ASN 65001 |
| `bgp-peer-config-infra.yaml` | `CiliumBGPPeerConfig` | Graceful restart, timers, `bgp-infra` advertisement selector |
| `bgp-peer-config-app.yaml` | `CiliumBGPPeerConfig` | Graceful restart, timers, `bgp-app` advertisement selector |
| `bgp-advertisement-infra.yaml` | `CiliumBGPAdvertisement` | Advertises `LoadBalancerIP` of Services matching `infra-gateway` |
| `bgp-advertisement-app.yaml` | `CiliumBGPAdvertisement` | Advertises `LoadBalancerIP` of Services matching `apps-gateway` |

## BGP peers

| Peer | IP | ASN |
|------|-----|-----|
| frr-01 | 192.168.253.20 | 65000 |
| frr-02 | 192.168.253.21 | 65000 |

Cilium nodes: ASN 65001. Timers: `connectRetry` 5s, `holdTime` 9s, `keepAlive` 3s, graceful restart 120s.

## Verification

```bash
cilium bgp peers
cilium bgp routes
```

## Dependencies

- FRR (`frr-01`/`frr-02`) configured as BGP peer in AS 65000, outside this repo
- `CiliumBGPAdvertisement` resources require Services with labels matching `gateway.networking.k8s.io/gateway-name` (see `../../gateway-api/`)
