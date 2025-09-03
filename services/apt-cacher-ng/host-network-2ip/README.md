# Host Network 2IP Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Network](https://img.shields.io/badge/Network-Dual_IP-FF6B35?style=for-the-badge&logo=cisco&logoColor=white)

Configuración automática de red dual IP para APT-Cacher-NG server mediante playbook de Ansible.

## ¿Qué hace?

Configura dos interfaces de red estáticas y hostname para servidor APT cache. Establece conectividad dual para el servicio de cache.

### Configuración incluida

- **Interface ens18**: 192.168.133.157/24 (gateway 192.168.133.2)
- **Interface ens19**: 192.168.253.10/24 (sin gateway)
- **Hostname**: apt-cacher-ng.local

## Uso

```bash
# Ejecutar configuración
ansible-playbook -i inventory network.yml
```

### Host configurado

```
127.0.1.1 apt-cacher-ng.local apt-cacher-ng
```

## Verificación

```bash
# Verificar ambas interfaces
ansible all -i inventory -m shell -a "ip addr show ens18"
ansible all -i inventory -m shell -a "ip addr show ens19"

# Verificar hostname
ansible all -i inventory -m shell -a "cat /etc/hosts"

# Probar conectividad dual
ansible all -i inventory -m shell -a "ping -c 2 192.168.133.157"
ansible all -i inventory -m shell -a "ping -c 2 192.168.253.10"
```

## Personalización

Para cambiar configuración, editar:
- `files/interfaces` - Modificar IPs, gateway, netmask
- `files/hosts` - Cambiar hostname
