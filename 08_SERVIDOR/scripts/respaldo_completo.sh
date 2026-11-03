#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  RESPALDO COMPLETO DEL MARKETATTACK
#  Qué guarda:  DB del chat + web + scripts + configuración + contexto
#  Dónde:      2 sitios en el VPS (disco A y espejo B)
#  Cuándo:     todos los días 02:30
#  Cuántos:    14 días en cada sitio
#  Integridad: SHA256SUMS para detectar corrupción
# ═══════════════════════════════════════════════════════════
set -uo pipefail
TS=$(date +%Y%m%d_%H%M)
BASE=/var/backups/marketattack/completos
ESPEJO=/root/marketattack-rescate
DIAS=14
W=/tmp/rsp_$TS
PROY="/home/personalamd/Documentos/Default Project"

log(){ echo "   $1"; }

echo "→ respaldo completo $TS"
rm -rf "$W"; mkdir -p "$W/contenido"

# 1) base de datos del chat (SQLite: copiar bien, en caliente es seguro con .backup)
DB=/home/personalamd/.local/share/opencode/opencode.db
DB2=/home/ubuntu/.local/share/opencode/opencode.db
for d in "$DB" "$DB2"; do
  if sudo test -f "$d"; then
    n=$(echo "$d" | tr '/' '_')
    sudo python3 -c "
import sqlite3,sys
s=sqlite3.connect('file:$d?mode=ro',uri=True)
d=sqlite3.connect('$W/contenido/chat_$n.db')
s.backup(d); d.close(); s.close()
" 2>/dev/null && log "chat: $(basename $n).db (copia consistente)" || log "AVISO: no se pudo copiar $d"
  fi
done
sudo chown -R ubuntu:ubuntu "$W" 2>/dev/null

# 2) web publicada
[ -d /var/www/marketattack ] && cp -r /var/www/marketattack "$W/contenido/web" && log "web: $(du -sh $W/contenido/web | cut -f1)"

# 3) scripts del servidor
mkdir -p "$W/contenido/scripts"
sudo cp /usr/local/bin/*.sh /usr/local/bin/*.py /usr/local/bin/PEGAME_ESTO_EN_EL_CHAT.txt "$W/contenido/scripts/" 2>/dev/null
# helpers que viven en el proyecto y no en /usr/local/bin (portada, menú, etc.)
if [ -d "$PROY/scripts" ]; then
  cp -an "$PROY/scripts/." "$W/contenido/scripts/" 2>/dev/null || true
fi
log "scripts: $(ls -1 $W/contenido/scripts | wc -l) archivos"

# 3b) proyecto: plantilla, clientes y documentos (para poder crear clientes
#     nuevos después de restaurar, no solo levantar el sitio)
if [ -d "$PROY" ]; then
  for d in 02_DEMO 05_CLIENTES 07_COBROS 05_OPERACION 01_DOCUMENTACION; do
    [ -d "$PROY/$d" ] && cp -a "$PROY/$d" "$W/contenido/" 2>/dev/null
  done
  for f in CONTEXTO.md MONITOREO.md; do
    [ -f "$PROY/$f" ] && cp -a "$PROY/$f" "$W/contenido/" 2>/dev/null
  done
  log "proyecto: plantilla $(du -sh "$W/contenido/02_DEMO" 2>/dev/null | cut -f1) + $(ls -1 "$W/contenido/05_CLIENTES" 2>/dev/null | wc -l) carpeta(s) de clientes"
fi

# 4) configuración saneada (nunca con secretos)
mkdir -p "$W/contenido/config"
sudo cp /etc/marketattack/telegram.conf "$W/contenido/config/telegram.conf.EJEMPLO" 2>/dev/null
sudo cp /etc/systemd/system/opencode.service "$W/contenido/config/opencode.service" 2>/dev/null
sudo cp /etc/systemd/system/puente-telegram.service "$W/contenido/config/puente-telegram.service" 2>/dev/null
sudo cp /etc/nginx/sites-available/marketattack "$W/contenido/config/nginx.conf" 2>/dev/null
sudo crontab -l > "$W/contenido/config/cron.txt" 2>/dev/null
sudo chmod 644 "$W/contenido/config"/* 2>/dev/null
sudo sed -i -E 's/(TOKEN=|PASSWORD=)[^ ]*/\1[OCULTO]/g' "$W/contenido/config/telegram.conf.EJEMPLO" "$W/contenido/config/opencode.service" 2>/dev/null
log "config: $(ls -1 $W/contenido/config | wc -l) archivos (saneados)"

