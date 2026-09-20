# FRR - BGP Router (Cilium Peering)
![Ansible](https://img.shields.io/badge/Ansible-Role-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![FRR](https://img.shields.io/badge/FRRouting-10.5.3-4B8BBE?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-Managed-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-13-A81D33?style=for-the-badge&logo=debian&logoColor=white)

Dos routers FRR (`frr-01`/`frr-02`) que actúan como peers BGP intermedios entre Cilium BGP Control Plane (AS 65001) y la red del homelab, en AS 65000. Provisionados con Terraform y configurados con Ansible.

## Componentes

| Componente | Detalle |
|------------|---------|
| VMs | `frr-01` (192.168.253.20), `frr-02` (192.168.253.21) — clonadas de template 8002 (Debian 13) |
| Terraform | `terraform/vm-frr.tf`, variable `frr_nodes` en `terraform/variables.tf` |
| Ansible | `frr-ansible/` — role `frr-install`, un `frr.conf` estático por nodo en `frr-install/files/` |
| ASN local | 65000 (peer iBGP entre frr-01 y frr-02) |
| ASN remoto | 65001 (nodos Cilium, ver `../../infrastructure-applications/cilium/bgp/`) |

## Orden de Despliegue

### 1. Provisionar las VMs (Terraform)
```bash
cd terraform/
docker compose run --rm terraform apply -target='proxmox_virtual_environment_vm.frr["frr-01"]' -target='proxmox_virtual_environment_vm.frr["frr-02"]'
```

### 2. Copiar la SSH key de administración a cada VM
```bash
ssh-copy-id root@192.168.253.20
ssh-copy-id root@192.168.253.21
```

### 3. Instalar y configurar FRR (Ansible)
```bash
cd frr-ansible/
ansible-playbook -i inventory frr-install.yml
```

## Estado de Preparación

Al completar el despliegue tendrás:
- **FRR** instalado y corriendo en ambos nodos, con `bgpd` habilitado
- **iBGP** establecido entre `frr-01` ↔ `frr-02`
- **eBGP** listo para peerear con los nodos Cilium (AS 65001) una vez desplegado `../../infrastructure-applications/cilium/`

## Verificación

```bash
vtysh -c "show bgp summary"
```

Debe mostrar el peer iBGP (`.20`/`.21` entre sí) y los peers hacia los nodos Talos en estado `Established` una vez Cilium esté desplegado.

## Siguiente Paso

Con FRR operativo, despliega `../../infrastructure-applications/cilium/` para que los nodos Talos empiecen a peerear vía BGP y las IPs de LoadBalancer se anuncien correctamente.

## Dependencias

- Template 8002 (Debian 13) disponible en Proxmox
- Provider `bpg/proxmox` configurado (`terraform/provider.tf`)
- Requiere acceso a internet para el repo de FRRouting (`deb.frrouting.org`), o mirror local vía apt-cacher-ng
