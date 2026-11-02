#!/bin/bash
# Prueba REAL de las vías de restauración del VPS.
# (La vía D = GitHub se verifica desde la PC, porque el VPS no tiene llave
#  de GitHub a propósito: el espejo automático es una mejora pendiente.)
f=0
ok(){ echo "  ok   $1"; }
mal(){ echo "  MAL  $1"; f=$((f+1)); }
existe(){ if [ -n "$1" ] && [ -e "$1" ]; then ok "$2"; else mal "$2"; fi; }

echo "═══ PRUEBA DE RESTAURACIÓN ═══"

echo ""
echo "── VÍA A: kit de Telegram ──"
Z=$(sudo ls -t /var/backups/marketattack/kits/*.zip | head -1)
D=/tmp/prueba_A
sudo rm -rf "$D"; mkdir -p "$D"; sudo cp "$Z" "$D/"
bash /usr/local/bin/recuperar.sh A "$D" "$D/$(basename "$Z")" >/dev/null 2>&1
existe "$(find "$D" -maxdepth 1 -name CONTEXTO.md | head -1)" "restauró CONTEXTO.md"
existe "$(find "$D" -maxdepth 2 -name conversacion.md | head -1)" "restauró la conversación"
existe "$(find "$D" -name puente_telegram.py | head -1)" "restauró los scripts"
existe "$(find "$D" -name opencode.service | head -1)" "restauró la configuración saneada"
sudo rm -rf "$D"

echo ""
echo "── VÍA B: respaldo completo del VPS ──"
r=$(sudo ls -t /var/backups/marketattack/completos/completo_*.tar.gz | head -1)
D=/tmp/prueba_B
sudo rm -rf "$D"; sudo mkdir -p "$D"
sudo tar -xzf "$r" -C "$D" 2>/dev/null
existe "$D/ESTADO.txt" "ESTADO.txt recuperable"
existe "$D/SHA256SUMS" "SHA256SUMS recuperable"
existe "$D/contenido/web/index.html" "sitio web recuperable"
existe "$D/contenido/scripts/kit_recuperacion.sh" "scripts recuperables"
db=$(sudo find "$D" -name 'chat_*.db' | head -1)
if [ -n "$db" ]; then
  n=$(sudo python3 -c "import sqlite3;print(sqlite3.connect('$db').execute('select count(*) from message').fetchone()[0])" 2>/dev/null)
  [ -n "$n" ] && ok "chat recuperable ($n mensajes)" || mal "la DB no abre"
else
  mal "no hay DB en el respaldo"
fi
if sudo bash -c "cd '$D' && sha256sum -c --quiet SHA256SUMS" >/dev/null 2>&1; then
  ok "los checksums cuadran"
else
  mal "checksums no cuadran"
fi
sudo rm -rf "$D"

echo ""
echo "── VÍA C: espejo interno ──"
a=$(sudo ls -t /var/backups/marketattack/completos/completo_*.tar.gz | head -1)
b=$(sudo ls -t /root/marketattack-rescate/completo_*.tar.gz | head -1)
[ "$(basename "$a")" = "$(basename "$b")" ] && ok "espejo al día ($(basename "$b"))" || mal "espejo desfasado"
sudo tar -tzf "$b" >/dev/null 2>&1 && ok "el espejo se lee" || mal "espejo ilegible"

echo ""
if [ "$f" -eq 0 ]; then echo "RESULTADO: todas las vías restauran de verdad"; else echo "RESULTADO: $f FALLOS"; fi
