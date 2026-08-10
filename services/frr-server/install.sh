#!/bin/bash
set -e

# Instalación base de FRR — idéntica en frr-01 y frr-02
# Prerequisito: Debian 12 (Bookworm) con IP estática ya configurada en /etc/network/interfaces

# Repo oficial de FRR
apt install -y curl gnupg lsb-release
curl -s https://deb.frrouting.org/frr/keys.gpg | tee /usr/share/keyrings/frrouting.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/frrouting.gpg] https://deb.frrouting.org/frr $(lsb_release -s -c) frr-stable" | tee /etc/apt/sources.list.d/frr.list
apt update && apt install -y frr frr-pythontools

# Habilitar solo bgpd — el resto apagado
sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons

# IP forwarding (necesario para rutear)
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Iniciar FRR
systemctl enable frr
systemctl start frr
systemctl status frr
