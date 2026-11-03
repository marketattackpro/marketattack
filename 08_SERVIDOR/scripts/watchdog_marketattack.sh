#!/usr/bin/env bash
# ═══ VIGILANTE MARKETATTACK ═══
# Revisa servicios, páginas y disco. Repara lo que puede y avisa por
# Telegram cuando algo no se pudo arreglar.
set -u
LOCK=/run/watchdog.lock
exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0   # solo una instancia

LOG=/var/log/marketattack_watchdog.log
ESTADO=/var/lib/marketattack/watchdog_estado
AVISO=/usr/local/bin/aviso_telegram.sh
mkdir -p "$(dirname "$ESTADO")" 2>/dev/null

log(){ echo "$(date '+%F %T') $1" >> "$LOG"; }

fallos=0
detalle=""

# registra un fallo que el vigilante NO pudo reparar
fallo(){
  fallos=$((fallos+1))
  detalle="${detalle}• $1"$'\n'
  log "🚨 $1"
}

# revisa un servicio: si está caído lo reinicia; si no revive, lo reporta
revisar(){
  local s="$1" espera="$2"
  systemctl is-active --quiet "$s" && return 0
  systemctl restart "$s" 2>/dev/null
  sleep "$espera"
  if systemctl is-active --quiet "$s"; then
    log "❌ $s estaba caído → reiniciado"
  else
    fallo "$s no arranca"
  fi
}

# ── 1) servicios ──
revisar nginx 3
revisar opencode 8
revisar puente-telegram 5
revisar marketattack-chat 3

# ── 2) páginas públicas (desde adentro) ──
for u in "/" "/tienda.html" "/kit.html"; do
  c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1$u")
  if [ "$c" != "200" ]; then
    log "❌ $u devolvió $c → re-publicando"
    /usr/local/bin/publicar.sh >/dev/null 2>&1
    sleep 3
    c2=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1$u")
    if [ "$c2" = "200" ]; then log "   ✓ $u recuperada (200)"
    else fallo "la página $u sigue en $c2"; fi
  fi
done

# ── 3) sitio real por HTTPS (como lo ve el cliente) ──
TMP=$(mktemp)
c=$(curl -s -o "$TMP" -w "%{http_code}" --max-time 12 "https://marketattack.duckdns.org/")
if [ "$c" != "200" ] || ! grep -qi "marketattack" "$TMP"; then
  log "❌ sitio público HTTPS devolvió $c → reiniciando nginx"
  systemctl restart nginx 2>/dev/null
  sleep 4
  c=$(curl -s -o "$TMP" -w "%{http_code}" --max-time 12 "https://marketattack.duckdns.org/")
  if [ "$c" != "200" ] || ! grep -qi "marketattack" "$TMP"; then
    fallo "el sitio público no responde (HTTPS $c)"
  else
    log "   ✓ sitio público recuperado"
  fi
fi
rm -f "$TMP"

# ── 4) certificado: avisar si le quedan menos de 14 días ──
CERT=$(find /etc/letsencrypt/live -name fullchain.pem 2>/dev/null | head -1)
if [ -n "$CERT" ]; then
  if ! openssl x509 -checkend $((14*86400)) -noout -in "$CERT" >/dev/null 2>&1; then
    fallo "el certificado HTTPS vence en menos de 14 días"
  fi
else
  fallo "no se encontró el certificado HTTPS"
fi

# ── 5) tiendas de clientes ──
if [ -d /var/www/marketattack/clientes ]; then
  for d in /var/www/marketattack/clientes/*/; do
    [ -d "$d" ] || continue
    s=$(basename "$d")
    c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "http://127.0.0.1/clientes/$s/tienda.html")
    [ "$c" = "200" ] || fallo "la tienda '$s' está caída ($c)"
  done
fi

# ── 6) disco ──
U=$(df -P / | awk 'NR==2{gsub("%","",$5); print $5}')
if [ "${U:-0}" -gt 90 ]; then
  log "⚠ disco al ${U}% → limpiando respaldos antiguos"
  find /var/backups/marketattack -name "*.tar.gz" -mtime +7 -delete 2>/dev/null
  [ "${U:-0}" -gt 95 ] && fallo "disco casi lleno (${U}%)"
fi

# ── 7) avisos al celular ──
AHORA=$(date +%s)
if [ "$fallos" -gt 0 ]; then
  ULTIMO=$(cut -d' ' -f1 "$ESTADO" 2>/dev/null || echo 0)
  [ -z "$ULTIMO" ] && ULTIMO=0
  if [ $((AHORA - ULTIMO)) -ge 1800 ]; then
    "$AVISO" "🚨 <b>MARKETATTACK — problema detectado</b>
$(date '+%F %H:%M')

$detalle
Revisa el servidor. Si se repite, te vuelvo a avisar en 30 minutos." >/dev/null 2>&1
    echo "$AHORA" > "$ESTADO"
  fi
  log "Watchdog: $fallos problema(s) detectado(s)"
else
  if [ -f "$ESTADO" ]; then
    "$AVISO" "✅ <b>MARKETATTACK — todo normal</b>
$(date '+%F %H:%M')

El problema anterior ya quedó resuelto." >/dev/null 2>&1
    rm -f "$ESTADO"
  fi
fi
exit 0
