# Host Network 2IP Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Network](https://img.shields.io/badge/Network-Dual_IP-FF6B35?style=for-the-badge&logo=cisco&logoColor=white)

Configuración automática de red dual IP y resolución DNS para Harbor server mediante playbook de Ansible.

## ¿Qué hace?

Configura dos interfaces de red estáticas y hostnames locales para servicios. Establece conectividad dual y resolución DNS interna.

### Configuración incluida

- **Interface ens18**: 192.168.133.20/24 (gateway 192.168.133.2)
- **Interface ens19**: 192.168.253.12/24 (sin gateway)
- **DNS local**: Harbor Registry (doble IP) y Gitea Server
- **Hostname**: harbor-server

## Uso

```bash
# Ejecutar configuración
ansible-playbook -i inventory network.yml
```

### Hosts configurados

```
192.168.133.20 registry.harbor.local
192.168.253.12 registry.harbor.local  
192.168.253.11 gitea.server.local
```

## Verificación

```bash
# Verificar ambas interfaces
ansible all -i inventory -m shell -a "ip addr show ens18"
ansible all -i inventory -m shell -a "ip addr show ens19"

# Verificar resolución DNS
ansible all -i inventory -m shell -a "cat /etc/hosts"

# Probar conectividad dual
ansible all -i inventory -m shell -a "ping -c 2 192.168.133.20"
ansible all -i inventory -m shell -a "ping -c 2 192.168.253.12"
```

## Personalización

Para cambiar configuración, editar:
- `files/interfaces` - Modificar IPs, gateway, netmask
- `files/hosts` - Agregar/cambiar hostnames
