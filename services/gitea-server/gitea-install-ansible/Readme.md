# Servidor Gitea con Ansible & Docker

![Ansible](https://img.shields.io/badge/Ansible-Role-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-Proxy-00ADD8?style=for-the-badge&logo=traefik&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-1.24.2-609926?style=for-the-badge&logo=gitea&logoColor=white)
![TLS](https://img.shields.io/badge/TLS-Certificates-FF6B35?style=for-the-badge&logo=letsencrypt&logoColor=white)

Despliegue automatizado de servidor Gitea con proxy reverso Traefik, certificados TLS e integración con registro Harbor.

## Arquitectura

![TLS](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner-10.png)

## Flujo de Trabajo

```
DESPLIEGUE: Host Admin (Ansible) → Servidor Gitea (Docker Compose) → Traefik + Gitea
ACCESO: https://gitea.server.local (Web) | SSH Puerto 2222
REGISTRO: Integración con Harbor Registry Local
CERTIFICADOS: TLS personalizado con Root CA
```

## Características

- **Zero Config**: Servidor Gitea listo con Actions habilitado
- **TLS Listo**: Certificados personalizados con automatización Traefik  
- **Soporte SSH**: Operaciones Git vía SSH en puerto 2222
- **Integración Harbor**: Usa registro Harbor local para imágenes
- **Health Checks**: Monitoreo incorporado de contenedores
- **Auto SSL**: Redirección automática a HTTPS

## Requisitos

### Configuración Ansible (Prerequisitos)
Los siguientes playbooks deben ejecutarse **ANTES** de este rol:

- host-network-1ip.yml 
- docker-install.yml 
- ansible-proxy.yaml
- certificados.yml

### Requisitos del Sistema
- **Host Admin**: Nodo de control Ansible con acceso SSH
- **Servidor Gitea**: Servidor destino configurado con playbooks prerequisitos
- Acceso a registro Harbor (`registry.harbor.local`)
- Certificados TLS generados (gitea.key, gitea.pem, rootCA.pem)
- Resolución DNS para `gitea.server.local`


### Configuración Manual

#### 1. Preparar Certificados
```bash
# Colocar certificados en directorio files/:
cp gitea.key files/
cp gitea.pem files/  
cp rootCA.pem files/
```

#### 2. Ejecutar Rol Ansible
```bash
ansible-playbook -i inventory gitea-install/gitea-install.yml
```
playbook
![TLS](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner-2.png)

Verificacion via web
![TLS](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/gitea-server%2Brunner-3.png)


## Estructura de Directorios

```
gitea-install/
├── defaults/main.yml          # Variables por defecto
├── files/                     # Archivos estáticos
│   ├── docker-compose.yml     # Definición del stack principal
│   ├── tls.yml               # Configuración TLS Traefik
│   ├── gitea.key             # Clave privada TLS
│   ├── gitea.pem             # Certificado TLS
│   └── rootCA.pem            # Certificado Root CA
├── handlers/main.yml          # Manejadores Ansible
├── tasks/main.yml            # Tareas principales de instalación
├── meta/main.yml             # Metadatos del rol
└── README.md                 # Este archivo
```

## Detalles de Configuración

### Arquitectura de Despliegue
- **Host Admin**: Ejecuta Ansible y gestiona la configuración
- **Servidor Gitea**: Recibe el despliegue y ejecuta los contenedores

### Configuración Gitea
- **Dominio**: gitea.server.local
- **Base de datos**: SQLite3 (embebida)
- **Actions**: Habilitado para CI/CD
- **Install Lock**: Habilitado por seguridad

### Configuración Traefik  
- **HTTP → HTTPS**: Redirección automática
- **TLS**: Certificados personalizados con proveedor de archivos
- **SSH**: Enrutamiento TCP para operaciones Git
- **Dashboard**: Disponible en puerto 8080

### Configuración de Red
```yaml
Puertos:
  80   → 443   (Redirección HTTP → HTTPS)
  443  → 3000  (Interfaz web Gitea)
  2222 → 2222  (Operaciones SSH Git)

Volúmenes:
  gitea-data: Repositorios Git persistentes
  certificates: Certificados TLS personalizados  
```

## Uso

### Acceso a Gitea
```bash
# Interfaz web
https://gitea.server.local

# Clonar repositorio vía SSH  
git clone git@gitea.server.local:2222/usuario/repo.git

# Clonar repositorio vía HTTPS
git clone https://gitea.server.local/usuario/repo.git
```

### Verificación
```bash
# Verificar contenedores
docker ps | grep gitea

# Ver logs
docker logs gitea-server
docker logs gitea-traefik

# Probar conectividad
curl -k https://gitea.server.local
```
## Integración

### Con Harbor Registry
Este rol utiliza Harbor como fuente de registro de contenedores. Asegurar que Harbor sea accesible en `registry.harbor.local`.

### Con Infraestructura Enterprise  
Parte del ecosistema de infraestructura empresarial Talos. Compatible con:
- Clusters Kubernetes
- Stacks de monitoreo  
- Sistemas de backup
- Pipelines CI/CD
