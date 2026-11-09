[English](./README.md) | **Español**

# Role: gitea-runner

Despliega `act_runner` en Docker y lo registra contra Gitea para ejecutar Gitea Actions.

## Qué hace

1. Crea `/opt/gitea-runner`
2. Copia `docker-compose.yml` y `config.yaml`
3. Levanta el runner con `docker compose up -d`

| Parámetro | Valor |
|-----------|-------|
| Imagen | `registry.harbor.local/proxy-docker/gitea/act_runner:latest` |
| Instancia | `https://gitea.server.local` |
| Nombre | `gitea-runner-docker` |
| Ejecución | Docker del host (`/var/run/docker.sock`) |
| CA | `/etc/ssl/certs/ca-certificates.crt` del host montado |
| Hosts | `gitea.server.local` → .11, `registry.harbor.local` → .12 |

## Requisitos

- Gitea operativo y token de registro del runner (Admin → Actions → Runners)
- CA instalada en el host (`shared-infrastructure/certificate-ansible`)

> El token de registro (`GITEA_RUNNER_REGISTRATION_TOKEN`) es un secret: pasarlo con `ansible-vault` o variable de entorno, no dejarlo en el compose versionado.

## Uso

```bash
ansible-playbook -i inventory gitea-runner.yml
```

## Verificación

```bash
docker logs gitea-runner --tail 20
```

En Gitea: Admin → Actions → Runners muestra el runner en estado `Idle`.
