# Role: certificados

Distribuye la CA interna a los hosts para que el sistema y Docker confíen en Harbor y Gitea.

## Qué hace

1. Copia `harbor-ca.crt` y `gitea-ca.crt` a `/usr/local/share/ca-certificates/`
2. Ejecuta `update-ca-certificates`
3. Crea `/etc/docker/certs.d/192.168.253.12` y `/etc/docker/certs.d/registry.harbor.local`
4. Copia `ca.crt` en `/etc/docker/certs.d/` para `192.168.253.11` y `gitea.server.local`
5. Reinicia Docker

> **Ojo**: el paso 3 crea los directorios de Harbor, pero el paso 4 copia a los de Gitea, que no se crean. Revisar que ambas listas coincidan.

## Requisitos

- Docker instalado
- CA exportada a `files/` (`ca.crt`, `harbor-ca.crt`, `gitea-ca.crt`)

## Uso

```bash
ansible-playbook -i inventory certificados.yml
```

Por defecto apunta al grupo `gitea`. Cambiar `hosts:` en `certificados.yml` para otros servidores.

## Verificación

```bash
ls /etc/ssl/certs | grep -iE 'harbor|gitea'
```

```bash
docker login registry.harbor.local
```
