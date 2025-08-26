variable "proxmox_endpoint" {
  description = "Proxmox VE endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token"
  type        = string
  sensitive   = true
}

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
