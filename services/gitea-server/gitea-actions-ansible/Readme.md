# Gitea Actions Air-Gapped Deployment
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Gitea](https://img.shields.io/badge/Gitea-Actions-609926?style=for-the-badge&logo=gitea&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Actions-181717?style=for-the-badge&logo=github&logoColor=white)
![Air-Gapped](https://img.shields.io/badge/Air_Gapped-Environment-FF6B35?style=for-the-badge)

Solución automatizada para desplegar GitHub Actions en entornos air-gapped usando Gitea con Ansible. Diseñado para infraestructuras sin acceso a internet donde las actions deben residir localmente.

## El Problema
En entornos air-gapped, `uses: actions/checkout@v4` falla porque no puede acceder a GitHub.com. Esta solución pre-descarga las actions y las despliega como repositorios locales en Gitea.

## Arquitectura
```
Internet → GitHub Repos → tar.gz → Air-Gapped Server → Gitea Local Repos
Pipeline: uses: https://192.168.253.11/actions/checkout@v4
```

## Características
- **25+ GitHub Actions** pre-descargadas (checkout, setup-node, docker-build, etc.)
- **Despliegue selectivo** opcional para actions específicas
- **Zero internet dependency** después del setup inicial
- **Full Git history** con tags para compatibilidad completa

## Configuración Inicial

### 1. Token de Gitea
Generar token de administrador en: `https://192.168.253.11/user/settings/applications`
- Scopes: `repo`, `admin:org`, `admin:repo_hook`

### 2. Variables (vars/main.yml)
```yaml
---
gitea_url: "https://192.168.253.11"
gitea_admin_password: "TU_TOKEN_DE_ADMINISTRADOR_AQUI"
gitea_actions_org: "actions"

# Opcional: Despliegue selectivo
# selected_actions:
#   - checkout
#   - setup-node
#   - upload-artifact
```

## Despliegue

### Método Completo
```bash
# 1. Descargar actions (servidor con internet)
./git.sh

# 2. Transferir a servidor air-gapped
scp /tmp/github-actions-airgap-full-repos.tar.gz root@192.168.253.11:/opt/

# 3. Ejecutar ansible
ansible-playbook -i inventory gitea-actions.yml
```

### Verificación
```bash
# Verificar organización
curl -k https://192.168.253.11/api/v1/orgs/actions \
  -H "Authorization: token TU_TOKEN"

# Ver actions en web
https://192.168.253.11/actions
```

## Uso en Pipelines

### Cambio Necesario
```yaml
# NO FUNCIONA (requiere internet)
- uses: actions/checkout@v4

# CORRECTO (repositorio local)
- uses: https://192.168.253.11/actions/checkout@v4
```

### Ejemplo Pipeline
```yaml
name: Air-Gapped CI
on: [push]
jobs:
  build:
    runs-on: gitea-runner
    steps:
      - uses: https://192.168.253.11/actions/checkout@v4
      - uses: https://192.168.253.11/actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm ci && npm run build
```

## Actions Incluidas

### Críticas
- `checkout v4` - Checkout código
- `upload-artifact v4` - Subir artefactos  
- `download-artifact v4` - Descargar artefactos
- `cache v4` - Sistema de caché

### Setup Lenguajes
- `setup-node v4`, `setup-python v5`, `setup-go v5`, `setup-java v4`

### Docker
- `docker-build-push-action v6`, `docker-login-action v3`

### Utilities
- `github-script v7`, `release-action v1.13.0`, `codeql-action v3`

## Troubleshooting

### Errores Comunes
```bash
# Verificar token
curl -k https://192.168.253.11/api/v1/user \
  -H "Authorization: token TU_TOKEN"

# Verificar permisos
sudo chown -R gitea:gitea /opt/gitea-actions-source/

# Verificar extracción
ls -la /opt/gitea-actions-source/github-actions-airgap-full-repos/
```

### Reconfiguración
```bash
# Limpiar y redesplegar
ansible-playbook -i inventory gitea-actions.yml --tags "cleanup"
ansible-playbook -i inventory gitea-actions.yml
```

## Estructura del Proyecto
```
gitea-actions/
├── vars/main.yml              # Variables principales
├── files/github-actions-airgap-full-repos.tar.gz
├── tasks/main.yml             # Extracción y setup
├── tasks/push.yml             # Push a Gitea
└── gitea-actions.yml          # Playbook principal
```
