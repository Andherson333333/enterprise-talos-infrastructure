**English** | [Español](./README.es.md)

# Role: gitea-runner

Deploys `act_runner` in Docker and registers it with Gitea to run Gitea Actions.

## What it does

1. Creates `/opt/gitea-runner`
2. Copies `docker-compose.yml` and `config.yaml`
3. Starts the runner with `docker compose up -d`

| Parameter | Value |
|-----------|-------|
| Image | `registry.harbor.local/proxy-docker/gitea/act_runner:latest` |
| Instance | `https://gitea.server.local` |
| Name | `gitea-runner-docker` |
| Execution | Host Docker (`/var/run/docker.sock`) |
| CA | Host `/etc/ssl/certs/ca-certificates.crt` mounted |
| Hosts | `gitea.server.local` → .11, `registry.harbor.local` → .12 |

## Requirements

- Gitea running and a runner registration token (Admin → Actions → Runners)
- CA installed on the host (`shared-infrastructure/certificate-ansible`)

> The registration token (`GITEA_RUNNER_REGISTRATION_TOKEN`) is a secret: pass it with `ansible-vault` or an environment variable, never leave it in the versioned compose file.

## Usage

```bash
ansible-playbook -i inventory gitea-runner.yml
```

## Verification

```bash
docker logs gitea-runner --tail 20
```

In Gitea: Admin → Actions → Runners shows the runner as `Idle`.
