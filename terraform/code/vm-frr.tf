resource "proxmox_virtual_environment_vm" "frr" {
  for_each = toset(var.frr_nodes)

  node_name = var.node_name
  name      = each.value

  agent {
    enabled = false
  }

  clone {
    vm_id = 8002
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
    interface    = "scsi0"
    datastore_id = "local-lvm"
    size         = 20
    iothread     = true
    discard      = "on"
  }

  boot_order = ["scsi0"]

  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  network_device {
    bridge   = "vmbr1"
    model    = "virtio"
    firewall = true
  }

  started         = true
  stop_on_destroy = true

  tags = ["terraform", "infrastructure", "bgp"]
}
