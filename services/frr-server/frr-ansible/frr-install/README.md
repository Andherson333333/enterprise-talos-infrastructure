**English** | [Español](./README.es.md)

# Role: frr-install

Installs FRRouting from the official repo and applies a static `frr.conf` per node to peer over BGP with Cilium.

## What it does

1. Installs `gnupg` and adds the `deb.frrouting.org` repo (`frr-stable`)
2. Installs `frr` and `frr-pythontools`
3. Enables `bgpd` in `/etc/frr/daemons`
4. Enables `net.ipv4.ip_forward=1`
5. Copies `files/<inventory_hostname>.conf` to `/etc/frr/frr.conf`
6. Restarts FRR and applies the config with `vtysh`

| Node | IP | Config |
|------|-----|--------|
| frr-01 | 192.168.253.20 | `files/frr-01.conf` |
| frr-02 | 192.168.253.21 | `files/frr-02.conf` |

Local ASN 65000, Cilium peers on ASN 65001.

## Requirements

- Access to `deb.frrouting.org` (or an equivalent mirror via the APT proxy)
- The host name in the inventory must match the `.conf` file

## Usage

```bash
ansible-playbook -i ../inventory ../frr-install.yml
```

## Verification

```bash
vtysh -c "show bgp summary"
```
