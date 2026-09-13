# ArgoCD Custom Image - AVP Baked In
![Docker](https://img.shields.io/badge/Docker-Custom_Build-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-v3.5.2-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![AVP](https://img.shields.io/badge/AVP-1.18.1-FFEC6E?style=for-the-badge)
![Harbor](https://img.shields.io/badge/Harbor-Registry-60B932?style=for-the-badge&logo=harbor&logoColor=white)

Imagen custom de ArgoCD con `argocd-vault-plugin` (AVP) integrado, necesaria porque la imagen oficial no incluye `curl`/`wget` para descargar el binario en runtime.

## Orden de Build

### 1. Descargar Binario AVP
Descargar en `pve-1` (tiene acceso a internet), ya que la imagen base de ArgoCD no tiene herramientas de descarga:
```bash
wget https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v1.18.1/argocd-vault-plugin_1.18.1_linux_amd64
```

### 2. Build de la Imagen
**Carpeta**: [`./`](./)
```bash
cd infrastructure-applications/argocd-docker-build/
docker build -t registry.harbor.local/docker-images/argocd:v3.5.2-custom .
```

El `Dockerfile` hace:
- `COPY` del binario AVP descargado manualmente (no `curl` en build)
- `update-ca-certificates` con la CA de Harbor baked in, para pull/push interno con TLS

### 3. Push a Harbor
```bash
docker push registry.harbor.local/docker-images/argocd:v3.5.2-custom
```

## Estado de Preparación

Al completar el build tendrás:
- **Imagen ArgoCD** con AVP 1.18.1 embebido
- **CA de Harbor** confiada dentro del contenedor
- **Imagen publicada** en `registry.harbor.local/docker-images/argocd:v3.5.2-custom`

## Verificación

```bash
# Exec en el sidecar avp del repo-server
kubectl exec -it <argocd-repo-server-pod> -c avp -n argocd -- sh

# Dentro del pod, contra un manifest de prueba con <path:secret/data/test#hello>
argocd-vault-plugin generate .
# Debe resolver a: world
```

## Siguiente Paso

Una vez la imagen está en Harbor, dirigirse a:
- **`../argocd/`** - Referenciar la imagen en `values.yaml` del repo-server

## Dependencias

- **Paso 1** requiere acceso a internet (solo disponible en `pve-1`)
- **Paso 3** requiere Harbor funcionando y login configurado
- **`../argocd/`** requiere esta imagen publicada antes de poder resolver secretos de OpenBao
