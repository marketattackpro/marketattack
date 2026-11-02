#!/bin/bash
# Fija el offset de getUpdates para que NUNCA se procese un mensaje dos veces
# tras un reinicio. Sin esto, reiniciar el puente = repetir todo el historial.
TOKEN=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
OFFSET=$(sudo grep -oE '"offset":[0-9]+' /home/ubuntu/.marketattack_offset 2>/dev/null | grep -oE '[0-9]+')
[ -z "$OFFSET" ] && OFFSET=0
echo "offset guardado: $OFFSET"
r=$(curl -s --max-time 20 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&limit=1")
n=$(echo "$r" | grep -oE '"update_id":[0-9]+' | grep -oE '[0-9]+' | head -1)
if [ -n "$n" ]; then
  nuevo=$((n+1))
  echo "$nuevo" | sudo tee /home/ubuntu/.marketattack_offset >/dev/null
  sudo chmod 600 /home/ubuntu/.marketattack_offset
  echo "  ✓ anclado en offset=$nuevo (el update_id $n ya no se volverá a procesar)"
else
  echo "  no hay actualizaciones pendientes"
fi
