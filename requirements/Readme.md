**English** | [Español](./Readme.es.md)

# Requirements - Deployment Guide

![Infrastructure](https://img.shields.io/badge/Infrastructure-Setup-4B8BBE?style=for-the-badge)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Ready-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![SSL](https://img.shields.io/badge/SSL_Certificates-Generated-28a745?style=for-the-badge)

Step-by-step guide to prepare every requirement before deploying the infrastructure.

## Deployment Order

### 1. Prepare Base Images
**Folder**: [`iso/`](./iso/)

Download and verify the ISO images for the base installation:
- Proxmox VE (hypervisor)
- Debian GNU/Linux (VM templates)

```bash
cd iso/
# Follow README.md to download verified ISOs
```

### 2. Install Working Tools
**Folder**: [`install/`](./install/)

Install the DevOps toolset on your workstation:
- kubectl, Terraform, Ansible, Helm

```bash
cd install/
chmod +x install.sh
./install.sh
```

### 3. Prepare Air-gapped Terraform
**Folder**: [`terraform-images/`](./terraform-images/)

Build an offline Terraform bundle with providers and modules:
- Providers: BPG, Telmate, Talos
- Popular modules pre-downloaded
- Portable Docker image

```bash
cd terraform-images/
# Follow the 2-phase process (online → offline)
```

### 4. Configure the Proxmox API
**Folder**: [`proxmox-api-token/`](./proxmox-api-token/)

Create a user and API token for Terraform automation:
- User `terraform@pam`
- Role with full permissions
- API token for the BPG provider

```bash
# Run the commands from README.md
```

### 5. Generate SSL Certificates
**Folder**: [`certificate-server-config/`](./certificate-server-config/)

Create SSL certificates for the services (choose one method):
- **Automated**: Ansible + mkcert containers
- **Manual**: Direct OpenSSL commands

```bash
cd certificate-server-config/
# Choose: ansible-ssl/ or open-ssl/
```

### 6. Create the Debian 12 template
**Folder**: [`debian12-templates/`](./debian12-templates/)

Create the Debian 12 template
- **Storage**: Docker on sdb to store data
- **Automated**: sdb resized automatically based on its size

## Readiness State

After all the steps you will have:

-  **Proxmox VE** installed and running
-  **DevOps tools** on the workstation
-  **Terraform bundle** ready for air-gapped environments
-  **API token** configured for Terraform
-  **SSL certificates** for every service
-  **Debian 12 template** for VMs

## Next Step

Once these requirements are complete, go to:
- **`../terraform/`** - Implementation and deployments
- **`../services/`** - Application configuration

## Dependencies

Each step may depend on the previous one:
- **Step 3** requires the tools installed (Step 2)
- **Step 4** requires Proxmox running (Step 1) and the Terraform bundle (Step 3)
- **Step 5** (SSL certificates) can run independently
