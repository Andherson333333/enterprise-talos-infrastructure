# Host Network Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Network](https://img.shields.io/badge/Network-Static_IP-FF6B35?style=for-the-badge&logo=cisco&logoColor=white)

Configuración automática de red estática y resolución DNS local mediante playbook de Ansible.

## ¿Qué hace?

Configura IP estática y hostnames locales para servicios. Establece red fija y resolución DNS interna.

### Configuración incluida

- **IP estática**: 192.168.253.11/24
- **Gateway**: 192.168.253.1  
- **DNS local**: Harbor Registry y Gitea Server
- **Hostname**: gitea-server

## Uso

```bash
# Ejecutar configuración
ansible-playbook -i inventory host-network-1ip.yml
```

## Archivos de configuración

```
host-network-1ip/
├── files/
│   ├── hosts                        # Resolución DNS local
│   └── interfaces                   # Configuración de red estática
└── tasks/main.yml                   # Tareas de configuración
```

### Hosts configurados

```
192.168.253.12 registry.harbor.local
192.168.253.11 gitea.server.local
```

## Verificación

```bash
# Verificar IP configurada
ansible all -i inventory -m shell -a "ip addr show ens18"

# Verificar resolución DNS
ansible all -i inventory -m shell -a "cat /etc/hosts"

# Probar conectividad
ansible all -i inventory -m shell -a "ping -c 2 registry.harbor.local"
```

## Personalización

Para cambiar configuración, editar:
- `files/interfaces` - Cambiar IP, gateway, netmask
- `files/hosts` - Agregar/modificar hostnames
