resource "proxmox_virtual_environment_vm" "talos_worker" {
  count     = var.infra_worker_count
  node_name = "pve-1"
  name      = "${var.infra_node_prefix}-dt-${format("%02d", count.index + 1)}"

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  disk {
    interface    = "scsi0"
    datastore_id = "local-lvm"
    size         = 20
    discard      = "on"
  }

  disk {
    interface    = "scsi1"
    datastore_id = "local-lvm"
    size         = 20
    discard      = "on"
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  started = true
  tags    = ["talos", "worker"]
}
