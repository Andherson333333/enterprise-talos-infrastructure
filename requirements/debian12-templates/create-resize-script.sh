#!/bin/bash

cat > /usr/local/bin/resize-docker-volumes.sh << 'EOF'
#!/bin/bash
pvresize /dev/sdb
lvextend -l +100%FREE /dev/vg_data/docker_data
resize2fs /dev/vg_data/docker_data
EOF

chmod +x /usr/local/bin/resize-docker-volumes.sh
