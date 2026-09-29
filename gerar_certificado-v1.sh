#!/bin/bash

# Configura o script para parar se ocorrer qualquer erro
set -e

# Validação dos parâmetros de entrada
if [ "$#" -ne 2 ]; then
    echo "Erro: Parâmetros inválidos."
    echo "Uso: $0 <nome_do_certificado> <nome_da_ca>"
    echo "Exemplo: $0 zabbix_pfsense.lab.proxy zabbix_ca"
    exit 1
fi

# Atribuição das variáveis
CERT_NAME="$1"
CA_NAME="$2"

# 1. Criar a chave privada e a requisição (CSR)
echo "=== [1/3] Gerando chave privada e CSR ==="
openssl req -new -nodes -sha256 -newkey rsa:2048 \
    -keyout "${CERT_NAME}.key" \
    -out "${CERT_NAME}.csr" \
    -subj "/CN=${CERT_NAME}/"

# 2. Assinar o certificado usando a CA fornecida
echo "=== [2/3] Assinando o certificado com a CA: ${CA_NAME} ==="
openssl x509 -req -sha256 \
    -in "${CERT_NAME}.csr" \
    -CA "${CA_NAME}.crt" \
    -CAkey "${CA_NAME}.key" \
    -CAcreateserial \
    -out "${CERT_NAME}.crt" \
    -days 1460

# 3. Verificar o certificado gerado
echo "=== [3/3] Verificando o certificado gerado ==="
openssl x509 -in "${CERT_NAME}.crt" -noout -issuer -subject

echo "=== Processo concluído com sucesso! ==="

