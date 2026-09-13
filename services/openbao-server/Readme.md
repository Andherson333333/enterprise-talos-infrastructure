# OpenBao Server - Secrets Management HA
![OpenBao](https://img.shields.io/badge/OpenBao-Vault_Fork-FFEC6E?style=for-the-badge)
![Raft](https://img.shields.io/badge/Storage-Raft_HA-4B8BBE?style=for-the-badge)
![HAProxy](https://img.shields.io/badge/HAProxy-Load_Balanced-106DA9?style=for-the-badge&logo=haproxy&logoColor=white)
![TLS](https://img.shields.io/badge/TLS-Multi_SAN-28a745?style=for-the-badge)

Cluster de 3 nodos OpenBao (fork de Vault) con almacenamiento Raft integrado, para gestión centralizada de secretos consumidos por ArgoCD vía AVP.

## Topología

| Nodo | IP | Rol |
|------|-----|-----|
| open-bao-1 | 192.168.253.30 | Raft peer |
| open-bao-2 | 192.168.253.31 | Raft peer |
| open-bao-3 | 192.168.253.32 | Raft peer |
| proxy-open-bao | 192.168.253.34 | HAProxy (endpoint HA) |

## Orden de Despliegue

### 1. Instalar y Configurar el Cluster Raft
**Carpeta**: [`open-bao-1/`](./open-bao-1/)

Proceso de instalación, init y unseal — mismo procedimiento para los 3 nodos, cambiando solo IP/hostname:
```bash
cd open-bao-1/
# Seguir README.md, repetir en open-bao-2/ y open-bao-3/ con su IP correspondiente
```

### 2. Configurar HAProxy (Endpoint HA)
**Carpeta**: [`proxy-open-bao/`](./proxy-open-bao/)

Balanceo y health-check para que los clientes siempre hablen con el líder activo:
```bash
cd proxy-open-bao/
# Seguir README.md
```

## Estado de Preparación

Al completar todos los pasos tendrás:
- **Cluster Raft** de 3 nodos inicializado y unsealed
- **Certificados multi-SAN** válidos para TLS Go
- **KV v2** habilitado en `secret/`
- **AppRole** configurado para consumo desde ArgoCD
- **HAProxy** dando HA transparente ante cambios de líder

![TLS](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/open-bao-1.png)
![TLS](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/open-bao-2.png)


## Siguiente Paso

Una vez el cluster está unsealed y el AppRole configurado, dirigirse a:
- **`../../infrastructure-applications/argocd/`** - Integración vía AVP sidecar
- **`../../infrastructure-applications/argocd-docker-build/`** - Imagen custom con AVP baked in

## Dependencias

- **Paso 1** requiere certificados generados (`../../requirements/certificate-server-config/`)
- **Paso 2** requiere el cluster Raft inicializado y unsealed (Paso 1)
- **ArgoCD** requiere AppRole configurado (Paso 1) antes de poder resolver secretos
