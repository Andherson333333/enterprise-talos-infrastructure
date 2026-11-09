[English](./README.md) | **Español**

# Role: frr-install

Instala FRRouting desde el repo oficial y aplica un `frr.conf` estático por nodo para hacer peering BGP con Cilium.

## Qué hace

1. Instala `gnupg` y agrega el repo `deb.frrouting.org` (`frr-stable`)
2. Instala `frr` y `frr-pythontools`
3. Habilita `bgpd` en `/etc/frr/daemons`
4. Habilita `net.ipv4.ip_forward=1`
5. Copia `files/<inventory_hostname>.conf` a `/etc/frr/frr.conf`
6. Reinicia FRR y aplica la config con `vtysh`

| Nodo | IP | Config |
|------|-----|--------|
| frr-01 | 192.168.253.20 | `files/frr-01.conf` |
| frr-02 | 192.168.253.21 | `files/frr-02.conf` |

ASN local 65000, peers Cilium en ASN 65001.

## Requisitos

- Acceso a `deb.frrouting.org` (o mirror equivalente vía proxy APT)
- El nombre del host en el inventario debe coincidir con el archivo `.conf`

## Uso

```bash
ansible-playbook -i ../inventory ../frr-install.yml
```

## Verificación

```bash
vtysh -c "show bgp summary"
```
