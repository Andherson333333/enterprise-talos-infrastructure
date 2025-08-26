# Terraform Air-gapped Bundle

![Terraform](https://img.shields.io/badge/Terraform-1.9.0+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Required-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Talos](https://img.shields.io/badge/Talos-Linux-000000?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Bundle de Terraform auto-contenido para entornos sin conexión a internet. Incluye providers de Proxmox, Talos y módulos populares en una imagen Docker portable.

## Características

- **Providers**: bpg/proxmox, telmate/proxmox, siderolabs/talos, hashicorp/*
- **15+ módulos** pre-cargados para VMs, LXCs y Kubernetes
- **100% offline** una vez construido

## Proceso

1. **Máquina Online**: Crear bundle con dependencias
2. **Máquina Offline**: Transferir bundle y usar con Docker

## Fase 1: Creación (Máquina Online)

**Requisitos**: Terraform v1.9.0+, Git

### 1. Estructura inicial

```bash
mkdir -p terraform-proxmox-airgap/{modules,mirror}
cd terraform-proxmox-airgap
```

### 2. Configurar providers

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

### 3. Descargar providers

```bash
terraform init
terraform providers mirror -platform=linux_amd64 -platform=linux_arm64 ./mirror
```

### 4. Descargar módulos

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

### 5. Configurar offline mode

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

### 6. Crear Dockerfile

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

### 7. Empaquetar bundle

```bash
rm main.tf .terraform.lock.hcl
rm -rf .terraform
cd ..
tar -czf "terraform-airgap-bundle-$(date +%Y%m%d).tar.gz" "terraform-proxmox-airgap/"
```

## Fase 2: Uso (Máquina Offline)

**Requisito**: Docker

### 1. Descomprimir y construir

```bash
tar -xzf terraform-airgap-bundle-*.tar.gz
cd terraform-proxmox-airgap
docker build -t terraform-airgap:latest .
```

### 2. Usar Terraform

```bash
# En tu directorio de proyecto
docker run --rm -it -v "$(pwd):/terraform" terraform-airgap:latest init
docker run --rm -it -v "$(pwd):/terraform" terraform-airgap:latest plan
docker run --rm -it -v "$(pwd):/terraform" terraform-airgap:latest apply
```

### Alias recomendado

```bash
alias terraform='docker run --rm -it -v "$(pwd):/terraform" -v "$HOME/.ssh:/root/.ssh:ro" terraform-airgap:latest'
```

Después puedes usar `terraform` normalmente:
```bash
terraform plan
terraform apply
```

## Nota : si no quieres hacer este proceso puedes descargar la imagen desde docker hub andherson1039/terraform-complete-airgap:2.0

