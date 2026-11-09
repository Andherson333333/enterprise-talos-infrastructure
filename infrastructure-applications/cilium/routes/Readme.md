**English** | [Español](./Readme.es.md)

# Routes - Hubble UI
![Gateway API](https://img.shields.io/badge/Gateway_API-HTTPRoute-60B932?style=for-the-badge)

`HTTPRoute` that exposes the Hubble UI through the Gateway API.

## Resources

| File | Detail |
|------|--------|
| `https.yaml` | `HTTPRoute` for `hubble.local` via `infra-gateway` (`https` section), plus HTTP → HTTPS redirect (`http` section) |

## Dependencies

- `infra-gateway` deployed in the `gateway-system` namespace (see `../../gateway-api/`)
- Hubble UI enabled in the main chart `values.yaml` (`hubble.ui.enabled: true`)
