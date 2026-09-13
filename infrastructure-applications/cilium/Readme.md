# Cilium - CNI + BGP Control Plane
![Cilium](https://img.shields.io/badge/Cilium-v1.19.1-EF7B4D?style=for-the-badge&logo=cilium&logoColor=white)
![BGP](https://img.shields.io/badge/BGP-Control_Plane-4B8BBE?style=for-the-badge)
![Gateway API](https://img.shields.io/badge/Gateway_API-Enabled-60B932?style=for-the-badge)
![Hubble](https://img.shields.io/badge/Hubble-UI_%2B_Relay-FFEC6E?style=for-the-badge)

Wrapper chart de Cilium como CNI del cluster, con BGP Control Plane para anunciar las IPs de LoadBalancer de los Gateways vía ECMP hacia FRR, reemplazando L2 announcements.

## Componentes

| Componente | Detalle |
|------------|---------|
| Chart base | `cilium` 1.19.1, vía OCI desde `oci://registry.harbor.local/helm-charts` |
| Routing mode | Native, `autoDirectNodeRoutes`, datapath `netkit` |
| kube-proxy | Reemplazado (`kubeProxyReplacement: true`) |
| Load Balancer | Modo `hybrid`, algoritmo `maglev` |
| Bandwidth Manager | BBR habilitado |
| Hubble | UI + Relay habilitados, TLS auto (método Helm) |
| Gateway API | Habilitado, CRDs instalados |

## BGP (`bgp/`)

BGP Control Plane en vez de L2 announcements, para anunciar IPs de LoadBalancer con ECMP.

| Recurso | Detalle |
|---------|---------|
| `bgp-cluster-infra.yaml` | `CiliumBGPClusterConfig` para nodos `workload-type: infrastructure`, ASN local 65001 |
| `bgp-cluster-app.yaml` | `CiliumBGPClusterConfig` para nodos `workload-type: application`, ASN local 65001 |
| `bgp-peer-config-infra.yaml` / `bgp-peer-config-app.yaml` | `CiliumBGPPeerConfig` — graceful restart, timers, selector de advertisements por label |
| `bgp-advertisement-infra.yaml` / `bgp-advertisement-app.yaml` | `CiliumBGPAdvertisement` — anuncia `LoadBalancerIP` de los Services que matchean `infra-gateway` / `apps-gateway` |

Peers BGP (ASN 65000):
- `frr-01` — `192.168.253.20`
- `frr-02` — `192.168.253.21`

## Routes (`routes/`)

- `https.yaml` — `HTTPRoute` para exponer Hubble UI (`hubble.local`) vía `infra-gateway`, con redirect HTTP → HTTPS

## Orden de Despliegue

### 1. Requisitos previos
- FRR (`frr-01`/`frr-02`) desplegado y configurado como peer BGP en AS 65000
- Gateway API CRDs y `infra-gateway`/`apps-gateway` desplegados

### 2. Instalar/Actualizar el Release
```bash
cd infrastructure-applications/cilium/
helm dependency update
helm upgrade --install cilium . -n kube-system
```

## Estado de Preparación

Al completar el despliegue tendrás:
- **Cilium** como CNI único, sin kube-proxy
- **BGP Control Plane** anunciando IPs de LoadBalancer vía ECMP hacia FRR
- **Hubble UI** accesible en `hubble.local` vía Gateway API

<!-- TODO: agregar capturas de evidencia (cilium bgp peers, Hubble UI) -->

## Verificación

```bash
# Estado de los peers BGP
cilium bgp peers

# Rutas anunciadas
cilium bgp routes

# Pods de Cilium en Running
kubectl get pods -n kube-system -l k8s-app=cilium
```

## Siguiente Paso

Con Cilium y BGP operativos, los Services de tipo LoadBalancer de las aplicaciones del resto de `infrastructure-applications/` quedan alcanzables vía las IPs anunciadas a FRR.

## Dependencias

- **Paso 1** requiere FRR configurado como peer BGP (fuera de este repo, en `frr-01`/`frr-02`)
- **Gateway API** (`../gateway-api/`) requerido antes de que las `CiliumBGPAdvertisement` tengan algo que anunciar
