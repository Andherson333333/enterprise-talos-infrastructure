resource "proxmox_virtual_environment_vm" "gitea_runner" {
  count     = var.gitea_count_runners
  node_name = var.node_name
  name      = "${var.gitea_runners}-${format("%02d", count.index + 1)}"

  agent {
  enabled = false
  }
  
  clone {
    vm_id = 8000
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
    size           = 30
    discard        = "on"
  }

  boot_order = ["scsi0"]

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  started = true
  stop_on_destroy = true

  # Tags para organización
  tags = ["terraform", "infrastructure", "gitea", "runner"]
}
