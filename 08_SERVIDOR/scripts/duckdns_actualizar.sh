#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ACTUALIZA LA IP DEL DOMINIO GRATUITO DUCKDNS
#
#  Si el servidor cambia de IP, este script vuelve a apuntar
#  marketattack.duckdns.org a la IP correcta.
#
#  Configuración (privada, solo root):
#    /etc/marketattack/duckdns.conf
#      DUCKDNS_DOMAIN="marketattack"
#      DUCKDNS_TOKEN="..."
#      DUCKDNS_IP=""      # vacío = DuckDNS toma la IP de origen
# ═══════════════════════════════════════════════════════════
CONF=/etc/marketattack/duckdns.conf
LOG=/var/log/marketattack-duckdns.log

if [ ! -r "$CONF" ]; then
  echo "ERROR: falta $CONF"
  exit 1
fi
# shellcheck disable=SC1090
. "$CONF"

if [ -z "$DUCKDNS_DOMAIN" ] || [ -z "$DUCKDNS_TOKEN" ]; then
  echo "ERROR: $CONF está incompleto"
  exit 1
fi

URL="https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}"
[ -n "$DUCKDNS_IP" ] && URL="${URL}&ip=${DUCKDNS_IP}"

resp=$(curl -fsS --max-time 20 "$URL" 2>/dev/null)
ahora=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$resp" = "OK" ]; then
  # comprobar que el nombre resuelve a la IP de este servidor
  ip_local=$(curl -fsS --max-time 10 https://api.ipify.org 2>/dev/null || true)
  ip_dns=$(getent hosts "${DUCKDNS_DOMAIN}.duckdns.org" | awk '{print $1; exit}')
  if [ -n "$ip_local" ] && [ -n "$ip_dns" ] && [ "$ip_local" != "$ip_dns" ]; then
    echo "$ahora  aviso  DNS=$ip_dns  servidor=$ip_local" >> "$LOG"
    echo "AVISO: DuckDNS respondió OK pero el DNS aún no coincide"
    exit 0
  fi
  echo "$ahora  OK  ${DUCKDNS_DOMAIN}.duckdns.org" >> "$LOG"
  echo "OK ${DUCKDNS_DOMAIN}.duckdns.org"
else
  echo "$ahora  FALLO  respuesta='$resp'" >> "$LOG"
  echo "FALLO: DuckDNS no confirmó la actualización"
  exit 1
fi

# el registro no debe crecer sin control
if [ -f "$LOG" ] && [ "$(wc -l < "$LOG")" -gt 500 ]; then
  tail -n 200 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi
