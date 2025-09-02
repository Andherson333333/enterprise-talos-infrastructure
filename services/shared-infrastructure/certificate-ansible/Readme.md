# Certificates Ansible Role

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![SSL](https://img.shields.io/badge/SSL-Certificates-4CAF50?style=for-the-badge&logo=letsencrypt&logoColor=white)

Configuración automática de certificados SSL/TLS para sistema y Docker mediante playbook de Ansible.

## ¿Qué hace?

Instala certificados personalizados en el sistema y los configura para Docker. Actualiza la confianza de certificados del sistema operativo.

### Certificados incluidos

- harbor-ca.crt (Harbor Registry)
- gitea-ca.crt (Gitea Server) 
- ca.crt (Certificado raíz para Docker)

## Uso

```bash
# Ejecutar configuración
ansible-playbook -i inventory certificados.yml
```

## Estructura

```
certificados/
├── files/                           # Certificados SSL
│   ├── ca.crt                       # CA raíz para Docker
│   ├── harbor-ca.crt                # Certificado Harbor
│   └── gitea-ca.crt                 # Certificado Gitea
└── tasks/main.yml                   # Tareas de instalación
```

## Verificación

```bash
# Verificar certificados del sistema
ansible all -i inventory -m shell -a "ls /usr/local/share/ca-certificates/"

# Verificar certificados Docker
ansible all -i inventory -m shell -a "ls /etc/docker/certs.d/"

# Probar confianza SSL
ansible all -i inventory -m shell -a "curl -k https://registry.harbor.local"
```

## Actualización

Para actualizar certificados:
1. Reemplazar archivos .crt en `files/`
2. Ejecutar playbook nuevamente
3. Docker se reinicia automáticamente
