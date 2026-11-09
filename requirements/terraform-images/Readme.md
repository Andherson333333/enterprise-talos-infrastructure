**English** | [Español](./Readme.es.md)

# Terraform Air-gapped Bundle

![Terraform](https://img.shields.io/badge/Terraform-1.9.0+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Required-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Talos](https://img.shields.io/badge/Talos-Linux-000000?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Self-contained Terraform bundle for environments without internet access. Includes the Proxmox and Talos providers and popular modules in a portable Docker image.

## Features

- **Providers**: bpg/proxmox, telmate/proxmox, siderolabs/talos, hashicorp/*
- **15+ modules** preloaded for VMs, LXCs and Kubernetes
- **100% offline** once built

## Process

1. **Online machine**: Build the bundle with its dependencies
2. **Offline machine**: Transfer the bundle and use it with Docker

## Phase 1: Build (Online Machine)

**Requirements**: Terraform v1.9.0+, Git

### 1. Initial structure

```bash
mkdir -p terraform-proxmox-airgap/{modules,mirror}
cd terraform-proxmox-airgap
```

### 2. Configure providers

```bash
cat > main.tf << 'EOF'
terraform {
  required_providers {
    proxmox = { source  = "bpg/proxmox", version = "~> 0.80.0" }
    telmate = { source = "telmate/proxmox", version = "~> 2.9" }
    talos = { source  = "siderolabs/talos", version = "~> 0.8.0" }
    local = { source  = "hashicorp/local", version = "~> 2.4" }
    http = { source  = "hashicorp/http", version = "~> 3.4" }
    random = { source  = "hashicorp/random", version = "~> 3.5" }
    null = { source  = "hashicorp/null", version = "~> 3.2" }
    time = { source  = "hashicorp/time", version = "~> 0.10" }
  }
}
provider "proxmox" {}
provider "talos" {}
provider "local" {}
provider "http" {}
provider "random" {}
provider "null" {}
provider "time" {}
EOF
```

### 3. Download providers

```bash
terraform init
terraform providers mirror -platform=linux_amd64 -platform=linux_arm64 ./mirror
```

### 4. Download modules

```bash
cd modules

# BPG modules
git clone https://github.com/trfore/terraform-bpg-proxmox.git bpg-trfore && rm -rf bpg-trfore/.git
git clone https://github.com/DacoDev/terraform-module-proxmox-lxc.git bpg-lxc-daco && rm -rf bpg-lxc-daco/.git
git clone https://github.com/f1uff3h/terraform-bpg-pve-lxc.git bpg-f1uff3h-lxc && rm -rf bpg-f1uff3h-lxc/.git
git clone https://github.com/kencx/homelab.git bpg-kencx-homelab && rm -rf bpg-kencx-homelab/.git

# Telmate modules
git clone https://github.com/trfore/terraform-telmate-proxmox.git telmate-trfore && (cd telmate-trfore && git checkout v3 && rm -rf .git)
git clone https://github.com/rkoosaar/terraform-proxmox-vm.git telmate-rkoosaar-vm && (cd telmate-rkoosaar-vm && rm -rf .git)

# Talos modules
git clone https://github.com/rgl/terraform-proxmox-talos.git talos-rgl-complete && rm -rf talos-rgl-complete/.git
git clone https://github.com/kubebn/talos-proxmox-kaas.git talos-kaas-gitops && rm -rf talos-kaas-gitops/.git
git clone https://github.com/sergelogvinov/terraform-talos.git talos-sergei-multicloud && rm -rf talos-sergei-multicloud/.git

cd ..
```

### 5. Configure offline mode

```bash
cat > .terraformrc << 'EOF'
provider_installation {
  filesystem_mirror {
    path    = "/terraform-mirror"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
plugin_cache_dir = "/terraform-cache"
EOF
```

### 6. Create the Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM debian:bookworm-slim

ENV TERRAFORM_VERSION=1.9.0
ENV ARCH=amd64

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -d /usr/local/bin && \
    rm "terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./mirror /terraform-mirror
COPY ./modules /opt/proxmox-terraform-modules
COPY ./.terraformrc /root/.terraformrc
COPY ./.terraformrc /etc/terraformrc

RUN mkdir -p /terraform-cache
WORKDIR /terraform
ENTRYPOINT ["terraform"]
CMD ["--help"]
EOF
```

### 7. Package the bundle

```bash
rm main.tf .terraform.lock.hcl
rm -rf .terraform
cd ..
tar -czf "terraform-airgap-bundle-$(date +%Y%m%d).tar.gz" "terraform-proxmox-airgap/"
```

## Phase 2: Usage (Offline Machine)

**Requirement**: Docker

### 1. Extract and build

```bash
tar -xzf terraform-airgap-bundle-*.tar.gz
cd terraform-proxmox-airgap
docker build -t terraform-airgap:latest .
```

### 2. Use Terraform

```bash
# In your project directory
docker run --rm -it -v "$(pwd):/terraform" terraform-airgap:latest init
docker run --rm -it -v "$(pwd):/terraform" terraform-airgap:latest plan
docker run --rm -it -v "$(pwd):/terraform" terraform-airgap:latest apply
```

### Recommended alias

```bash
alias terraform='docker run --rm -it -v "$(pwd):/terraform" -v "$HOME/.ssh:/root/.ssh:ro" terraform-airgap:latest'
```

Then use `terraform` as usual:
```bash
terraform plan
terraform apply
```

## Note: if you don't want to go through this process, you can pull the prebuilt image from Docker Hub: `andherson1039/terraform-complete-airgap:2.0`
