**English** | [Español](./README.es.md)

# Role: gitea-actions

Publishes an offline mirror of GitHub Actions into Gitea so Gitea Actions works in an air-gapped environment.

## What it does

1. Extracts `files/github-actions-airgap-full-repos.tar.gz` into `/opt/gitea-actions-source`
2. Creates the `actions` organization via API (ignored if it already exists)
3. Creates one repository per action found
4. Runs `git push --all --force` of each action into its repo

## Requirements

- Gitea running (`gitea-install`)
- Gitea API token with admin permissions
- `.tar.gz` package generated with `../download-actions.sh`

## Variables (`vars/main.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `gitea_url` | `https://192.168.253.11` | Gitea URL |
| `gitea_actions_org` | `actions` | Target organization |
| `gitea_actions_dir` | `/opt/gitea-actions-source` | Extraction directory |
| `actions_tar_file` | `github-actions-airgap-full-repos.tar.gz` | Actions package |
| `gitea_user` / `gitea_group` | `gitea` | File owner |
| `gitea_admin_user`, `gitea_admin_password`, token | — | **Secrets**: use `ansible-vault` or `--extra-vars`, never plain text |

## Usage

```bash
ansible-playbook -i inventory gitea-actions.yml
```

## Verification

In Gitea: the `actions` organization with one repo per action (e.g. `actions/checkout`). Workflows reference them exactly as on GitHub.
