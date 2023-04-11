#!/usr/bin/env bash
#
# Creates a wildcard server certificate for TLS with a self signed CA
#
# Usage:
#   ./create-wildcard-cert-server.sh [SERVER_NAME] [COMPANY_NAME]
#
# Example:
#   ./create-wildcard-cert-server.sh server scalastic
#
# Arguments:
#   SERVER_NAME: Name of the server (default: server)
#   COMPANY_NAME: Name of the company (default: scalastic)
#
# Environment variables:
#   CERT_CA_PATH: Path to the CA certificate (default: openssl/ca)
#   CERT_PATH: Path to the certificate (default: openssl)
#
# Requires:
#   - openssl
#
# References:
#   - https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
#   - https://devopscube.com/create-self-signed-certificates-openssl/


set -euo pipefail

SERVER_NAME=${1:-server}
COMPANY_NAME=${COMPANY_NAME:=scalastic}
CERT_CA_PATH="${CERT_CA_PATH:=openssl/ca}"
CERT_PATH="openssl"

echo "Creating ${SERVER_NAME} certificate..."

mkdir -p "$CERT_PATH"

# Create the Server Private Key
openssl genrsa -out "./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.key" 4096

# Create Certificate Signing Request Configuration
cat > "./${CERT_PATH}/${SERVER_NAME}-wildcard-csr.conf" <<EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha512
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = FR
ST = France
L = Paris
O = "${COMPANY_NAME^}"
OU = "${SERVER_NAME^} ${COMPANY_NAME^} Local"
CN = "${COMPANY_NAME}.local"

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = "${COMPANY_NAME}.local"
DNS.2 = "*.${COMPANY_NAME}.local"
IP.1 = 192.168.0.10
IP.2 = 192.168.0.10

EOF

# Generate Certificate Signing Request (CSR) Using Server Private Key
openssl req -new -key "./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.key" -out "./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.csr" -config "./${CERT_PATH}/${SERVER_NAME}-wildcard-csr.conf"

# Create a cert.conf
cat > ./${CERT_PATH}/cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[ dn ]
C = FR
ST = France
L = Paris
O = "${COMPANY_NAME^}"
OU = "${SERVER_NAME^} ${COMPANY_NAME^} Local"
CN = "${COMPANY_NAME}.local"

[ alt_names ]
DNS.1 = "${COMPANY_NAME}.local"
DNS.2 = "*.${COMPANY_NAME}.local"
IP.1 = 192.168.0.10
IP.2 = 192.168.0.10

EOF

# Generate SSL certificate With self signed CA
openssl x509 -req \
    -in "./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.csr" \
    -CA "./${CERT_CA_PATH}/${COMPANY_NAME}-ca-tls.crt" -CAkey "./${CERT_CA_PATH}/${COMPANY_NAME}-ca-tls.key" \
    -CAcreateserial -out "./${CERT_PATH}/${SERVER_NAME}-wildcard-tls.crt" \
    -days 120 \
    -sha512 -extfile ./${CERT_PATH}/cert.conf

rm -f "${CERT_PATH}"/*.conf
rm -f "${CERT_PATH}"/*.csr
rm -f "${CERT_CA_PATH}"/*.srl