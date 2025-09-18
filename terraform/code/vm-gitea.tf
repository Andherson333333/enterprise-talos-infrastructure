resource "proxmox_virtual_environment_vm" "gitea_server" {
  node_name = var.node_name
  name      = "gitea-server"

  agent {
  enabled = false
  }
  
  clone {
    vm_id = 8001
    full  = true
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    interface      = "scsi0"
    datastore_id   = "local-lvm"
    size           = 20
    discard        = "on"
  }

  disk {
    interface      = "scsi1"
    datastore_id   = "local-lvm"
    size           = 20
    file_format    = "raw"
    discard        = "on"
  }

  boot_order = ["scsi0"]

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  started = true
  stop_on_destroy = true

  tags = ["terraform", "infrastructure"]
}
