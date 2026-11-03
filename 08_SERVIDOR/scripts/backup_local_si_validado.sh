#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  RESPALDO LOCAL · solo si hay cambios y el sitio valida
#  Se ejecuta a las 00:00 desde el cron del PC.
#  - Si no hay cambios desde el último respaldo local: no hace nada.
#  - Si hay cambios, primero valida el sitio en vivo; solo si TODO
#    está correcto crea el respaldo local verificado.
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

PROY="/home/jarvisnet/Documentos/Default Project"
STATE="$HOME/MarketAttack_Respaldos/.ultimo_local.sha256"
HOST="marketattack"

cd "$PROY" || { echo "✗ no existe el proyecto"; exit 1; }

huella() {
  find . -type f \
    ! -path './05_RESPALDOS/*' \
    ! -path './MarketAttack_Respaldos/*' \
    ! -path './ProfitBlockchain-start/*' \
    ! -path '*/__pycache__/*' \
    ! -path './.git/*' \
    ! -name '*.db' ! -name '*.db-wal' ! -name '*.db-shm' \
    ! -name '*.key' ! -name '*.pem' ! -name 'ma_celular' \
    ! -name '*.log' ! -name '*.tmp' ! -name '.DS_Store' \
    ! -name 'RESTAURACION_RAPIDA_*.md' \
    -print0 | sort -z | xargs -0 -r sha256sum | sha256sum | awk '{print $1}'
}

echo "══════ $(date '+%F %T') · RESPALDO LOCAL MARKETATTACK ══════"
ACTUAL=$(huella)

if [ -f "$STATE" ] && [ "$ACTUAL" = "$(cat "$STATE")" ]; then
  echo "✓ sin cambios locales desde el último respaldo: no se crea copia."
  exit 0
fi

echo "→ validando el sitio en vivo..."
if ! ssh -o BatchMode=yes -o ConnectTimeout=12 "$HOST" 'sudo /usr/local/bin/verificacion_final.sh' >/dev/null 2>&1; then
  echo "✗ el sitio NO valida: no se respalda localmente."
  exit 1
fi

echo "→ cambios validados: creando respaldo local verificado..."
if bash scripts/backup_local.sh; then
  echo "$ACTUAL" > "$STATE"
  echo "✓ respaldo local actualizado."
else
  echo "✗ el respaldo local falló; no se actualiza el estado."
  exit 1
fi
