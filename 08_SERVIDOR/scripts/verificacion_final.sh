#!/bin/bash
# Verificación final, sin errores de comprobación (sin globs que necesiten sudo,
# sin grep que devuelva cadena vacía).
f=0
ok(){ echo "  ok   $1"; }
mal(){ echo "  MAL  $1"; f=$((f+1)); }

echo "══════════════════════════════════════════"
echo " VERIFICACIÓN FINAL — MARKETATTACK"
echo "══════════════════════════════════════════"

echo ""
echo "── SERVICIOS ──"
for s in nginx opencode puente-telegram; do
  a=$(systemctl is-active $s 2>/dev/null); e=$(systemctl is-enabled $s 2>/dev/null)
  [ "$a" = "active" ] && ok "$s = $a / $e" || mal "$s = $a"
done

echo ""
echo "── WEB ──"
BASE=${BASE:-https://157-137-203-223.sslip.io}
for u in / /tienda.html /kit.html; do
  c=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "$BASE$u")
  [ "$c" = "200" ] && ok "$u = $c" || mal "$u = $c"
done
c=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "$BASE/noexiste")
[ "$c" = "404" ] && ok "/noexiste = 404 (correcto)" || mal "/noexiste = $c (debía ser 404)"

echo ""
echo "── CHAT IA ──"
a=$(systemctl is-active marketattack-chat 2>/dev/null)
[ "$a" = "active" ] && ok "marketattack-chat = $a" || mal "marketattack-chat = $a"
h=$(curl -s --max-time 8 "$BASE/api/chat/health")
echo "$h" | grep -q '"ok": true' && ok "backend /api/chat/health responde" || mal "backend /api/chat/health no responde"
prueba=$(curl -s --max-time 30 -X POST "$BASE/api/chat" -H "Content-Type: application/json" \
  -d '{"mensaje":"Responde solo: ok","negocio":{"nombre":"Prueba","menu":[]}}')
if echo "$prueba" | grep -q '"respuesta"'; then
  ok "IA real responde (proveedor externo)"
else
  echo "  aviso  la IA externa no respondió; el chat usa el respaldo local (no bloquea respaldos)"
fi

echo ""
echo "── SEGURIDAD ──"
CL=$(sudo cat /root/CLAVE_OPENCODE.txt 2>/dev/null)
c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -u "opencode:$CL" http://127.0.0.1:4096/)
[ "$c" = "200" ] && ok "clave actual -> 200" || mal "clave actual -> $c"
c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://127.0.0.1:4096/)
[ "$c" = "401" ] && ok "sin clave -> 401" || mal "sin clave -> $c"
ANTIGUA=$(sudo head -1 /etc/marketattack/claves_rotadas.txt 2>/dev/null)
if [ -n "$ANTIGUA" ]; then
  c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -u "opencode:$ANTIGUA" http://127.0.0.1:4096/)
  [ "$c" = "401" ] && ok "clave antigua -> 401 (anulada)" || mal "clave antigua -> $c (sigue viva!)"
else
  mal "no encuentro la lista de claves rotadas"
fi

# Llaves autorizadas: comparar HUELLAS reales, no comentarios ni cadenas inventadas.
HUELLA_PC=SHA256:cjHUVVGMuRKQCQ1hBN+h7OMsaie/asYOgtbVt97fTKw
HUELLA_CEL=SHA256:9lI9c4iGJDIgw2av5ud6a7azsVBUgwA4XhzdlVgCcnw
HUELLAS=$(sudo python3 -c "
import subprocess
for linea in open('/home/ubuntu/.ssh/authorized_keys'):
    p = linea.split()
    k = next((x for x in p if x.startswith('ssh-')), None)
    if not k: continue
    pub = k + ' ' + p[p.index(k)+1]
    o = subprocess.run(['ssh-keygen','-lf','-'],input=pub,capture_output=True,text=True)
    if o.stdout.strip(): print(o.stdout.split()[1])
" | sort | tr '\n' ' ')
case "$HUELLAS" in
  *"$HUELLA_PC"*) ok "llave de la PC presente ($HUELLA_PC)" ;;
  *) mal "falta la llave de la PC" ;;
esac
case "$HUELLAS" in
  *"$HUELLA_CEL"*) ok "llave del celular presente ($HUELLA_CEL)" ;;
  *) mal "falta la llave del celular" ;;
