#!/bin/bash
KITS=/var/backups/marketattack/kits
TCONF=/etc/marketattack/telegram.conf
RAP=$(ls -1t "$KITS"/RESTAURACION_RAPIDA_*.md 2>/dev/null | head -1)
[ -n "$RAP" ] || { echo "no hay archivo rápido"; exit 1; }
T=$(sudo grep TELEGRAM_TOKEN "$TCONF" | cut -d= -f2- | tr -d '"')
C=$(sudo grep TELEGRAM_CHAT_ID "$TCONF" | cut -d= -f2- | tr -d '"')
[ -z "$T" ] || [ -z "$C" ] && { echo "sin token/chat"; exit 1; }
curl -s --max-time 120 -F "chat_id=$C" -F "document=@$RAP" -F "caption=MARKETATTACK — RESTAURACION_RAPIDA.md · Pega este archivo a un NUEVO CHAT en opencode. Después escribe: lee este archivo y retoma MARKETATTACK" "https://api.telegram.org/bot$T/sendDocument" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('  envío archivo único:', 'OK' if d.get('ok') else 'FALLÓ '+str(d.get('description')))
"
