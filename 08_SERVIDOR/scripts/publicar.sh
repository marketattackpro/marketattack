#!/usr/bin/env bash
# ═══ Publica los cambios del proyecto en la web del servidor (local) ═══
# Lo usa el watchdog. Origen = espejo en el propio VPS.
set -e
ORIGEN="/home/personalamd/Documentos/Default Project/02_DEMO"
DESTINO="/var/www/marketattack"

echo "▸ Publicando cambios..."
rsync -a --exclude 'descargas' --exclude 'clientes' "$ORIGEN/" "$DESTINO/"
chown -R www-data:www-data "$DESTINO"

C1=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1/tienda.html)
C2=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1/assets/carrito.js)
if [ "$C1" = "200" ] && [ "$C2" = "200" ]; then
  echo "✓ PUBLICADO y verificado (tienda=$C1, carrito=$C2)"
  echo "  https://157-137-203-223.sslip.io/tienda.html"
else
  echo "⚠ ERROR al publicar (tienda=$C1 carrito=$C2)"
  exit 1
fi
