**English** | [Español](./Readme.es.md)

# Terraform - VM Provisioning on Proxmox
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Air-Gapped](https://img.shields.io/badge/Mode-Air--Gapped-4B8BBE?style=for-the-badge)

Creates the environment VMs on Proxmox with the BPG provider (`proxmox_virtual_environment_vm`), cloning from templates.

## Contents

| Folder | Purpose | README |
|--------|---------|--------|
| `proxmox-connection/` | Proxmox API connection using the air-gapped Docker image `andherson1039/terraform-complete-airgap:2.0` (providers bundled) | [`proxmox-connection/Readme.md`](./proxmox-connection/Readme.md) |
| `code/` | VM definitions and their variables | [`code/Readme.md`](./code/Readme.md) |

## VMs created by `code/`

| File | VM | Template |
|------|----|----------|
| `vm-apt-ng.tf` | apt-cacher-ng | 8001 |
| `vm-harbor.tf` | Harbor | 8001 |
| `vm-frr.tf` | FRR x2 (`frr_nodes`) | 8002 |
| `vm-gitea.tf` | Gitea | 8001 |
| `vm-gitea-runners.tf` | Gitea runners (`gitea_count_runners`) | 8000 |
| `vm-taloscp-infra.tf` | Talos control plane (`control_plane_count`) | 9000 |
| `vm-talosdt-infra.tf` | Talos infra workers (`infra_worker_count`) | 9000 |
| `vm-talosdt-application.tf` | Talos app workers (`app_worker_count`) | 9000 |

Counts are set in `code/terraform.tfvars`.

The OpenBao VMs (`open-bao-1/2/3` and `proxy-open-bao`) were created manually from template 8002 (Debian 13); they are not managed by Terraform.

## Deployment Order

### 1. Verify the connection
```bash
cd proxmox-connection/
docker compose run --rm terraform init
docker compose run --rm terraform validate
```

### 2. Create the VMs
```bash
cd ../code/
terraform init
terraform plan
terraform apply
```

## Verification

```bash
terraform state list
```

![VMs on Proxmox](../images/proxmox-vms.png)

## Dependencies

- Proxmox API token (`../requirements/proxmox-api-token/`)
- Air-gapped Terraform bundle (`../requirements/terraform-images/`)
- Templates 8000, 8001 and 9000 created on Proxmox (`../requirements/debian12-templates/`, `../talos-linux/`)
