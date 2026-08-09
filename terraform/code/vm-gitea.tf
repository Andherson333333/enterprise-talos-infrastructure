#######################################################
# Gitea Server VM
#######################################################
resource "proxmox_virtual_environment_vm" "gitea_server" {
  node_name = var.node_name
  name      = "gitea-server"
  
  agent {
  enabled = false
  }

  # Clonar desde template
  clone {
    vm_id = 8001
    full  = true
  }

  # CPU y Memoria
  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  # Disco primario con discard habilitado (para SSD/thin provisioning)
  disk {
    interface      = "scsi0"
    datastore_id   = "local-lvm"
    size           = 20
    discard        = "on"
  }
  
  # Disco secundario para datos
  disk {
    interface      = "scsi1"
    datastore_id   = "local-lvm"
    size           = 20
    file_format    = "raw"
    discard        = "on"
  }

  # Configuración de arranque
  boot_order = ["scsi0"]

  # Red - Solo vmbr1 para Gitea server
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  # Configuración adicional
  started = true
  stop_on_destroy = true

  # Tags para organización
  tags = ["terraform", "infrastructure"]
}
