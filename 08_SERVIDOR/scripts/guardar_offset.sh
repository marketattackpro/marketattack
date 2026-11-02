#!/bin/bash
# Guarda el último update_id confirmado para que el puente NO reenvíe
# el historial tras un reinicio. Telegram dice "ok":true solo si ya se leyó.
TOKEN=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
OFF=$(sudo cat /home/ubuntu/.marketattack_offset 2>/dev/null || echo 0)
r=$(curl -s --max-time 20 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFF&timeout=2")
n=$(echo "$r" | grep -oE '"update_id":[0-9]+' | grep -oE '[0-9]+' | tail -1)
if [ -n "$n" ]; then
  echo "$((n+1))" | sudo tee /home/ubuntu/.marketattack_offset >/dev/null
  sudo chmod 600 /home/ubuntu/.marketattack_offset
  echo "  ✓ offset anclado en $((n+1))"
else
  echo "  cola vacía: se deja offset=$OFF"
fi
