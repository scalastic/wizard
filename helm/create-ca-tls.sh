#!/usr/bin/env bash

set -euo pipefail

COMPANY_NAME=${1:-scalastic}
CERT_CA_PATH="${CERT_CA_PATH:=openssl/ca}"

echo "Creating CA certificate..."

mkdir -p "${CERT_CA_PATH}"

openssl req -x509 \
    -sha512 -days 120 \
    -nodes \
    -newkey rsa:4096 \
    -subj "/CN=${COMPANY_NAME}-ca.local/C=FR/L=Paris/O=${COMPANY_NAME^}/OU=${COMPANY_NAME^} SSL CA Cert" \
    -keyout "${CERT_CA_PATH}/${COMPANY_NAME}-ca-tls.key" -out "${CERT_CA_PATH}/${COMPANY_NAME}-ca-tls.crt"
