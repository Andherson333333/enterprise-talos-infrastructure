# OpenBao - Instalación de Nodo Raft
![OpenBao](https://img.shields.io/badge/OpenBao-Vault_Fork-FFEC6E?style=for-the-badge)
![Raft](https://img.shields.io/badge/Storage-Raft_Integrated-4B8BBE?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-13-A81D33?style=for-the-badge&logo=debian&logoColor=white)

Este README aplica a los 3 nodos del cluster (`open-bao-1`, `open-bao-2`, `open-bao-3`). El procedimiento es idéntico — solo cambian la IP, el hostname y el `node_id` en `openbao.hcl`. No se repite en las otras carpetas.

## Especificaciones por Nodo

| Nodo | IP | node_id |
|------|-----|---------|
| open-bao-1 | 192.168.253.30 | open-bao-1 |
| open-bao-2 | 192.168.253.31 | open-bao-2 |
| open-bao-3 | 192.168.253.32 | open-bao-3 |

- VM: Debian 13, 2 vCPU / 2GB RAM
- Storage: disco dedicado de 10GB, particionado y montado en `/opt/openbao/data`

## Orden de Despliegue

### 1. Provisionar la VM
Ver `../../../terraform/` para el despliegue base, o crear manualmente sobre el template Debian 13.

### 2. Generar Certificado Multi-SAN
**Carpeta**: [`../../../requirements/certificate-server-config/`](../../../requirements/certificate-server-config/)

Un solo certificado cubriendo las 3 IPs + hostnames (sin SAN, Go TLS rechaza la validación):
```bash
# Generado en certificate-server con mkcert + Harbor CA
# Salida en /opt/generated_certs/openbao/
```

### 3. Instalar OpenBao
```bash
# Descargar binario/paquete en pve-1 (internet) y transferir, o vía apt-cacher-ng
apt install openbao
```

### 4. Aplicar Configuración
Copiar `openbao.hcl` de esta carpeta (ajustando IP/node_id para cada nodo) a `/etc/openbao/openbao.hcl`:
```bash
systemctl enable --now openbao
```

### 5. Inicializar el Cluster (solo una vez, desde open-bao-1)
```bash
bao operator init
# 5 Shamir unseal keys, threshold 3
```

### 6. Unir y Unseal los Demás Nodos
```bash
# En open-bao-2 y open-bao-3
bao operator raft join https://192.168.253.30:8200
bao operator unseal
```

### 7. Habilitar Secrets Engine y AppRole
```bash
bao secrets enable -path=secret kv-v2
bao auth enable approle
# Policy de solo lectura sobre secret/data/* y secret/metadata/* para ArgoCD
```

## Estado de Preparación

Al completar todos los pasos tendrás:
- **3 nodos** en cluster Raft, unsealed
- **KV v2** habilitado en `secret/`
- **AppRole** listo para consumo desde ArgoCD

## Verificación

```bash
bao operator status
bao kv get secret/test
```

## Siguiente Paso

- **`../proxy-open-bao/`** - Configurar HAProxy como endpoint HA

## Dependencias

- **Paso 2** requiere certificados generados antes de instalar
- **Paso 5** solo se ejecuta una vez, desde el primer nodo levantado
- **Paso 6** requiere que open-bao-1 ya esté inicializado
