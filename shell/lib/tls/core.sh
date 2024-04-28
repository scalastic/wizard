#!/usr/bin/env bash

# shellcheck source-path=shell
. "${SHELL_DIR}/lib/core/logger.sh"


tls.create_server_cert() {
    local server="${1:-server}"
    local company="${2:-scalastic}"
    local cert_path="${3:-tmp/openssl}"
    local ca_key_cert_path="${4:-${cert_path}/${company}-ca-tls}"

    log.info "Creating ${server} certificate with CA ${ca_key_cert_path}.crt..."

    if [ ! -f "${ca_key_cert_path}.crt" ] && [ ! -f "${ca_key_cert_path}.key" ]; then
        log.info "No existing CA certificate found with name ${ca_key_cert_path}.crt"
        command.run_function tls.__create_ca_cert "${company}" "${cert_path}"
    fi

    command.run_function tls.__create_server_cert "${server}" "${company}" "${cert_path}" "${ca_key_cert_path}"

    command.run_function tls.__cleanup "${cert_path}"
}

tls.__create_ca_cert() {
    local company="${1}"
    local ca_cert_path="${2}"

    log.info "Creating CA certificate..."

    mkdir -p "${ca_cert_path}"
    local ca_key_cert_path="${ca_cert_path}/${company}-ca-tls"

    openssl req -x509 \
    -sha512 -days 120 \
    -nodes \
    -newkey rsa:4096 \
    -subj "/CN=${company}-ca.local/C=FR/L=Paris/O=${company^}/OU=${company^} SSL CA Cert" \
    -keyout "${ca_key_cert_path}.key" -out "${ca_key_cert_path}.crt"

    log.info "CA certificate created."
    echo "${ca_key_cert_path}"
}

tls.__create_server_cert() {
    local server="${1}"
    local company="${2}"
    local cert_path="${3}"
    local ca_key_cert_path="${4}"

    log.info "Creating ${server} certificate with CA cert ${ca_key_cert_path}..."

    mkdir -p "${cert_path}"
    local ca_crt_file="${ca_key_cert_path}.crt"
    local ca_key_file="${ca_key_cert_path}.key"

    local private_key_file
    private_key_file="$(tls.__create_private_key "${server}" "${cert_path}")"

    local csr_config_file
    csr_config_file="$(tls.__create_csr_config "${server}" "${company}" "${cert_path}")"

    local csr_file
    csr_file="$(tls.__create_csr "${server}" "${private_key_file}" "${csr_config_file}" "${cert_path}")"

    local cert_config_file
    cert_config_file="$(tls.__create_cert_config "${server}" "${company}" "${cert_path}")"

    local cert_file
    cert_file="$(tls.__create_cert "${server}" "${company}" "${csr_file}" "${cert_config_file}" "${ca_crt_file}" "${ca_key_file}" "${cert_path}")"
    
    log.info "${server} certificate is :"
    echo "${cert_file}"
}

tls.__create_private_key() {
    local server="${1}"
    local private_key_path="${2}"

    log.info "Creating private key for ${server}..."

    mkdir -p "${private_key_path}"
    local private_key_file="${private_key_path}/${server}-tls.key"

    openssl genrsa -out "${private_key_file}" 4096

    log.info "Private key for ${server} created at ${private_key_file}."
    echo "${private_key_file}"
}

tls.__create_csr_config() {
    local server="${1}"
    local company="${2}"
    local csr_path="${3}"

    log.info "Creating CSR config file for ${server}..."

    local config_file="${csr_path}/${server}-csr.conf"
    local csr_file="${csr_path}/${server}-tls.csr"

    cat >"${config_file}" <<EOF

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
    O = "${company^}"
    OU = "${server^} ${company^} Local"
    CN = "${server}.${company}.local"

    [ req_ext ]
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.1 = "${server}.${company}.local"
    IP.1 = 127.0.0.1
EOF

    log.info "CSR config file created at ${config_file}."
    echo "${config_file}"
}

tls.__create_cert_config() {
    local server="${1}"
    local company="${2}"
    local cert_path="${3}"

    log.info "Creating CERT config file for ${server}..."

    local config_file="${cert_path}/${server}-cert.conf"

    cat >"${config_file}" <<EOF

    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [ dn ]
    C = FR
    ST = France
    L = Paris
    O = "${company^}"
    OU = "${server^} ${company^} Local"
    CN = "${server}.${company}.local"
    
    [ req_ext ]
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.1 = "${server}.${company}.local"
    IP.1 = 127.0.0.1
EOF

    log.info "CERT config file created at ${config_file}."
    echo "${config_file}"
}

tls.__create_csr() {
    local server="${1}"
    local private_key_file="${2}"
    local config_file="${3}"
    local csr_path="${4}"

    log.info "Creating CSR for ${server}..."

    local csr_file="${csr_path}/${server}-tls.csr"

    openssl req -new -key "${private_key_file}" -out "${csr_file}" -config "${config_file}"

    log.info "CSR for ${server} created at ${csr_file}."
    echo "${csr_file}"
}

tls.__create_cert() {
    local server="${1}"
    local company="${2}"
    local csr_file="${3}"
    local cert_config_file="${4}"
    local ca_crt_file="${5}"
    local ca_key_file="${6}"
    local cert_path="${7}"

    log.info "Creating certificate for ${server}..."

    local cert_file="${cert_path}/${server}-tls.crt"

    openssl x509 -req \
        -in "./${csr_file}" \
        -CA "./${ca_crt_file}" \
        -CAkey "./${ca_key_file}" \
        -CAcreateserial \
        -days 120 \
        -sha512 \
        -extfile "${cert_config_file}" \
        -out "./${cert_file}"

    log.info "Certificate for ${server} created at ${cert_file}."
    echo "${cert_file}"
}

tls.__cleanup() {
    local cert_path="${1}"

    log.info "Cleaning up ${cert_path}..."

    rm "${cert_path}"/*.conf "${cert_path}"/*.csr "${cert_path}"/*.srl

    log.info "Cleanup complete."
}
