#!/bin/bash
set -e

K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -o k9s.tar.gz
tar -xzf k9s.tar.gz k9s
mv k9s /usr/local/bin/
chmod +x /usr/local/bin/k9s
rm k9s.tar.gz
k9s version
