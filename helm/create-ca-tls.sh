#!/usr/bin/env bash
#
# Creates a CA certificate for TLS
#
# Usage:
#   ./create-ca-tls.sh [COMPANY_NAME]
#
# Example:
#   ./create-ca-tls.sh scalastic
#
# Arguments:
#   COMPANY_NAME: Name of the company (default: scalastic)
#
# Environment variables:
#   CERT_CA_PATH: Path to the CA certificate (default: openssl/ca)
#
# Requires:
#   - openssl
#
# References:
#   - https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
#   - https://devopscube.com/create-self-signed-certificates-openssl/

set -euo pipefail

COMPANY_NAME=${1:-macompanie}
CERT_CA_PATH="${CERT_CA_PATH:=openssl/ca}"

echo "Creating CA certificate..."

mkdir -p "${CERT_CA_PATH}"

openssl req -x509 \
    -sha512 -days 120 \
    -nodes \
    -newkey rsa:4096 \
    -subj "/CN=${COMPANY_NAME}-ca.local/C=FR/L=Paris/O=${COMPANY_NAME^}/OU=${COMPANY_NAME^} SSL CA Cert" \
    -keyout "${CERT_CA_PATH}/${COMPANY_NAME}-ca-tls.key" -out "${CERT_CA_PATH}/${COMPANY_NAME}-ca-tls.crt"