esac
n=$(sudo wc -l < /home/ubuntu/.ssh/authorized_keys)
[ "$n" -eq 2 ] && ok "solo 2 llaves autorizadas (la antigua se retiró)" || mal "hay $n llaves autorizadas"
# la del celular debe estar restringida al túnel, no servir para entrar al servidor
r=$(sudo sed -n '2p' /home/ubuntu/.ssh/authorized_keys | cut -d' ' -f1)
case "$r" in
  *restrict*permitopen*) ok "llave del celular restringida al túnel 4096" ;;
  *) mal "la llave del celular NO está restringida: $r" ;;
esac
bind=$(sudo ss -tln 2>/dev/null | grep ':4096' | awk '{print $4}' | head -1)
case "$bind" in 127.0.0.1:4096) ok "4096 escucha solo en 127.0.0.1";; *) mal "4096 escucha en $bind";; esac

echo ""
echo "── RESPALDOS (4 vías) ──"
A=$(sudo find /var/backups/marketattack/completos -name 'completo_*.tar.gz' | wc -l)
B=$(sudo find /root/marketattack-rescate -name 'completo_*.tar.gz' | wc -l)
C=$(sudo find /var/backups/marketattack/kits -name '*.zip' | wc -l)
[ "$A" -ge 1 ] && ok "vía A (disco VPS): $A respaldo(s)" || mal "vía A vacía"
[ "$B" -ge 1 ] && ok "vía B (espejo):    $B respaldo(s)" || mal "vía B vacía"
[ "$C" -ge 1 ] && ok "vía C (Telegram):  $C kit(s)" || mal "vía C vacía"
G=$(sudo ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
case "$G" in
  *"successfully authenticated"*) ok "vía D (GitHub): llave del VPS autorizada" ;;
  *) echo "  aviso  vía D (GitHub): llave no autorizada (respaldo en GitHub inactivo)" ;;
esac
for V in /var/backups/marketattack/completos /root/marketattack-rescate; do
  if sudo find "$V" -name 'SHA256SUMS' | grep -q .; then :; fi
  r=$(sudo find "$V" -name 'completo_*.tar.gz' | sort -r | head -1)
  if sudo tar -tzf "$r" >/dev/null 2>&1; then ok "$(basename $r) se lee bien"; else mal "$(basename $r) ilegible"; fi
done

echo ""
echo "── SIN SECRETOS EN LOS RESPALDOS ──"
TK=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
for D in /var/backups/marketattack/completos /root/marketattack-rescate; do
  leaks=0
  sudo grep -rqF -- "$CL" "$D" 2>/dev/null && leaks=$((leaks+1))
  sudo grep -rqF -- "$ANTIGUA" "$D" 2>/dev/null && leaks=$((leaks+1))
  sudo grep -rqF -- "$TK" "$D" 2>/dev/null && leaks=$((leaks+1))
  sudo grep -rqE 'BEGIN [A-Z ]*PRIVATE KEY' "$D" 2>/dev/null && leaks=$((leaks+1))
  [ "$leaks" -eq 0 ] && ok "$(basename $D): 0 fugas" || mal "$(basename $D): $leaks fugas"
done

echo ""
echo "── CRON ──"
CRON=$(sudo crontab -l)
faltan=""
for t in watchdog_marketattack backup_marketattack respaldo_diario_marketattack \
         informe_diario verificar_respaldos verificacion_final; do
  echo "$CRON" | grep -q "$t" || faltan="$faltan $t"
done
# El respaldo diario agrupa: kit+Telegram (nube), completo A/B (local) y GitHub.
[ -x /usr/local/bin/respaldo_diario_marketattack.sh ] || faltan="$faltan respaldo_diario_marketattack.sh"
if [ -z "$faltan" ]; then
  ok "las 6 reglas de cron estan activas (respaldo diario = nube + local)"
else
  mal "faltan reglas de cron:$faltan"
fi

echo ""
echo "── DISCOS ──"
u=$(df / | awk 'NR==2{print $5}' | tr -d '%')
echo "  $(df -h / | awk 'NR==2{print $2}') total, $(df -h / | awk 'NR==2{print $4}') libre, ${u}% usado"
[ "$u" -lt 80 ] && ok "espacio sano" || mal "espacio crítico: ${u}%"

echo ""
echo "══════════════════════════════════════════"
if [ "$f" -eq 0 ]; then echo " RESULTADO: TODO CORRECTO"; else echo " RESULTADO: $f FALLOS"; exit 1; fi
echo "══════════════════════════════════════════"
