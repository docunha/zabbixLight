### Execução do Script

```bash
./gerar_certificado.sh
Erro: Parâmetros inválidos.
Uso: ./gerar_certificado.sh <nome_do_certificado> <nome_da_ca>
Exemplo: ./gerar_certificado.sh zabbix_pfsense.lab.proxy zabbix_ca
```

```bash
./gerar_certificado.sh zabbix_pfsense.lab.proxy zabbix_ca
```

---

### 🧪 LAB

#### Make cert and key
```bash
openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout zabbix_pfsense.lab.key -out zabbix_pfsense.lab.csr -subj "/CN=ZabbixPfSenseLab/"
```

#### Sign cert
```bash
openssl x509 -req -sha256 -in zabbix_pfsense.lab.csr -CA zabbix_ca.crt -CAkey zabbix_ca.key -CAcreateserial -out zabbix_pfsense.lab.crt -days 1460
```

#### Check cert
```bash
openssl x509 -in zabbix_pfsense.lab.crt -noout -issuer -subject
```

---

### 🌐 LAB Proxy

#### Make cert and key
```bash
openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout zabbix_pfsense.lab.proxy.key -out zabbix_pfsense.lab.proxy.csr -subj "/CN=ZabbixPfSenseLabProxy/"
```

#### Sign cert
```bash
openssl x509 -req -sha256 -in zabbix_pfsense.lab.proxy.csr -CA zabbix_ca.crt -CAkey zabbix_ca.key -CAcreateserial -out zabbix_pfsense.lab.proxy.crt -days 1460
```

#### Check cert
```bash
openssl x509 -in zabbix_pfsense.lab.proxy.crt -noout -issuer -subject
```

---

### 🛡️ GUARDA

#### Make cert and key
```bash
openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout zabbix_GuardaBtu.key -out zabbix_GuardaBtu.csr -subj "/CN=ZabbixGuardaBtu/"
```

#### Sign cert
```bash
openssl x509 -req -sha256 -in zabbix_GuardaBtu.csr -CA zabbix_ca.crt -CAkey zabbix_ca.key -CAcreateserial -out zabbix_GuardaBtu.crt -days 1460
```

#### Check cert
```bash
openssl x509 -in zabbix_GuardaBtu.crt -noout -issuer -subject
```

---

### ⚙️ Configuração do Zabbix (`zabbix_agentd.conf`)

```ini
TLSConnect=cert
TLSAccept=cert
TLSCAFile=/etc/zabbix/certs/zabbix_ca.crt
TLSCertFile=/etc/zabbix/certs/zabbix_GuardaBtu.crt
TLSKeyFile=/etc/zabbix/certs/zabbix_GuardaBtu.key
```
