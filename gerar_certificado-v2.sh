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

# Define o nome do diretório alvo
DIR_CERTIFICADOS="certificados"

# Garante que o diretório 'certificados' existe
mkdir -p "$DIR_CERTIFICADOS"

# 1. Criar a chave privada e a requisição (CSR)
echo "=== [1/3] Gerando chave privada e CSR ==="
openssl req -new -nodes -sha256 -newkey rsa:2048 \
    -keyout "${DIR_CERTIFICADOS}/${CERT_NAME}.key" \
    -out "${DIR_CERTIFICADOS}/${CERT_NAME}.csr" \
    -subj "/CN=${CERT_NAME}/"

# 2. Assinar o certificado usando a CA fornecida (buscando e salvando dentro da pasta certificados)
echo "=== [2/3] Assinando o certificado com a CA: ${CA_NAME} ==="
openssl x509 -req -sha256 \
    -in "${DIR_CERTIFICADOS}/${CERT_NAME}.csr" \
    -CA "${DIR_CERTIFICADOS}/${CA_NAME}.crt" \
    -CAkey "${DIR_CERTIFICADOS}/${CA_NAME}.key" \
    -CAcreateserial \
    -out "${DIR_CERTIFICADOS}/${CERT_NAME}.crt" \
    -days 1460

# 3. Verificar o certificado gerado
echo "=== [3/3] Verificando o certificado gerado ==="
openssl x509 -in "${DIR_CERTIFICADOS}/${CERT_NAME}.crt" -noout -issuer -subject

echo "=== Processo concluído com sucesso! Arquivos salvos em ./${DIR_CERTIFICADOS}/ ==="
