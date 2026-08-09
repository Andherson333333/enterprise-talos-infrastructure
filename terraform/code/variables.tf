# Variables de conexión Proxmox - SIN defaults (valores críticos)
variable "proxmox_endpoint" {
  description = "Proxmox VE endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token"
  type        = string
  sensitive   = true
}

# Variables con defaults sensatos - raramente cambian
variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve-1"
}

# Variables de cluster - SIN defaults (configuración consciente)
variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
}

# Variables de workers - SIN defaults (decisión consciente)
variable "infra_worker_count" {
  description = "Number of infrastructure worker nodes"
  type        = number
}

variable "infra_node_prefix" {
  description = "Infrastructure node name prefix"
  type        = string
}

variable "app_worker_count" {
  description = "Number of application worker nodes"
  type        = number
}

variable "app_node_prefix" {
  description = "Application node name prefix"
  type        = string
}

# Variables de Gitea - SIN defaults (configuración explícita)
variable "gitea_runners" {
  description = "Gitea runners name prefix"
  type        = string
}

variable "gitea_count_runners" {
  description = "Number of Gitea runners to deploy"
  type        = number
}
