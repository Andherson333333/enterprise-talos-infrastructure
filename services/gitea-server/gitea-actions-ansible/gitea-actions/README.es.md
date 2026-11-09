[English](./README.md) | **Español**

# Role: gitea-actions

Publica en Gitea un mirror offline de GitHub Actions para usar Gitea Actions en entorno air-gapped.

## Qué hace

1. Descomprime `files/github-actions-airgap-full-repos.tar.gz` en `/opt/gitea-actions-source`
2. Crea la organización `actions` vía API (ignora si ya existe)
3. Crea un repositorio por cada action encontrada
4. Hace `git push --all --force` de cada action a su repo

## Requisitos

- Gitea operativo (`gitea-install`)
- Token de API de Gitea con permisos de admin
- Paquete `.tar.gz` generado con `../download-actions.sh`

## Variables (`vars/main.yml`)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `gitea_url` | `https://192.168.253.11` | URL de Gitea |
| `gitea_actions_org` | `actions` | Organización destino |
| `gitea_actions_dir` | `/opt/gitea-actions-source` | Directorio de extracción |
| `actions_tar_file` | `github-actions-airgap-full-repos.tar.gz` | Paquete de actions |
| `gitea_user` / `gitea_group` | `gitea` | Dueño de los archivos |
| `gitea_admin_user`, `gitea_admin_password`, token | — | **Secrets**: usar `ansible-vault` o `--extra-vars`, no dejarlos en texto plano |

## Uso

```bash
ansible-playbook -i inventory gitea-actions.yml
```

## Verificación

En Gitea: organización `actions` con un repo por action (p. ej. `actions/checkout`). En los workflows se referencian igual que en GitHub.
