#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  RESPALDO VALIDADO · MARKETATTACK
#  - Valida SIEMPRE (servicios, web, seguridad, disco).
#  - Solo crea un respaldo si hay CAMBIOS desde el último respaldo
#    validado (o con --force, tras una mejora aprobada).
#  - Nube: kit + Telegram.  Local: vías A y B del VPS.
#  - Si la validación falla: NO respalda y avisa.
#  Uso:  respaldo_diario_marketattack.sh [--force]
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

MODO="${1:-auto}"
STATE=/var/backups/marketattack/.ultimo_validado.sha256

huella() {
  {
    find /var/www/marketattack -type f \
      ! -path '*/descargas/*' ! -name 'recuperar.html' -print0 \
      | sort -z | xargs -0 -r sha256sum
    find /usr/local/bin -maxdepth 1 -type f \( -name '*.sh' -o -name '*.py' \) -print0 \
      | sort -z | xargs -0 -r sha256sum
    sha256sum /etc/nginx/sites-available/marketattack
  } | sha256sum | awk '{print $1}'
}

echo "══════ $(date '+%F %T') · RESPALDO MARKETATTACK ($MODO) ══════"

# 1) VALIDAR
echo "→ 1/5 validación"
if ! /usr/local/bin/verificacion_final.sh; then
  echo "✗ validación con fallos: NO se respalda nada."
  /usr/local/bin/aviso_telegram.sh "🚨 <b>Respaldo OMITIDO</b> — la validación falló; no se guardó nada. Revisa el VPS." >/dev/null 2>&1 || true
  exit 1
fi

# 2) ¿HAY CAMBIOS?
ACTUAL=$(huella)
if [ "$MODO" != "--force" ] && [ -f "$STATE" ] && [ "$ACTUAL" = "$(cat "$STATE")" ]; then
  echo "✓ sin cambios validados desde el último respaldo: no se crea copia nueva."
  echo "══════ $(date '+%F %T') · FIN ══════"
  exit 0
fi

OK=1

# 3) NUBE: kit + Telegram
echo "→ 2/5 nube: kit + Telegram"
/usr/local/bin/kit_recuperacion.sh || { echo "⚠ kit con avisos"; OK=0; }

# 4) LOCAL: respaldo completo A/B
echo "→ 3/5 local: respaldo completo (vías A y B)"
/usr/local/bin/respaldo_completo.sh || { echo "⚠ respaldo A/B con avisos"; OK=0; }

# 5) NUBE: GitHub (opcional hasta autorizar la llave)
echo "→ 4/5 nube: GitHub"
/usr/local/bin/publicar_github.sh || echo "⚠ GitHub no disponible (falta autorizar la llave)"

# 6) Estado: solo si el respaldo crítico salió bien
if [ "$OK" -eq 1 ]; then
  echo "$ACTUAL" > "$STATE"
  echo "→ 5/5 aviso"
  /usr/local/bin/aviso_telegram.sh "✅ <b>Respaldo validado MARKETATTACK</b> ($(date '+%F %H:%M'))
• Validación: OK
• Local VPS: vías A y B
• Nube: kit enviado a Telegram
• GitHub: se activa al autorizar la llave" >/dev/null 2>&1 || true
else
  echo "✗ respaldo incompleto: NO se actualiza el estado (se reintentará)."
  /usr/local/bin/aviso_telegram.sh "⚠ <b>Respaldo incompleto</b> — se reintentará en la próxima ejecución." >/dev/null 2>&1 || true
  exit 1
fi

echo "══════ $(date '+%F %T') · FIN ══════"
