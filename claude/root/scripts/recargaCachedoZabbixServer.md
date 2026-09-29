
### Recarregue o cache no Zabbix Server:
No servidor Zabbix, execute o comando:bash
```ini
zabbix_server -R config_cache_reload
```

---

### Recarregue o cache no Zabbix Proxy:
No host onde o Zabbix Proxy está instalado, execute o comando:bash
```ini
zabbix_proxy -R config_cache_reload
```