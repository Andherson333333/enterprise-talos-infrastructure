FROM quay.io/argoproj/argocd:v3.5.2

USER root

COPY *.crt /usr/local/share/ca-certificates/
RUN chmod 644 /usr/local/share/ca-certificates/*.crt && \
    update-ca-certificates && \
    echo "=== Certificados CA personalizados instalados ===" && \
    ls -la /usr/local/share/ca-certificates/ && \
    echo "=== Verificando certificados en store ===" && \
    ls -la /etc/ssl/certs/ | grep -E "(gitea|harbor|192|rootCA)" || echo "Certificados procesados"

COPY argocd-vault-plugin /usr/local/bin/argocd-vault-plugin
RUN chmod +x /usr/local/bin/argocd-vault-plugin && \
    echo "=== AVP instalado ===" && \
    /usr/local/bin/argocd-vault-plugin version

USER 999
