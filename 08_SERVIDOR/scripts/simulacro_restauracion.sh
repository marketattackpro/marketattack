#!/usr/bin/env bash
# ═══ SIMULACRO DE RESTAURACIÓN — MARKETATTACK ═══
# Toma el último respaldo completo, lo restaura en una carpeta temporal,
# comprueba checksums y levanta el sitio restaurado para ver que abre.
# No toca el sitio en vivo.
set -uo pipefail

RESPALDOS=/var/backups/marketattack/completos
PUERTO=8099
DEST=$(mktemp -d /tmp/simulacro_restauracion.XXXXXX)
SRV_PID=""
limpiar(){
  [ -n "$SRV_PID" ] && kill "$SRV_PID" 2>/dev/null
  rm -rf "$DEST" /tmp/sim_body 2>/dev/null
}
trap limpiar EXIT

fallos=0
inicio=$(date +%s)

echo "═══ SIMULACRO DE RESTAURACIÓN — $(date '+%F %H:%M') ═══"

ULTIMO=$(ls -t "$RESPALDOS"/completo_*.tar.gz 2>/dev/null | head -1)
if [ -z "$ULTIMO" ]; then
  echo "✗ no hay respaldos completos"
  exit 1
fi
echo "respaldo: $(basename "$ULTIMO") ($(du -h "$ULTIMO" | cut -f1))"

echo ""
echo "── 1) extraer ──"
if tar -xzf "$ULTIMO" -C "$DEST"; then
  echo "  ok extraído"
else
  echo "  ✗ no se pudo extraer"
  exit 1
fi
t_ext=$(date +%s)

echo ""
echo "── 2) checksums ──"
if (cd "$DEST" && sha256sum -c --quiet SHA256SUMS >/dev/null 2>&1); then
  echo "  ok los archivos coinciden con el respaldo"
else
  echo "  ✗ los checksums NO coinciden"
  fallos=$((fallos+1))
fi

echo ""
echo "── 3) archivos clave ──"
for f in \
  contenido/web/index.html \
  contenido/web/tienda.html \
  contenido/scripts/publicar.sh \
  contenido/scripts/nuevo_cliente.py \
  contenido/scripts/watchdog_marketattack.sh \
  contenido/config/nginx.conf \
  contenido/02_DEMO/index.html \
  contenido/05_CLIENTES \
  contenido/10_LEGAL/condiciones_servicio.html \
  contenido/10_LEGAL/politica_privacidad.html
do
  if [ -e "$DEST/$f" ]; then echo "  ok $f"
  else echo "  ✗ falta $f"; fallos=$((fallos+1)); fi
done

echo ""
echo "── 4) base de datos del chat ──"
DB=$(find "$DEST" -name 'chat_*.db' | head -1)
if [ -n "$DB" ]; then
  N=$(python3 -c "import sqlite3,sys; print(sqlite3.connect(sys.argv[1]).execute('select count(*) from message').fetchone()[0])" "$DB" 2>/dev/null)
  if [ -n "$N" ]; then echo "  ok abre y tiene $N mensajes"
  else echo "  ✗ la base de datos no abre"; fallos=$((fallos+1)); fi
else
  echo "  ✗ no hay base de datos en el respaldo"; fallos=$((fallos+1))
fi

echo ""
echo "── 5) levantar el sitio restaurado (127.0.0.1:$PUERTO) ──"
if ss -ltn 2>/dev/null | grep -q ":$PUERTO "; then
  echo "  ✗ el puerto $PUERTO está ocupado; se omite esta prueba"
  fallos=$((fallos+1))
else
  python3 -m http.server "$PUERTO" --bind 127.0.0.1 --directory "$DEST/contenido/web" >/dev/null 2>&1 &
  SRV_PID=$!
  for _ in $(seq 1 20); do
    curl -sf -o /dev/null --max-time 2 "http://127.0.0.1:$PUERTO/" && break
    sleep 0.5
  done

  probar(){
    local url="$1" marca="$2" c
    c=$(curl -s -o /tmp/sim_body -w "%{http_code}" --max-time 8 "http://127.0.0.1:$PUERTO$url")
    if [ "$c" = "200" ] && grep -qi "$marca" /tmp/sim_body; then
      echo "  ok $url"
    else
      echo "  ✗ $url (HTTP $c)"
      fallos=$((fallos+1))
    fi
  }
  probar "/" "marketattack"
  probar "/tienda.html" "marketattack"

  CLIENTES=0
  if [ -d "$DEST/contenido/web/clientes" ]; then
    for d in "$DEST/contenido/web/clientes"/*/; do
      [ -d "$d" ] || continue
      s=$(basename "$d")
      CLIENTES=$((CLIENTES+1))
      probar "/clientes/$s/tienda.html" "marketattack"
    done
  fi
  echo "  tiendas de clientes restauradas: $CLIENTES"

  # ── 5b) ¿se puede crear un cliente nuevo con lo restaurado? ──
  echo ""
  echo "── 6) crear un cliente de prueba con la plantilla restaurada ──"
  SALIDA=$(MA_WEB="/proc/sin-escritura" python3 "$DEST/contenido/scripts/nuevo_cliente.py" \
    --nombre "Prueba Simulacro" \
    --whatsapp "3000000000" \
    --menu "Producto de prueba|1000|Solo para el ensayo" \
    --url-base "https://marketattack.duckdns.org" 2>&1)
  if echo "$SALIDA" | grep -q "VERIFICADO=LOCAL_OK"; then
    echo "  ok la plantilla genera un cliente nuevo"
    # publicarlo en la copia restaurada y comprobar que abre
    cp -a "$DEST/contenido/05_CLIENTES/prueba-simulacro" "$DEST/contenido/web/clientes/" 2>/dev/null
    probar "/clientes/prueba-simulacro/tienda.html" "marketattack"
  else
    echo "  ✗ no se pudo generar el cliente"
    echo "$SALIDA" | tail -3
    fallos=$((fallos+1))
  fi

  kill "$SRV_PID" 2>/dev/null; wait "$SRV_PID" 2>/dev/null; SRV_PID=""
fi

fin=$(date +%s)
ARCH=$(find "$DEST" -type f | wc -l)

echo ""
echo "── RESULTADO ──"
echo "archivos restaurados: $ARCH"
echo "tiempo de extracción: $((t_ext-inicio))s"
echo "tiempo total del simulacro: $((fin-inicio))s"
if [ "$fallos" -eq 0 ]; then
  echo "RESULTADO: el respaldo restaura y el sitio abre correctamente"
  exit 0
else
  echo "RESULTADO: $fallos problema(s)"
  exit 1
fi
