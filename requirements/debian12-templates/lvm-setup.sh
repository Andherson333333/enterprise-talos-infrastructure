#!/bin/bash

pvcreate /dev/sdb
vgcreate vg_data /dev/sdb  
lvcreate -n docker_data -l 100%FREE vg_data
mkfs.ext4 /dev/vg_data/docker_data
mkdir -p /var/lib/docker/volumes
mount /dev/vg_data/docker_data /var/lib/docker/volumes
echo "/dev/vg_data/docker_data /var/lib/docker/volumes ext4 defaults 0 2" >> /etc/fstab
