# FRR - Configuración BGP
![FRR](https://img.shields.io/badge/FRRouting-10.5.3-4B8BBE?style=for-the-badge)
![BGP](https://img.shields.io/badge/BGP-AS_65000-E52F1F?style=for-the-badge)
![Cilium](https://img.shields.io/badge/Cilium-BGP_Control_Plane-7B42BC?style=for-the-badge)
![HA](https://img.shields.io/badge/HA-2_Routers-28a745?style=for-the-badge)

Par de routers FRR en HA (AS 65000) que peerean vía BGP con el Cilium BGP Control Plane de cada nodo Talos (AS 65001), dando conectividad L3 real a los Service/LoadBalancer sin depender de un VIP tradicional tipo MetalLB.

## Topología

| Router | IP | router-id |
|--------|-----|-----------|
| frr-01 | 192.168.253.20 | 192.168.253.20 |
| frr-02 | 192.168.253.21 | 192.168.253.21 |

**Peers Talos (AS 65001):**

| Nodo | IP |
|------|-----|
| talos-infra-01 | 192.168.253.111 |
| talos-infra-02 | 192.168.253.112 |
| talos-infra-03 | 192.168.253.113 |
| talos-app-01 | 192.168.253.120 |
| talos-app-02 | 192.168.253.121 |

## Diseño BGP

- **iBGP entre `frr-01` y `frr-02`** (mismo AS 65000) — cada uno anuncia al otro las rutas aprendidas de los nodos Talos, con `next-hop-self`
- **eBGP entre cada FRR y cada nodo Talos** (AS 65000 ↔ AS 65001) — sin VIP: cada nodo Talos peerea de forma independiente con **ambos** FRR, logrando HA por redundancia de peers en vez de un balanceador
- **`maximum-paths 3`** habilita ECMP — el tráfico de retorno se reparte entre los nodos que anuncian la misma ruta
- **`soft-reconfiguration inbound`** en los peers Talos, para poder inspeccionar rutas entrantes sin reiniciar la sesión BGP
- **`no bgp ebgp-requires-policy`** — simplifica el setup evitando exigir route-maps explícitos en el eBGP

Este README aplica a los 2 routers (`frr-01`, `frr-02`). El procedimiento de instalación es idéntico — solo cambian la IP, el `hostname` y el `router-id` en `frr.conf`.

## Orden de Despliegue

### 1. Instalar FRR
**Script**: [`install.sh`](./install.sh)

```bash
chmod +x install.sh
./install.sh
```

El script:
- Agrega el repo oficial de FRRouting (`deb.frrouting.org`) con su GPG key
- Instala `frr` + `frr-pythontools`
- Habilita únicamente el daemon `bgpd` (el resto queda apagado)
- Activa `net.ipv4.ip_forward=1` (necesario para rutear tráfico)
- Habilita y arranca el servicio `frr`

### 2. Aplicar Configuración BGP
Copiar `frr.conf` de [`frr-01/`](./frr-01/) o [`frr-02/`](./frr-02/) (según el nodo) a `/etc/frr/frr.conf`, ajustando IP/hostname/router-id:
```bash
vtysh -f /etc/frr/frr.conf
```
(`vtysh -f` aplica sin reiniciar el servicio, evitando caídas de sesión en el otro peer)

## Estado de Preparación

Al completar estos pasos tendrás:
- **bgpd** corriendo en AS 65000 en ambos routers
- **iBGP** establecido entre `frr-01` y `frr-02`
- **eBGP** establecido con los 5 nodos Talos (AS 65001)

## Verificación

```bash
# Estado de todas las sesiones BGP — deben verse "Established" (Up/Down con tiempo, no "never")
vtysh -c "show bgp summary"

# Confirmar qué rutas se recibieron de un nodo específico
vtysh -c "show bgp ipv4 unicast neighbors 192.168.253.111 received-routes"
```

## Evidencia de Funcionamiento

![FRR BGP Summary](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/frr-04.png)

![FRR Received Routes](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/frr-01.png)

![FRR BGP Summary](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/frr-02.png)

![FRR Received Routes](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/frr-03.png)


## Siguiente Paso

Con FRR operativo, dirigirse a:
- **`../../infrastructure-applications/cilium/`** - Configuración del BGP Control Plane del lado de Cilium (peers, ASN, anuncio de LoadBalancer IPs)

## Dependencias

- Requiere acceso a internet para el repo de FRRouting (o mirror local vía `apt-cacher-ng`)
- El peer iBGP requiere que el otro router (`frr-02` o `frr-01`) ya tenga `bgpd` corriendo, aunque no es bloqueante para el arranque
- Las sesiones eBGP hacia Talos requieren que Cilium tenga `CiliumBGPClusterConfig`/`CiliumBGPPeerConfig` configurado con AS 65001 — sin esto, los peers Talos quedan en estado `Active` indefinidamente (nunca `Established`)
