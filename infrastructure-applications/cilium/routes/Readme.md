# Routes - Hubble UI
![Gateway API](https://img.shields.io/badge/Gateway_API-HTTPRoute-60B932?style=for-the-badge)

`HTTPRoute` para exponer Hubble UI a través del Gateway API.

## Recursos

| Archivo | Detalle |
|---------|---------|
| `https.yaml` | `HTTPRoute` de `hubble.local` vía `infra-gateway` (sección `https`), más redirect HTTP → HTTPS (sección `http`) |

## Dependencias

- `infra-gateway` desplegado en el namespace `gateway-system` (ver `../../gateway-api/`)
- Hubble UI habilitado en `values.yaml` del chart principal (`hubble.ui.enabled: true`)
