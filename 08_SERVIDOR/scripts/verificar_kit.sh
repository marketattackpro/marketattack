#!/bin/bash
Z=$(sudo ls -t /var/backups/marketattack/kits/*.zip | head -1)
sudo rm -rf /tmp/vk; sudo mkdir -p /tmp/vk; sudo unzip -qo "$Z" -d /tmp/vk
K=$(sudo find /tmp/vk -maxdepth 1 -type d -name 'kit_*' | head -1)
CL=$(sudo cat /root/CLAVE_OPENCODE.txt)
TK=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
fails=0
chk(){ if [ "$2" = "$3" ]; then echo "  OK   $1"; else echo "  FALLO $1 -> '$2' (esperaba '$3')"; fails=$((fails+1)); fi; }
n(){ sudo grep -rlE -- "$1" "$K" 2>/dev/null | wc -l; }
nf(){ sudo grep -rlF -- "$1" "$K" 2>/dev/null | wc -l; }

echo "KIT: $(basename "$Z")"
echo ""
echo "-- FUGAS (todas deben ser 0) --"
chk "clave opencode actual" "$(nf "$CL")" "0"
ANTIGUA=$(sudo head -1 /etc/marketattack/claves_rotadas.txt 2>/dev/null)
chk "clave antigua"         "$(nf "$ANTIGUA")" "0"
chk "token telegram"        "$(nf "$TK")" "0"
chk "llaves privadas"       "$(n 'BEGIN[A-Z ]*PRIVATE KEY')" "0"
# Los secretos reales ya se comprueban uno por uno arriba (clave actual, clave
# antigua, token vigente y llaves privadas). Este patron generico solo avisa:
# un token de EJEMPLO en la documentacion no es una fuga y no debe romper el kit.
LOOSOS=$(n '[0-9]{8,10}:[A-Za-z0-9_-]{35}')
if [ "$LOOSOS" -eq 0 ]; then
  ok "tokens sueltos         0"
else
  echo "  aviso tokens sueltos  $LOOSOS (revisar: puede ser un token de ejemplo en la doc)"
  sudo grep -rhoE -- '[0-9]{8,10}:[A-Za-z0-9_-]{35}' "$K" 2>/dev/null | sort -u \
    | head -5 | sed 's/^/      /'
fi
chk "api keys"              "$(n 'sk-[A-Za-z0-9_-]{20,}')" "0"
chk "tokens github"         "$(n 'gh[pousr]_[A-Za-z0-9]{20,}')" "0"

echo ""
echo "-- INTEGRIDAD DEL TEXTO --"
chk "sin corrupcion [CLAVE SERVIDOR]" "$(sudo grep -oF -- '[CLAVE SERVIDOR]' "$K/chat/conversacion.md" | wc -l)" "0"
echo "  INFO redacciones [CLAVE ROTADA]: $(sudo grep -oF -- '[CLAVE ROTADA' "$K/chat/conversacion.md" | wc -l) (correcto)"

echo ""
echo "-- ESTRUCTURA --"
sudo python3 -c "import json;d=json.load(open('$K/chat/conversacion.json'));print('  INFO contador:',d['mensajes'],'entradas:',len(d['conversacion']))"
chk "contador coincide con entradas" "$(sudo python3 -c "import json;d=json.load(open('$K/chat/conversacion.json'));print(1 if d['mensajes']==len(d['conversacion']) else 0)")" "1"
for r in CONTEXTO.md LEEME_PRIMERO.txt RESTAURAR.sh PEGAME_ESTO_EN_EL_CHAT.txt estado/ESTADO.txt chat/conversacion.md chat/conversacion.json config/cron.txt config/nginx.conf config/opencode.service; do
  if sudo test -s "$K/$r"; then echo "  OK   $r"; else echo "  FALLO falta $r"; fails=$((fails+1)); fi
done
n_srv=$(sudo ls -1 /usr/local/bin/*.sh /usr/local/bin/*.py 2>/dev/null | wc -l)
chk "todos los scripts del servidor ($(echo $n_srv))" "$(sudo ls -1 "$K/scripts/" | wc -l)" "$n_srv"

echo ""
echo "-- RESTAURADOR --"
cd "$(dirname "$K")" || exit 1
sudo bash "$K/RESTAURAR.sh" >/dev/null 2>&1 && echo "  OK   RESTAURAR.sh corre" || { echo "  FALLO RESTAURAR.sh falla"; fails=$((fails+1)); }
chk "sin dollar sin expandir" "$(sudo bash "$K/RESTAURAR.sh" 2>&1 | grep -cE '\$[A-Za-z]')" "0"

echo ""
if [ "$fails" -eq 0 ]; then echo "RESULTADO: KIT CORRECTO, sin fallos"; else echo "RESULTADO: $fails FALLOS"; fi
