# Proxmox User and Token for Terraform

![Proxmox](https://img.shields.io/badge/Proxmox-VE-E52F1F?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-BPG_Provider-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![API](https://img.shields.io/badge/API_Token-Authentication-28a745?style=for-the-badge)

Comandos para crear usuario y token API en Proxmox para automatización con Terraform usando el provider BPG.

## 1. Crear Usuario

```bash
# Crear usuario terraform en dominio PAM
pveum user add terraform@pam

```

## 2. Crear Rol con Permisos

```bash
# Crear rol TerraformProv con todos los permisos necesarios
pveum role add TerraformProv --privs "Datastore.AllocateSpace,Datastore.Audit,Pool.Allocate,SDN.Use,Sys.Audit,Sys.Console,Sys.Modify,VM.Allocate,VM.Audit,VM.Clone,VM.Config.CDROM,VM.Config.CPU,VM.Config.Cloudinit,VM.Config.Disk,VM.Config.HWType,VM.Config.Memory,VM.Config.Network,VM.Config.Options,VM.Migrate,VM.Monitor,VM.PowerMgmt"
```

## 3. Asignar Rol al Usuario

```bash
# Asignar rol en path raíz con propagación
pveum acl modify / --roles TerraformProv --users terraform@pam --propagate
```

## 4. Crear Token API

```bash
# Crear token que herede permisos del usuario
pveum user token add terraform@pam terraform --privsep 0 --comment "Terraform automation token"
```

**Resultado esperado:**
```
┌──────────────┬──────────────────────────────────────┐
│ key          │ value                                │
├──────────────┼──────────────────────────────────────┤
│ full-tokenid │ terraform@pam!terraform              │
├──────────────┼──────────────────────────────────────┤
│ value        │ 1160238f-41a8-49a8-99f3-3e5692324cca │
└──────────────┴──────────────────────────────────────┘
```

## 5. Usar Token en Terraform

### Entender el Token API

El token generado tiene **dos partes**:
- **Token ID**: `terraform@pam!terraform` (identificador)  
- **Token Secret**: `1160238f-41a8-49a8-99f3-3e5692324cca` (valor secreto)

**Para BPG provider**: Se combinan con `=` → `terraform@pam!terraform=1160238f-41a8-49a8-99f3-3e5692324cca`

### Configuración del Provider

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.80.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.1.100:8006/"
  api_token = "terraform@pam!terraform=1160238f-41a8-49a8-99f3-3e5692324cca"
  insecure = true  # Si usas certificados auto-firmados
}
```

### Variables de Entorno (Recomendado)

```bash
# Configurar variables de entorno
export PM_API_URL="https://192.168.1.100:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!terraform"
export PM_API_TOKEN_SECRET="1160238f-41a8-49a8-99f3-3e5692324cca"
```

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.80.0"
    }
  }
}

provider "proxmox" {
  # Las variables de entorno se usan automáticamente
  insecure = true  # Si usas certificados auto-firmados
}
```

## Verificar Configuración

```bash
# Ver permisos del usuario
pveum user permissions terraform@pam

# Ver permisos del token
pveum user token permissions terraform@pam terraform

# Listar tokens
pveum user token list terraform@pam
```
Tambien puedes verificar via web con promox

Verificacion de usuario 
![Terraform](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/config-token-1.png)

Verificacion permisos usarios
![Terraform](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/config-token-2.png)

Verificacion permisos token
![Terraform](https://github.com/Andherson333333/enterprise-talos-infrastructure/blob/main/images/config-token-3.png)

## Datos de Conexión

- **API URL**: `https://tu-proxmox-ip:8006/api2/json`
- **Token ID**: `terraform@pam!terraform`
- **Token Secret**: El valor generado en el paso 4
- **Insecure**: `true` (si usas certificados auto-firmados)
