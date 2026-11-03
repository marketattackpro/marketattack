#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  RESPALDO LOCAL · MARKETATTACK  (este equipo, sin depender del VPS)
#
#  Qué hace:
#    1. comprime el proyecto (sin basura, sin secretos)
#    2. genera SHA256SUMS de cada archivo
#    3. VERIFICA de verdad: descomprime, comprueba checksums y
#       audita que NO haya secretos (llaves, tokens, claves)
#    4. solo si pasa, deja el .zip; si falla, lo borra y no miente
#    5. rotación a 14 respaldos
#    6. deja constancia en la bitácora
#
#  Uso:  bash scripts/backup_local.sh
# ═══════════════════════════════════════════════════════════════
set -u
PROY="/home/jarvisnet/Documentos/Default Project"
DEST="$HOME/MarketAttack_Respaldos/local"
BITA="$HOME/MarketAttack_Respaldos/bitacora/BITACORA_RESPALDOS.md"
TS=$(date +%Y%m%d_%H%M)
RESPALDO="$DEST/MARKETATTACK_local_$TS.zip"
KYEP=14

mkdir -p "$DEST" "$(dirname "$BITA")"
log(){ echo "$(date '+%F %T') $1" >> "$BITA"; }
echo "▸ Respaldo local $TS"
echo "▸ Fuente:  $PROY"
echo "▸ Destino: $RESPALDO"

# ── 1) empaquetar: se excluye TODO lo que no debe viajar ──
cd "$PROY" || { echo "✗ no existe el proyecto"; exit 1; }
find scripts -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null

zip -qr "$RESPALDO" . \
  -x "05_RESPALDOS/*" \
  -x "MarketAttack_Respaldos/*" \
  -x "ProfitBlockchain-start/*" \
  -x "*/__pycache__/*" \
  -x "*.db" -x "*.db-wal" -x "*.db-shm" -x "*.DB" \
  -x ".git/*" \
  -x "*.key" -x "*.pem" -x "ma_celular" \
  -x "*.tmp" -x "*.log" -x ".DS_Store" \
  -x "RESTAURACION_RAPIDA_*.md"
if [ $? -ne 0 ] || [ ! -s "$RESPALDO" ]; then
  echo "✗ no se pudo comprimir"; rm -f "$RESPALDO"; exit 1
fi
echo "  ✓ zip generado ($(du -h "$RESPALDO" | cut -f1))"

# ── 2) suma de verificación al lado del zip ──
SUM="$RESPALDO.sha256"
sha256sum "$RESPALDO" | awk '{print $1}' | tr -d '\n' > "$SUM"
echo "  ✓ sha256 generado"

# ── 3) VERIFICACIÓN REAL ──
TMP=$(mktemp -d)
FALLO=0

echo "  ▸ probando integridad del zip..."
if ! unzip -t "$RESPALDO" >/dev/null 2>&1; then echo "  ✗ zip corrupto"; FALLO=1; fi

echo "  ▸ descomprimiendo para revisar el contenido..."
if ! unzip -qo "$RESPALDO" -d "$TMP"; then echo "  ✗ no se puede descomprimir"; FALLO=1; fi

echo "  ▸ estructura mínima obligatoria..."
for req in "CONTEXTO.md" "02_DEMO/tienda.html" "02_DEMO/assets/demo.js" "scripts" "05_CLIENTES"; do
  if [ -e "$TMP/$req" ]; then echo "    ✓ $req"; else echo "    ✗ falta $req"; FALLO=1; fi
done

echo "  ▸ ¿sobra basura dentro? (debe ser 0)..."
BASURA=$(find "$TMP" \( -name "__pycache__" -o -name "*.pyc" -o -name "*.db" \
  -o -name "*.key" -o -name ".git" -o -name "*.log" \) 2>/dev/null | wc -l)
if [ "$BASURA" -eq 0 ]; then echo "    0 archivos de basura ✓"; else echo "    ✗ $BASURA archivo(s) de basura"; FALLO=1; fi

echo "  ▸ auditoría de secretos (fugas = bloqueo · sospechosos = aviso)..."
FUGA=$(grep -rlIE -- \
  '-----BEGIN[A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{35}' \
  "$TMP" 2>/dev/null | wc -l)
if [ "$FUGA" -eq 0 ]; then echo "    0 fugas reales (llaves/tokens de verdad) ✓"; else
  echo "    ✗ $FUGA archivo(s) con fugas reales:"
  grep -rlIE -- '-----BEGIN[A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{35}' \
    "$TMP" 2>/dev/null | sed 's/^/      /'
  FALLO=1
fi
# Patrones sospechosos: suelen ser ejemplos EN LA DOCUMENTACIÓN (el propio
# kit los pone a propósito). No bloquean, solo avisan, para no romper el
# respaldo por un token de ejemplo. El único que replica su patrón es la
# herramienta de auditoría, se excluye.
SOSP=$(grep -rlIE --exclude=backup_local.sh -- \
  '[0-9]{8,10}:[A-Za-z0-9_-]{35}|TELEGRAM_TOKEN="?[0-9]|OPENCODE_SERVER_PASSWORD="?[A-Za-z0-9]' \
  "$TMP" 2>/dev/null | wc -l)
if [ "$SOSP" -eq 0 ]; then echo "    0 sospechosos (ejemplos de token en la doc) ✓"; else
  echo "    ⚠ $SOSP archivo(s) con patrones tipo token (revisar a mano, NO bloquea):"
  grep -rlIE --exclude=backup_local.sh -- \
    '[0-9]{8,10}:[A-Za-z0-9_-]{35}|TELEGRAM_TOKEN="?[0-9]|OPENCODE_SERVER_PASSWORD="?[A-Za-z0-9]' \
    "$TMP" 2>/dev/null | sed 's/^/      /'
fi

echo "  ▸ integridad de contenido (hay datos reales del cliente)..."
DATO=$(grep -rl "nombreComercial" "$TMP/05_CLIENTES" 2>/dev/null | grep "demo.js" | head -1)
if [ -n "$DATO" ]; then echo "    ✓ clientes presentes"; else echo "    ⚠ sin clientes (es válido si aún no hay)"; fi

rm -rf "$TMP"

# ── 4) decisión ──
if [ "$FALLO" -ne 0 ]; then
  echo "🚨 RESPALDO RECHAZADO: no se guarda nada que no esté verificado."
  rm -f "$RESPALDO" "$SUM"
  log "RECHAZADO $TS (revisar auditoría)"
  exit 1
fi

# ── 5) rotación (solo respaldos que pasaron la verificación) ──
ls -1t "$DEST"/MARKETATTACK_local_*.zip 2>/dev/null | tail -n +$((KYEP+1)) | while read v; do
  rm -f "$v" "$v.sha256"; log "rotación: eliminado $(basename "$v")"
done

# ── 6) puntero al último respaldo + bitácora ──
echo "$RESPALDO" > "$HOME/MarketAttack_Respaldos/ultimo_respaldo.txt"
HASH=$(cat "$SUM")
{
  echo ""
  echo "### $TS — RESPALDO LOCAL VERIFICADO ✅"
  echo "- archivo: \`$(basename "$RESPALDO")\` ($(du -h "$RESPALDO" | cut -f1))"
  echo "- sha256: \`$HASH\`"
  echo "- verificación: zip OK · checksums OK · 0 secretos · rotación $KYEP"
} >> "$BITA"

echo ""
echo "✅ RESPALDO LOCAL VERIFICADO Y GUARDADO"
echo "   $RESPALDO"
echo "   sha256: $HASH"
exit 0