#!/bin/sh
# /root/scripts/suricata_blocks_zbx.sh

LOGDIR="/var/log/suricata"
STATEDIR="/var/db/suricata_blocks"
ZBX_SERVER="172.16.5.123"          # ajuste para o IP do seu Zabbix Server
ZBX_HOST="PfSenseLab"     # nome do host cadastrado no Zabbix
ZBX_KEY="suricata.blocks.perminute"
ZBX_SENDER="/usr/local/bin/zabbix_sender"

mkdir -p "$STATEDIR"

DATA=""

for BLOCKLOG in "$LOGDIR"/suricata_*/block.log; do
    [ -f "$BLOCKLOG" ] || continue

    IFNAME=$(basename "$(dirname "$BLOCKLOG")" | sed 's/^suricata_//')
    STATE="$STATEDIR/${IFNAME}.state"

    CURR_INODE=$(stat -f%i "$BLOCKLOG")
    CURR_SIZE=$(stat -f%z "$BLOCKLOG")

    if [ -f "$STATE" ]; then
        LAST_INODE=$(awk '{print $1}' "$STATE")
        LAST_POS=$(awk '{print $2}' "$STATE")
    else
        LAST_INODE=""
        LAST_POS=0
    fi

    if [ "$CURR_INODE" != "$LAST_INODE" ] || [ "$CURR_SIZE" -lt "$LAST_POS" ]; then
        LAST_POS=0
    fi

    COUNT=$(tail -c +$((LAST_POS + 1)) "$BLOCKLOG" 2>/dev/null | grep -c '\[Block ')

    echo "$CURR_INODE $CURR_SIZE" > "$STATE"

    DATA="${DATA}${ZBX_HOST} ${ZBX_KEY}[${IFNAME}] ${COUNT}
"
done

printf '%s' "$DATA" | "$ZBX_SENDER" -z "$ZBX_SERVER" -i - >/dev/null 2>&1