# 5) manifiesto del estado del sistema
{
  echo "RESPALDO=$TS"
  echo "SERVIDOR=157.137.203.223"
  echo "proyecto=/var/www/marketattack"
  echo "servicios:"; for s in nginx opencode puente-telegram; do
    echo "  $s = $(systemctl is-active $s 2>/dev/null)"; done
  echo "tamanos:"; df -h / | tail -1
} > "$W/ESTADO.txt"

# 6) INTEGRIDAD: checksums de todo lo guardado
( cd "$W" && find . -type f ! -name 'SHA256SUMS' -exec sha256sum {} \; > SHA256SUMS )
log "integridad: $(wc -l < $W/SHA256SUMS) archivos con SHA256"

# 7) comprimir y publicar en las DOS vías del VPS
sudo mkdir -p "$BASE"
sudo tar -czf "$BASE/completo_$TS.tar.gz" -C "$W" . 2>/dev/null
sudo chmod 600 "$BASE/completo_$TS.tar.gz"
sudo mkdir -p "$ESPEJO"
sudo cp "$BASE/completo_$TS.tar.gz" "$ESPEJO/" && sudo chmod 600 "$ESPEJO/completo_$TS.tar.gz"

# 8) rotación en ambas vías
for D in "$BASE" "$ESPEJO"; do
  sudo find "$D" -name 'completo_*.tar.gz' -mtime +$DIAS -delete 2>/dev/null
done

# 9) verificación REAL: se extrae el tar aparte y se pasa sha256sum -c sobre el
#    SHA256SUMS de DENTRO. Antes se validaba el propio .tar.gz como si fuera una
#    lista de sumas: siempre fallaba y caía al mensaje de "compresión verificada"
#    sin haber comprobado nada. El respaldo se daba por bueno sin probarlo.
CHK=$(mktemp -d)
NSHA=$(wc -l < "$W/SHA256SUMS" 2>/dev/null || echo 0)
# se extrae el tar COMPLETO: sha256sum -c necesita los archivos, no solo el
# listado. Extrayendo solo SHA256SUMS daba error falso en todos los archivos.
if sudo tar -xzf "$BASE/completo_$TS.tar.gz" -C "$CHK" 2>/dev/null; then
  if sudo bash -c "cd '$CHK' && sha256sum -c --quiet ./SHA256SUMS" >/dev/null 2>&1; then
    log "integridad: $NSHA archivos verificados dentro del tar"
  else
    log "ERROR: hay archivos que NO coinciden con su SHA256 dentro del respaldo"
    MAL=1
  fi
else
  log "ERROR: el tar no se pudo extraer, no se puede validar la integridad"
  MAL=1
fi
sudo tar -tzf "$BASE/completo_$TS.tar.gz" >/dev/null 2>&1 \
  && log "compresión: verificada" \
  || { log "ERROR: el archivo no se puede leer"; MAL=1; }
sudo rm -rf "$CHK"

echo "   vía A: $BASE  ($(sudo ls -1 $BASE | wc -l) copias)"
echo "   vía B: $ESPEJO  ($(sudo ls -1 $ESPEJO | wc -l) copias)"
rm -rf "$W"
echo "✓ respaldo completo: completo_$TS.tar.gz ($(sudo du -h $BASE/completo_$TS.tar.gz | cut -f1))"
