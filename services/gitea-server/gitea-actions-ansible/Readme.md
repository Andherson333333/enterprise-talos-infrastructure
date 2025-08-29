# Gitea Actions Air-Gapped Deployment
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-Actions-609926?style=for-the-badge&logo=gitea&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Actions-181717?style=for-the-badge&logo=github&logoColor=white)
![Air-Gapped](https://img.shields.io/badge/Air_Gapped-Environment-FF6B35?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Support-2496ED?style=for-the-badge&logo=docker&logoColor=white)

Solución automatizada para desplegar GitHub Actions en entornos air-gapped usando Gitea con Ansible. Diseñado específicamente para infraestructuras sin acceso a internet donde las actions deben residir localmente en repositorios internos.

## Contexto del Problema

### Desafío en Entornos Air-Gapped
Los entornos air-gapped (sin acceso a internet) presentan un desafío fundamental para CI/CD:
- **GitHub Actions** requiere conectividad a `github.com` para descargar actions
- **Pipelines fallan** al intentar usar `uses: actions/checkout@v4` desde GitHub
- **Dependencias externas** no están disponibles durante la ejecución

### Solución Implementada
Esta solución automatiza la **pre-descarga** y **hosting local** de GitHub Actions:
1. **Descarga completa** de repositorios de actions desde GitHub (con historial y tags)
2. **Transferencia segura** del archive a entorno air-gapped
3. **Deploy automatizado** como repositorios locales en Gitea
4. **Referencia local** en pipelines usando URLs internas de Gitea

## Arquitectura
![Architecture](URL_DE_TU_IMAGEN_AQUI)

## Flujo de Trabajo
```
PROBLEMA: Entorno sin acceso a internet → GitHub Actions no disponibles
SOLUCIÓN: Descarga → Archive → Transfer → Local Gitea Repositories

DESCARGA: Internet → GitHub Repos → Local Archive (tar.gz)
TRANSFERENCIA: Archive → Air-Gapped Server → Gitea Instance  
DESPLIEGUE: Ansible → Extract → Git Push → Local Actions Repositories
EJECUCIÓN: Gitea Runner → Local Actions → CI/CD Pipeline (Offline)
```

## Características
- **Air-Gapped Ready**: Solución completa para entornos sin acceso a internet
- **Local Repository Storage**: Actions almacenadas como repositorios locales en Gitea
- **Full Git History**: Repositorios completos con tags y commits para compatibilidad
- **Automated Organization**: Creación automática de organización y repositorios via API
- **25+ Critical Actions**: Incluye actions esenciales de GitHub pre-descargadas
- **Docker Ecosystem**: Soporte completo para pipelines basadas en contenedores
- **Enterprise Ready**: SSL/TLS y certificados corporativos soportados
- **Zero Internet Dependency**: Operación completamente offline después del despliegue inicial

## Requisitos

### Problema a Resolver
- **Entorno air-gapped**: Infraestructura sin acceso directo a internet
- **GitHub Actions dependency**: Pipelines que requieren actions de GitHub.com
- **Local repository requirement**: Necesidad de actions disponibles localmente

### Infraestructura Necesaria
- Servidor con acceso a internet (para descarga inicial de repositorios)
- Servidor Gitea en entorno air-gapped (destino final)
- Ansible 2.9+ en máquina de control
- Token de administrador de Gitea con permisos de API
- Git instalado en servidor objetivo

## Estructura del Proyecto
```
gitea-actions/
├── defaults/main.yml              # Variables por defecto
├── files/
│   └── github-actions-airgap-full-repos.tar.gz  # Archive de actions
├── tasks/
│   ├── main.yml                   # Tareas principales
│   └── push.yml                   # Push a repositorios Gitea
├── handlers/main.yml              # Handlers de Ansible
├── vars/main.yml                  # Variables específicas
└── gitea-actions.yml              # Playbook principal
```

## GitHub Actions Incluidas

### Actions Críticas (Obligatorias)
```bash
checkout v4                    # Checkout de código fuente
upload-artifact v4            # Subir artefactos
download-artifact v4          # Descargar artefactos  
cache v4                      # Sistema de caché
```

### Setup Actions (Lenguajes)
```bash
setup-node v4                 # Node.js y npm
setup-python v5               # Python y pip
setup-go v5                   # Go language
setup-java v4                 # Java y Maven
setup-dotnet v4               # .NET Framework
```

### Docker Actions
```bash
docker-setup-buildx-action v3     # Docker Buildx
docker-build-push-action v6       # Build y Push imágenes
docker-login-action v3            # Login a registries
```

### Security, Release & Utilities
```bash
codeql-action v3              # Análisis de seguridad
release-action v1.13.0       # Crear releases
action-gh-release v2          # GitHub releases
github-script v7             # Ejecutar scripts
configure-pages v5           # GitHub Pages
deploy-pages v4              # Deploy Pages
image-actions main           # Optimización de imágenes
labeler v5                   # Auto-labeling
stale v9                     # Gestión de issues stale
```

## Configuración

### Variables Principales (defaults/main.yml)
```yaml
# Gitea Configuration
gitea_url: "https://gitea.server.local"
gitea_admin_password: "your-admin-token-here"
gitea_actions_org: "actions"
gitea_user: "git"
gitea_group: "git"

# Paths
gitea_actions_dir: "/tmp/gitea-actions"
actions_tar_file: "github-actions-airgap-full-repos.tar.gz"
```

### Organizacion y Repositorios
```yaml
# Se crean automáticamente:
Organization: actions
Repositories: 
  - actions/checkout
  - actions/upload-artifact
  - actions/download-artifact
  - actions/cache
  - actions/setup-node
  # ... y 20+ más
```

## Preparación Inicial

### 1. Descarga de Actions (Servidor con Internet)
```bash
# Ejecutar script de descarga
./git.sh

# Verificar archivo generado
ls -lh /tmp/github-actions-airgap-full-repos.tar.gz
```

### 2. Transferencia a Servidor Air-Gapped
```bash
# Copiar archivo a servidor objetivo  
scp /tmp/github-actions-airgap-full-repos.tar.gz usuario@gitea-server:/path/to/ansible/

# O usar método físico (USB, etc.) para entornos completamente aislados
```

## Despliegue

### Método Rápido
```bash
# Ejecutar playbook completo
ansible-playbook -i inventory gitea-actions.yml
```

### Método Paso a Paso

#### 1. Preparar inventario
```bash
# Crear inventory con servidor Gitea
cat > inventory << EOF
[gitea_servers]
gitea-01 ansible_host=192.168.253.11
EOF
```

#### 2. Configurar variables
```bash
# Editar variables principales
vim defaults/main.yml

# Verificar token de administrador
curl -k https://gitea.server.local/api/v1/version \
  -H "Authorization: token YOUR_TOKEN"
```

#### 3. Ejecutar despliegue
```bash
# Despliegue con verbose para debugging
ansible-playbook -i inventory gitea-actions.yml -v

# Solo extract (sin push)
ansible-playbook -i inventory gitea-actions.yml --tags "extract"

# Solo push repositories
ansible-playbook -i inventory gitea-actions.yml --tags "push"
```

#### 4. Verificar deployment
```bash
# Verificar organización creada
curl -k https://gitea.server.local/api/v1/orgs/actions \
  -H "Authorization: token YOUR_TOKEN"

# Listar repositorios de actions
curl -k https://gitea.server.local/api/v1/orgs/actions/repos \
  -H "Authorization: token YOUR_TOKEN"
```

## Verificación

### Verificar Actions en Gitea
```bash
# Verificar extracción local
ls -la /tmp/gitea-actions/github-actions-airgap-full-repos/

# Count de repositorios
find /tmp/gitea-actions/github-actions-airgap-full-repos/ -maxdepth 1 -type d | wc -l

# Verificar git history en un repo
cd /tmp/gitea-actions/github-actions-airgap-full-repos/checkout
git log --oneline | head -5
git tag | head -5
```

### Verificar en Gitea Web UI
```bash
# Acceder via navegador
https://gitea.server.local/actions

# Verificar repositorios específicos:
https://gitea.server.local/actions/checkout
https://gitea.server.local/actions/setup-node
https://gitea.server.local/actions/docker-build-push-action
```

## Uso en Pipelines

### Importante: Referencia a Actions Locales
En entornos air-gapped, las actions deben referenciar repositorios locales de Gitea en lugar de GitHub.com:

```yaml
#  NO FUNCIONA en air-gapped (requiere internet)
- uses: actions/checkout@v4

# CORRECTO para air-gapped (repositorio local)  
- uses: https://gitea.server.local/actions/checkout@v4
```

### Ejemplo .gitea/workflows/ci.yml
```yaml
name: Air-Gapped CI Pipeline
on:
  push:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: gitea-runner-docker
    steps:
      # Todas las actions usando rutas locales de Gitea
      - name: Checkout Code
        uses: https://gitea.server.local/actions/checkout@v4
        
      - name: Setup Node.js
        uses: https://gitea.server.local/actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Build Docker Image
        uses: https://gitea.server.local/actions/docker-build-push-action@v6
        with:
          context: .
          push: true
          tags: registry.harbor.local/myproject/app:${{ github.sha }}
          
      - name: Upload Artifacts
        uses: https://gitea.server.local/actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: dist/
```

### Configuración de Runner para Actions Locales
```yaml
# En runner config.yaml
container:
  options: >-
    --add-host=gitea.server.local:192.168.253.11
    -e ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER=false
    -e ACTIONS_STEP_DEBUG=true
```

## Troubleshooting

### Problemas de Conectividad en Air-Gapped

### Errores Comunes
```bash
# Verificar extracción del archivo
tar -tzf github-actions-airgap-full-repos.tar.gz | head -10

# Problemas de permisos
sudo chown -R git:git /tmp/gitea-actions/

# Verificar API token
curl -k https://gitea.server.local/api/v1/user \
  -H "Authorization: token YOUR_TOKEN"

# Debug push de repositorios
cd /tmp/gitea-actions/github-actions-airgap-full-repos/checkout
git remote -v
git log --oneline -5

# Verificar SSL en git push
GIT_SSL_NO_VERIFY=true git ls-remote origin
```

### Reconfiguración
```bash
# Limpiar y volver a desplegar
ansible-playbook -i inventory gitea-actions.yml --tags "cleanup"
ansible-playbook -i inventory gitea-actions.yml

# Solo recrear organización
curl -k -X DELETE https://gitea.server.local/api/v1/orgs/actions \
  -H "Authorization: token YOUR_TOKEN"
```

### Verificación de Actions Específicas
```bash
# Verificar action específica
curl -k https://gitea.server.local/api/v1/repos/actions/checkout

# Verificar tags disponibles
curl -k https://gitea.server.local/api/v1/repos/actions/checkout/tags

# Verificar contenido del action.yml
curl -k https://gitea.server.local/api/v1/repos/actions/checkout/contents/action.yml
```

## Monitoreo

### Health Checks
```bash
# Script de verificación de actions
cat > verify_actions.sh << 'EOF'
#!/bin/bash
GITEA_URL="https://gitea.server.local"
TOKEN="YOUR_TOKEN"

ACTIONS=("checkout" "setup-node" "upload-artifact" "docker-build-push-action")

for action in "${ACTIONS[@]}"; do
  STATUS=$(curl -s -k "$GITEA_URL/api/v1/repos/actions/$action" \
    -H "Authorization: token $TOKEN" | jq -r '.name // "ERROR"')
  
  if [ "$STATUS" = "$action" ]; then
    echo "[OK] $action: OK"
  else
    echo "[ERROR] $action: ERROR"
  fi
done
EOF

chmod +x verify_actions.sh
./verify_actions.sh
```

### Logs de Despliegue
```bash
# Ejecutar con máximo detalle
ansible-playbook -i inventory gitea-actions.yml -vvv

# Guardar logs
ansible-playbook -i inventory gitea-actions.yml -v > deployment.log 2>&1
```

## Actualización de Actions

### Agregar Nuevas Actions
```bash
# Editar git.sh para agregar más repositorios
clone_action "https://github.com/nueva/action.git" "v1" "nueva-action"

# Regenerar archivo y redesplegar
./git.sh
scp /tmp/github-actions-airgap-full-repos.tar.gz servidor:/path/
ansible-playbook -i inventory gitea-actions.yml
```
