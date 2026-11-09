**English** | [Español](./Readme.es.md)

# Services

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Services](https://img.shields.io/badge/Services-Enterprise-4CAF50?style=for-the-badge&logo=kubernetes&logoColor=white)

Suite of automated enterprise services for the infrastructure, built with Ansible playbooks.

**Features**:
- **Full automation**: Deployment without manual intervention
- **Self-signed SSL certificates**: Secure communication preconfigured  
- **Offline installation**: Works without internet access once downloaded
- **Idempotent**: Playbooks can be re-run safely

## Available Services

### Base Infrastructure

| Service | Purpose | README |
|---------|---------|--------|
| **shared-infrastructure** | Base prerequisites (proxy, Docker, certificates) | [`shared-infrastructure/Readme.md`](./shared-infrastructure/Readme.md) |

### Application Services

| Service | Purpose | README |
|---------|---------|--------|
| **harbor-server** | Private container registry | [`harbor-server/Readme.md`](./harbor-server/Readme.md) |
| **gitea-server** | Enterprise Git server | [`gitea-server/Readme.md`](./gitea-server/Readme.md) |
| **apt-cacher-ng** | APT package cache proxy | [`apt-cacher-ng/Readme.md`](./apt-cacher-ng/Readme.md) |

## Implementation Order

### 1. Base Infrastructure (REQUIRED)
```bash
cd shared-infrastructure/
# Follow the README steps (proxy → Docker → certificates)
```

### 2. Application Services (OPTIONAL - as needed)
```bash
# Container registry
cd harbor-server/

# Git server  
cd gitea-server/

# APT cache
cd apt-cacher-ng/
```

## Full Implementation

```bash
# 1. Base infrastructure
cd shared-infrastructure/
ansible-playbook -i inventory infrastructure-setup.yml

# 2. Services (example with all of them)
cd ../harbor-server/
ansible-playbook -i inventory harbor-install.yml

cd ../apt-cacher-ng/
ansible-playbook -i inventory apt-cacher-ng.yml

cd ../gitea-server/ 
ansible-playbook -i inventory gitea-install.yml
```

## Where to Start?

1. **New user**: Run `shared-infrastructure` first
2. **Container registry**: Go to `harbor-server`
3. **Git server**: Go to `gitea-server`  
4. **APT cache**: Go to `apt-cacher-ng`

---

**Note**: `shared-infrastructure` is a mandatory prerequisite. The other services are independent of each other.
