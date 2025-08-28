#!/bin/bash

cat > /etc/rc.local << 'EOF'
#!/bin/sh -e
#
# rc.local
#
sleep 60
cd /usr/local/bin && ./resize-docker-volumes.sh
exit 0
EOF

chmod +x /etc/rc.local
systemctl status rc-local.service
systemctl start rc-local.service
