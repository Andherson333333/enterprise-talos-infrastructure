# OpenBao - HAProxy (Endpoint HA)
![HAProxy](https://img.shields.io/badge/HAProxy-Load_Balanced-106DA9?style=for-the-badge&logo=haproxy&logoColor=white)
![TLS](https://img.shields.io/badge/TLS-Passthrough-28a745?style=for-the-badge)

Balanceador que expone un único endpoint HA para OpenBao, dirigiendo tráfico solo al líder activo del cluster Raft.

## Especificaciones

- IP: 192.168.253.34
- Health-check: `/v1/sys/health` — responde HTTP 200 **solo** para el nodo líder
- Los demás nodos (standby/sealed) responden códigos distintos, por lo que HAProxy los excluye automáticamente del pool

## Orden de Despliegue

### 1. Generar Certificado
**Carpeta**: [`../../../requirements/certificate-server-config/`](../../../requirements/certificate-server-config/)

Certificado propio para el endpoint HAProxy (distinto al de los nodos OpenBao).

### 2. Instalar HAProxy
```bash
apt install haproxy
```

### 3. Aplicar Configuración
Copiar `haproxy.cfg` de esta carpeta a `/etc/haproxy/haproxy.cfg`:
```bash
systemctl restart haproxy
```

### 4. Apuntar Clientes al Endpoint
En ArgoCD (u otros consumidores), configurar:
```bash
VAULT_ADDR=https://192.168.253.34:8200
```

## Estado de Preparación

Al completar estos pasos tendrás:
- **Endpoint único** (`.34:8200`) resolviendo siempre al líder activo
- **Failover transparente** ante cambio de líder en el Raft

## Verificación

```bash
# Debe responder 200 solo mientras hay un líder activo
curl -k https://192.168.253.34:8200/v1/sys/health

# Provocar failover manual y confirmar que HAProxy sigue respondiendo
bao operator step-down   # desde el nodo líder
curl -k https://192.168.253.34:8200/v1/sys/health
```

## Siguiente Paso

- **`../../../infrastructure-applications/argocd/`** - Usar este endpoint como `VAULT_ADDR`

## Dependencias

- Requiere el cluster OpenBao ya inicializado (`../open-bao-1/`)
