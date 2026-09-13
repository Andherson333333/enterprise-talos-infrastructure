# ArgoCD - GitOps Controller
![ArgoCD](https://img.shields.io/badge/ArgoCD-v3.5.2-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![HA](https://img.shields.io/badge/Mode-HA_2_Replicas-4B8BBE?style=for-the-badge)
![AVP](https://img.shields.io/badge/AVP-OpenBao_Integration-FFEC6E?style=for-the-badge)
![Harbor](https://img.shields.io/badge/Chart-OCI_Harbor-60B932?style=for-the-badge&logo=harbor&logoColor=white)

Wrapper chart de ArgoCD en modo HA, con `argocd-vault-plugin` (AVP) integrado como sidecar del repo-server para resolver secretos desde OpenBao en tiempo de sync.

## Componentes

| Componente | Detalle |
|------------|---------|
| Chart base | `argo-cd` 10.4.2 (appVersion `v3.5.2`), vía OCI desde `oci://registry.harbor.local/helm-charts` |
| Imagen | `registry.harbor.local/docker-images/argocd:v3.5.2-custom` (ver [`../argocd-docker-build/`](../argocd-docker-build/)) |
| Redis | `redis-ha` (Sentinel), reemplaza el `redis` standalone por defecto |
| Dex | `registry.harbor.local/proxy-ghcr/dexidp/dex:v2.45.1` |
| Secrets | AVP sidecar en `repoServer`, resuelve `<path:secret/data/...#key>` contra OpenBao |

## Alta Disponibilidad

- `controller`, `server` y `repoServer`: **2 réplicas** cada uno, con `podAntiAffinity` (preferred) por `kubernetes.io/hostname` — evita que las 2 réplicas de un mismo componente caigan en el mismo nodo
- `redis-ha`: Sentinel habilitado (`redis.enabled: false`, `redis-ha.enabled: true`)
- Scheduling: todo el release usa `nodeSelector: workload-type: infrastructure` + toleration `PreferNoSchedule`

## TLS: Passthrough hasta el Gateway

`server.insecure: true` y `*.repo.server.plaintext: "true"` porque TLS se termina en el Gateway API (`../gateway-api/`), no dentro de ArgoCD. El `templates/https.yaml` de este chart expone el `HTTPRoute`/`Certificate` correspondiente — ArgoCD en sí corre en texto plano puertas adentro del cluster.

## Integración AVP + OpenBao

El sidecar `avp` en `repoServer`:
- Imagen: la misma custom (`v3.5.2-custom`) con el binario AVP baked in
- Monta la CA de OpenBao (`templates/openbao-ca-configmap.yaml`) en `/vault/tls`
- Monta el plugin config (`templates/cmp-plugin-configmap.yaml`) en `/home/argocd/cmp-server/config/plugin.yaml`
- Toma `VAULT_ADDR` y credenciales del AppRole desde `templates/vault-configuration-secret.yaml` (`envFrom.secretRef: vault-configuration`)

## Orden de Despliegue

### 1. Requisitos previos
- Imagen custom publicada — ver [`../argocd-docker-build/`](../argocd-docker-build/)
- Cluster OpenBao inicializado y AppRole configurado — ver [`../../services/openbao-server/`](../../services/openbao-server/)

### 2. Configurar Secret de Vault
`templates/vault-configuration-secret.yaml` requiere `VAULT_ADDR` (endpoint HAProxy de OpenBao) y credenciales del AppRole:
```bash
# VAULT_ADDR=https://192.168.253.34:8200
```

### 3. Instalar/Actualizar el Release
```bash
cd infrastructure-applications/argocd/
helm dependency update
helm upgrade --install argocd . -n argocd --create-namespace
```

## Estado de Preparación

Al completar el despliegue tendrás:
- **ArgoCD HA** con 2 réplicas por componente crítico
- **Sync de manifiestos** resolviendo secretos de OpenBao en tiempo real vía AVP
- **TLS terminado en el Gateway**, ArgoCD sirviendo en texto plano internamente

## Nota Operacional: Dependencia de OpenBao

Si OpenBao se sella (por ejemplo, tras reiniciar las VMs del cluster), el sidecar AVP falla con `503` al intentar hacer login vía AppRole. Verificar y desellar OpenBao antes de asumir que el problema está en ArgoCD — ver [`../../services/openbao-server/`](../../services/openbao-server/).

## Verificación

```bash
# Pods en Running, 2 réplicas por componente
kubectl get pods -n argocd

# Confirmar resolución de secretos desde el sidecar avp
kubectl exec -it <argocd-repo-server-pod> -c avp -n argocd -- sh
argocd-vault-plugin generate .
# Debe resolver <path:secret/data/test#hello> → world
```

## Evidencia de Funcionamiento

![AVP Secret Resolution](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/argocd-vaul-1.png)

![AVP Secret Resolution](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/argocd-vaul-3.png)

*Resolución exitosa de `<path:secret/data/test#hello>` → `world` desde el sidecar AVP del repo-server, confirmando el pipeline completo: ArgoCD → HAProxy → OpenBao líder.*

## Siguiente Paso

Con ArgoCD operativo, las aplicaciones GitOps del resto de `infrastructure-applications/` (cilium, gateway-api, grafana-alloy, loki, longhorn, prometheus-stack, tempo, tetragon) se sincronizan a través de este controlador.

## Dependencias

- **Paso 2** requiere OpenBao inicializado y AppRole con policy de solo lectura (`../../services/openbao-server/`)
- **Paso 3** requiere la imagen custom publicada en Harbor (`../argocd-docker-build/`)
