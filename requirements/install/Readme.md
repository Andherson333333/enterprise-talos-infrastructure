**English** | [Español](./Readme.es.md)

# DevOps Tools Installer

![Kubernetes](https://img.shields.io/badge/kubectl-Latest-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Latest-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Latest-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Latest-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-Ubuntu-A81D33?style=for-the-badge&logo=debian&logoColor=white)

Automated script that installs essential DevOps, Kubernetes and automation tools on Debian/Ubuntu systems.

## Included tools

- **kubectl**: Kubernetes command-line client
- **Terraform**: Infrastructure as code tool
- **Ansible**: IT automation platform
- **Helm**: Kubernetes package manager

## Installation

### 1. Clone the repository

```bash
git clone 
cd enterprise-talos-infrastructure/Requirements/install
```

### 2. Run the installer

```bash
# Make scripts executable
chmod +x install.sh
chmod +x install-argocd-cli.sh
chmod +x install-k9s.sh


# Run script
./install.sh
```

## Requirements

- Operating system: Debian/Ubuntu
- sudo permissions
- Internet access

## Verification

The script automatically verifies the installations by printing the versions:

```bash
kubectl version --client
terraform --version
ansible --version
helm version
argocd-cli
k9s
```

## Compatibility

- Debian 11+
- Ubuntu 20.04+
- Architecture: amd64
