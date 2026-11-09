**English** | [Español](./README.es.md)

# Role: docker-install

Installs Docker CE on Debian 12 from local `.deb` packages, without internet access.

## What it does

1. Copies the `.deb` files from `files/` to `/tmp`
2. Installs them in order: containerd → docker-ce-cli → docker-ce → buildx → compose
3. Removes the temporary `.deb` files
4. Enables and starts `docker`
5. Adds `root` to the `docker` group
6. Checks `docker --version` and `docker compose --version`

| Package | Version |
|---------|---------|
| containerd.io | 1.7.27 |
| docker-ce / docker-ce-cli | 28.3.2 |
| docker-buildx-plugin | 0.25.0 |
| docker-compose-plugin | 2.38.2 |

## Variables (`defaults/main.yml`)

| Variable | Description |
|----------|-------------|
| `docker_deb_packages` | List of `.deb` files to copy and clean up |

To change versions, replace the `.deb` files in `files/` and update the list **and** the file names in `tasks/main.yml`.

## Usage

```bash
ansible-playbook -i inventory docker-install.yml
```

Targets the `gitea` group by default. Change `hosts:` in `docker-install.yml` for other servers.

## Verification

```bash
docker --version
```

```bash
systemctl is-active docker
```
