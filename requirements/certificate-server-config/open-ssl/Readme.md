**English** | [Español](./Readme.es.md)

# OpenSSL Certificate Generator (Simple)

![OpenSSL](https://img.shields.io/badge/OpenSSL-Latest-721412?style=for-the-badge&logo=openssl&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Required-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![SSL](https://img.shields.io/badge/SSL_Certificates-Generated-28a745?style=for-the-badge)

Direct OpenSSL commands to generate SSL certificates for Gitea, Harbor and wildcard.

## 1. Create the Certificate Authority

```bash
# Create directories
mkdir -p certs/{ca,gitea,harbor,wildcard}

# Generate CA key
openssl genrsa -out certs/ca/rootCA.key 4096

# Generate CA certificate
openssl req -x509 -new -nodes -key certs/ca/rootCA.key -sha256 -days 3650 -out certs/ca/rootCA.pem -subj "/CN=Local CA"
```

## 2. Gitea Certificates

```bash
# Generate key
openssl genrsa -out certs/gitea/gitea.key 2048

# Generate CSR
openssl req -new -key certs/gitea/gitea.key -out certs/gitea/gitea.csr -subj "/CN=gitea.server.local"

# Create SAN config
cat > certs/gitea/gitea.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = gitea.server.local
DNS.2 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.253.11
EOF

# Generate certificate
openssl x509 -req -in certs/gitea/gitea.csr -CA certs/ca/rootCA.pem -CAkey certs/ca/rootCA.key -CAcreateserial -out certs/gitea/gitea.crt -days 365 -sha256 -extfile certs/gitea/gitea.ext

# Clean up
rm certs/gitea/gitea.csr certs/gitea/gitea.ext
```

## 3. Harbor Certificates

```bash
# Generate key
openssl genrsa -out certs/harbor/harbor.key 2048

# Generate CSR
openssl req -new -key certs/harbor/harbor.key -out certs/harbor/harbor.csr -subj "/CN=registry.harbor.local"

# Create SAN config
cat > certs/harbor/harbor.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = registry.harbor.local
DNS.2 = harbor.server.local
DNS.3 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.133.20
IP.3 = 192.168.253.12
EOF

# Generate certificate
openssl x509 -req -in certs/harbor/harbor.csr -CA certs/ca/rootCA.pem -CAkey certs/ca/rootCA.key -CAcreateserial -out certs/harbor/harbor.crt -days 365 -sha256 -extfile certs/harbor/harbor.ext

# Clean up
rm certs/harbor/harbor.csr certs/harbor/harbor.ext
```

## 4. Wildcard Certificates

```bash
# Generate key
openssl genrsa -out certs/wildcard/wildcard.key 2048

# Generate CSR
openssl req -new -key certs/wildcard/wildcard.key -out certs/wildcard/wildcard.csr -subj "/CN=*.local"

# Create SAN config
cat > certs/wildcard/wildcard.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.local
DNS.2 = local
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF

# Generate certificate
openssl x509 -req -in certs/wildcard/wildcard.csr -CA certs/ca/rootCA.pem -CAkey certs/ca/rootCA.key -CAcreateserial -out certs/wildcard/wildcard.crt -days 365 -sha256 -extfile certs/wildcard/wildcard.ext

# Clean up
rm certs/wildcard/wildcard.csr certs/wildcard/wildcard.ext
```

## Verify

```bash
# Show certificate
openssl x509 -in certs/gitea/gitea.crt -text -noout

# Verify against the CA
openssl verify -CAfile certs/ca/rootCA.pem certs/gitea/gitea.crt
```

## Install the CA

```bash
# Ubuntu/Debian
sudo cp certs/ca/rootCA.pem /usr/local/share/ca-certificates/rootCA.crt
sudo update-ca-certificates
```

## Clean up everything

```bash
rm -rf certs/
```
