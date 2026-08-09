#######################################################
# Gitea Runners VMs
#######################################################
resource "proxmox_virtual_environment_vm" "gitea_runner" {
  count     = var.gitea_count_runners
  node_name = var.node_name
  name      = "${var.gitea_runners}-${format("%02d", count.index + 1)}"
  
  agent {
  enabled = false
  }

  # Clonar desde template
  clone {
    vm_id = 8000
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

  # Disco único para runners (no necesitan tanto almacenamiento)
  disk {
    interface      = "scsi0"
    datastore_id   = "local-lvm"
    size           = 30
    discard        = "on"
  }

  # Configuración de arranque
  boot_order = ["scsi0"]

  # Red - vmbr1 para runners
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  # Configuración adicional
  started = true
  stop_on_destroy = true

  # Tags para organización
  tags = ["terraform", "infrastructure", "gitea", "runner"]
}
