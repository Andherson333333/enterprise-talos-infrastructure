# Ansible APT Proxy Configuration

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![APT](https://img.shields.io/badge/APT-Proxy-FF6B35?style=for-the-badge&logo=debian&logoColor=white)

Configura proxy APT en múltiples servidores automáticamente.

## ¿Qué hace?

Crea `/etc/apt/apt.conf.d/02proxy` en todos los servidores para usar proxy APT centralizado.

## Uso

```bash
# Ejecutar
ansible-playbook -i inventory ansible-proxy.yaml

# Verificar
ansible all -i inventory -m shell -a "cat /etc/apt/apt.conf.d/02proxy"
```

## Personalizar

```yaml
# Cambiar IP del proxy en ansible-proxy.yaml
content: 'Acquire::http::Proxy "http://TU_IP_PROXY:3142";'
```

## Remover

```bash
# Quitar configuración
ansible all -i inventory -m file -a "path=/etc/apt/apt.conf.d/02proxy state=absent" --become
```
