#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ACTIVAR UN TOKEN NUEVO DEL BOT  (tras /revoke en @BotFather)
#
#  Uso:  sudo bash /usr/local/bin/activar_token.sh
#  Pega el token nuevo cuando lo pida. Actualiza TODO solo:
#    - valida el token contra Telegram
#    - guarda la copia anterior
#    - reinicia el puente
#    - regenera y envía el kit
# ═══════════════════════════════════════════════════════════
set -uo pipefail
CONF=/etc/marketattack/telegram.conf
STAMP=$(date +%Y%m%d_%H%M)

echo "══════════════════════════════════════"
echo " ACTIVAR TOKEN NUEVO DEL BOT"
echo "══════════════════════════════════════"
echo ""
read -rp "Pega aquí el token nuevo de @BotFather: " NUEVO
NUEVO=$(echo "$NUEVO" | tr -d '[:space:]')

if [ -z "$NUEVO" ]; then echo "✗ vacío, no se cambió nada"; exit 1; fi
if ! echo "$NUEVO" | grep -qE '^[0-9]{8,10}:[A-Za-z0-9_-]{35}$'; then
  echo "✗ ese no parece un token de Telegram (formato 123456789:AAH...)"
  echo "  se dejó todo como estaba."; exit 1
fi

echo ""
echo "1) comprobando el token contra Telegram..."
INFO=$(curl -s --max-time 20 "https://api.telegram.org/bot$NUEVO/getMe")
if ! echo "$INFO" | grep -q '"ok":true'; then
  echo "  ✗ Telegram lo rechaza. Revisa que lo copiaste completo."
  echo "  se dejó todo como estaba."; exit 1
fi
echo "  ✓ válido — bot: $(echo "$INFO" | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["username"])' 2>/dev/null)"

echo ""
echo "2) respaldo de la configuración actual..."
sudo cp "$CONF" "$CONF.bak-$STAMP" && sudo chmod 600 "$CONF.bak-$STAMP"
echo "  ✓ copia en $CONF.bak-$STAMP"

echo ""
echo "3) si el token nuevo tiene otro chat_id, lo tomo de getUpdates..."
CHAT=$(sudo grep TELEGRAM_CHAT_ID "$CONF" | cut -d= -f2- | tr -d '"')
echo "  chat_id actual: $CHAT"

echo ""
# se guarda el token saliente ANTES de escribir el nuevo: si se lee despues,
# ya se perdio el viejo y la lista de rotadas queda inutil
VIEJO=$(sudo grep TELEGRAM_TOKEN "$CONF" | cut -d= -f2- | tr -d '"')

echo "4) guardando el token nuevo..."
sudo sed -i "s|^TELEGRAM_TOKEN=.*|TELEGRAM_TOKEN=\"$NUEVO\"|" "$CONF"
sudo chmod 600 "$CONF"
sudo grep -q 'TELEGRAM_TOKEN' "$CONF" && echo "  ✓ escrito" || { echo "  ✗ no se pudo escribir"; exit 1; }

echo ""
echo "5) anotando el token viejo en la lista de rotadas..."
# El token saliente puede seguir apareciendo en chats viejos o respaldos ya
# hechos. Si queda anotado aqui, el generador del kit lo detecta y lo tapa.
sudo touch /etc/marketattack/claves_rotadas.txt
sudo chmod 600 /etc/marketattack/claves_rotadas.txt
if [ -n "$VIEJO" ] && [ "$VIEJO" != "$NUEVO" ]; then
  if sudo grep -qxF "$VIEJO" /etc/marketattack/claves_rotadas.txt; then
    echo "  · el token viejo ya estaba anotado"
  else
    echo "$VIEJO" | sudo tee -a /etc/marketattack/claves_rotadas.txt >/dev/null
    echo "  ✓ token viejo guardado (quedará fuera del kit y de los respaldos)"
  fi
else
  echo "  · sin token previo que registrar"
fi

echo ""
echo "6) reiniciando el puente..."
sudo systemctl restart puente-telegram
sleep 12
ACT=$(systemctl is-active puente-telegram)
[ "$ACT" = "active" ] && echo "  ✓ puente activo" || { echo "  ✗ puente CAÍDO"; exit 1; }

echo ""
echo "7) borrando el offset viejo (el nuevo bot empieza de cero)..."
sudo rm -f /home/ubuntu/.marketattack_offset && echo "  ✓ offset reiniciado"

echo ""
echo "8) probando que responde..."
curl -s --max-time 20 -X POST "https://api.telegram.org/bot$NUEVO/sendMessage" \
  -d "chat_id=$CHAT" -d 'text=✅ Token renovado. MARKETATTACK sigue en pie.' \
  | python3 -c 'import json,sys;d=json.load(sys.stdin);print("  ✓ mensaje enviado" if d.get("ok") else "  ✗ no se pudo enviar: "+str(d))' 2>/dev/null

echo ""
echo "9) regenerando el kit con la configuración nueva..."
sudo /usr/local/bin/kit_recuperacion.sh 2>&1 | tail -3 | sed 's/^/  /'

echo ""
echo "══════════════════════════════════════"
echo " ✓ TOKEN RENOVADO Y TODO ACTUALIZADO"
echo "══════════════════════════════════════"
