# Role: docker-install

Instala Docker CE en Debian 12 desde paquetes `.deb` locales, sin acceso a internet.

## Qué hace

1. Copia los `.deb` de `files/` a `/tmp`
2. Los instala en orden: containerd → docker-ce-cli → docker-ce → buildx → compose
3. Borra los `.deb` temporales
4. Habilita y arranca `docker`
5. Agrega `root` al grupo `docker`
6. Verifica `docker --version` y `docker compose --version`

| Paquete | Versión |
|---------|---------|
| containerd.io | 1.7.27 |
| docker-ce / docker-ce-cli | 28.3.2 |
| docker-buildx-plugin | 0.25.0 |
| docker-compose-plugin | 2.38.2 |

## Variables (`defaults/main.yml`)

| Variable | Descripción |
|----------|-------------|
| `docker_deb_packages` | Lista de `.deb` a copiar y limpiar |

Para cambiar de versión, reemplazar los `.deb` en `files/` y actualizar la lista **y** los nombres en `tasks/main.yml`.

## Uso

```bash
ansible-playbook -i inventory docker-install.yml
```

Por defecto apunta al grupo `gitea`. Cambiar `hosts:` en `docker-install.yml` para otros servidores.

## Verificación

```bash
docker --version
```

```bash
systemctl is-active docker
```
