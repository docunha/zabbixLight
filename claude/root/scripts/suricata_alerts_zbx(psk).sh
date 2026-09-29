#!/bin/sh
# /root/scripts/suricata_alerts_zbx.sh
#
# Conta linhas novas de bloqueio em cada alerts.log (uma por interface Suricata)
# desde a ultima execução, e envia via zabbix_sender (trapper) com TLS/PSK
# para o Zabbix Proxy local. Roda a cada minuto via cron (Services > Cron na GUI).
#
# Novas interfaces adicionadas depois sao pegas automaticamente pelo
# glob "suricata_*/alerts.log" -- so e preciso criar o item trapper correspondente
# no Zabbix quando isso acontecer (key: suricata.alerts.perminute[NOME_INTERFACE]).

LOGDIR="/var/log/suricata"
STATEDIR="/var/db/suricata_alerts"

ZBX_HOST="firewall.jdband"
ZBX_KEY="suricata.alerts.perminute"
ZBX_SENDER="/usr/local/bin/zabbix_sender"
ZBX_SERVER="127.0.0.1"

TLS_PSK_IDENTITY="pskAgent"
TLS_PSK_FILE="/usr/local/etc/zabbix64/zabbix_agentd.psk"

mkdir -p "$STATEDIR"

DATA=""

for ALERTLOG in "$LOGDIR"/suricata_*/alerts.log; do
    [ -f "$ALERTLOG" ] || continue

    IFNAME=$(basename "$(dirname "$ALERTLOG")" | sed 's/^suricata_//')
    STATE="$STATEDIR/${IFNAME}.state"

    CURR_INODE=$(stat -f%i "$ALERTLOG")
    CURR_SIZE=$(stat -f%z "$ALERTLOG")

    if [ -f "$STATE" ]; then
        LAST_INODE=$(awk '{print $1}' "$STATE")
        LAST_POS=$(awk '{print $2}' "$STATE")
    else
        LAST_INODE=""
        LAST_POS=0
    fi

    # rotacionou (inode mudou) OU arquivo encolheu -> reinicia leitura
    if [ "$CURR_INODE" != "$LAST_INODE" ] || [ "$CURR_SIZE" -lt "$LAST_POS" ]; then
        LAST_POS=0
    fi

    COUNT=$(tail -c +$((LAST_POS + 1)) "$ALERTLOG" 2>/dev/null | grep -c '\[* ')

    echo "$CURR_INODE $CURR_SIZE" > "$STATE"

    DATA="${DATA}${ZBX_HOST} ${ZBX_KEY}[${IFNAME}] ${COUNT}
"
done

printf '%s' "$DATA" | "$ZBX_SENDER" \
    -z "$ZBX_SERVER" \
    -i - \
    --tls-connect psk \
    --tls-psk-identity "$TLS_PSK_IDENTITY" \
    --tls-psk-file "$TLS_PSK_FILE" \
    >/dev/null 2>&1
