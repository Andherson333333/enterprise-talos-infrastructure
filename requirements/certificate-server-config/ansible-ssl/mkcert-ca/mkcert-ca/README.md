# Role: mkcert-ca

Genera certificados TLS para los servicios internos firmados con la CA local de mkcert, usando contenedores `iamluc/mkcert` con Docker Compose.

## Qué hace

1. Crea `/opt/generated_certs/{gitea,harbor,wildcard-local}`
2. Copia el `docker-compose.yml` de cada generador
3. Ejecuta `docker compose up` en cada carpeta para emitir los certificados

| Certificado | Archivos | SANs |
|-------------|----------|------|
| Gitea | `gitea/gitea.pem`, `gitea.key` | `gitea.server.local`, `localhost`, `127.0.0.1`, `192.168.253.11` |
| Harbor | `harbor/harbor.pem`, `harbor.key` | `registry.harbor.local`, `harbor.server.local`, `harbor.local`, `localhost`, IPs |
| Wildcard | `wildcard-local/wildcard-local.pem`, `.key` | `*.local`, `local`, `localhost` |

`files/` también incluye `openbao-compose.yml` y `proxy-openbao-compose.yml` (nodos OpenBao y HAProxy); hoy no los ejecuta el role, se lanzan a mano.

## Requisitos

- Docker + Compose en el host
- CA de mkcert en `/opt/harbor/mkcert-ca` (la montan los compose como solo lectura)

## Variables (`vars/main.yml`)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `cert_base_dir` | `/opt/generated_certs` | Directorio de salida |
| `mkcert_ca_path` | `/opt/mkcert-ca` | No se usa: los compose montan `/opt/harbor/mkcert-ca` fijo |

## Uso

```bash
ansible-playbook -i ../inventory mkcer.yml
```

## Verificación

```bash
openssl x509 -in /opt/generated_certs/harbor/harbor.pem -noout -subject -ext subjectAltName
```
