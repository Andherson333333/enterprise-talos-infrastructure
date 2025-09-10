resource "proxmox_virtual_environment_vm" "talos_cp" {
  count     = var.control_plane_count
  node_name = "pve-1"
  name      = "${var.cluster_name}-cp-${format("%02d", count.index + 1)}"

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = 4
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

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  started = true
  tags    = ["talos", "cp"]
}
