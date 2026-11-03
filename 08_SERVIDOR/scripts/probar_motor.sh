#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  PRUEBAS AUTOMÁTICAS DEL MOTOR · MARKETATTACK
#  Ejecuta las pruebas del motor (02_DEMO) y de cada tienda de
#  cliente, para detectar cualquier ruptura antes de publicar.
#
#  Uso:  bash scripts/probar_motor.sh
#  Sale con código 1 si alguna prueba falla.
# ═══════════════════════════════════════════════════════════════
set -u
PROY="/home/jarvisnet/Documentos/Default Project"
TEST="$PROY/scripts/pruebas/motor.test.js"
VERDE=$'\033[32m'; ROJO=$'\033[31m'; NC=$'\033[0m'
EXIT=0

if ! command -v node >/dev/null 2>&1; then
  echo "${ROJO}✗ Node.js no está instalado; no se pueden correr las pruebas.${NC}"
  exit 1
fi

echo "════════════════════════════════════════════════════════"
echo " PRUEBAS DEL MOTOR"
echo "════════════════════════════════════════════════════════"
echo ""
if node "$TEST" "$PROY/02_DEMO/assets/demo.js"; then
  echo "${VERDE}✓ motor OK${NC}"
else
  echo "${ROJO}✗ motor con fallos${NC}"; EXIT=1
fi

for d in "$PROY"/05_CLIENTES/*/; do
  [ -f "${d}assets/demo.js" ] || continue
  nombre=$(basename "${d%/}")
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo " PRUEBAS DE CLIENTE: $nombre"
  echo "════════════════════════════════════════════════════════"
  echo ""
  if node "$TEST" "${d}assets/demo.js"; then
    echo "${VERDE}✓ $nombre OK${NC}"
  else
    echo "${ROJO}✗ $nombre con fallos${NC}"; EXIT=1
  fi
done

echo ""
echo "════════════════════════════════════════════════════════"
if [ "$EXIT" -eq 0 ]; then echo "${VERDE}✅ TODAS LAS PRUEBAS PASARON${NC}"; else echo "${ROJO}🚨 HAY PRUEBAS FALLIDAS${NC}"; fi
exit $EXIT
