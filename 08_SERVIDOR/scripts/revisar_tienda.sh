#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  REVISOR DE CALIDAD · MARKETATTACK
#  Revisa una (o todas) las tiendas de clientes ANTES de publicarlas.
#  Detecta errores típicos: restos de la demo, WhatsApp mal, precios
#  sin formato, el bug del carrito, archivos faltantes, QR, etc.
#
#  Uso:
#    bash scripts/revisar_tienda.sh              # revisa TODAS
#    bash scripts/revisar_tienda.sh arepas-dona-rosa
#    bash scripts/revisar_tienda.sh 02_DEMO      # revisa el motor
#  Salida: código 0 si TODO pasa, 1 si algo falla.
# ═══════════════════════════════════════════════════════════════
set -u
PROY="/home/jarvisnet/Documentos/Default Project"
CLIENTES="$PROY/05_CLIENTES"

VERDE=$'\033[32m'; ROJO=$'\033[31m'; AMAR=$'\033[33m'; NC=$'\033[0m'
TOTAL_FALLOS=0; TOTAL_AVISOS=0; N_TIENDAS=0

fallo(){ echo "    ${ROJO}✗ $1${NC}"; FALLOS=$((FALLOS+1)); }
aviso(){ echo "    ${AMAR}⚠ $1${NC}"; AVISOS=$((AVISOS+1)); }
ok(){    echo "    ${VERDE}✓ $1${NC}"; }

revisar_tienda(){
  local dir="$1" etq="$2" modo="${3:-cliente}"
  FALLOS=0; AVISOS=0
  echo ""
  echo "═══ $etq  ($dir)"
  [ -d "$dir" ] || { fallo "no existe la carpeta"; return; }

  # 1) archivos obligatorios
  for f in tienda.html assets/demo.js assets/carrito.js assets/style.css assets/tienda_autocontenida.html; do
    if [ -e "$dir/$f" ]; then :; else fallo "falta $f"; fi
  done

  # 2) datos del cliente dentro de demo.js
  local demo="$dir/assets/demo.js"
  if [ -f "$demo" ]; then
    grep -q "const CLIENTE" "$demo" || fallo "demo.js no tiene 'const CLIENTE'"
    grep -q "nombreComercial" "$demo" || fallo "demo.js sin nombreComercial"
    local wa
    wa=$(grep -oE "[\"']?whatsapp[\"']?[[:space:]]*:[[:space:]]*[\"']?[0-9]+" "$demo" | grep -oE '[0-9]+' | head -1)
    if [ -z "$wa" ]; then fallo "WhatsApp vacío o con formato raro en demo.js"
    elif [ "${#wa}" -lt 10 ] || [ "${#wa}" -gt 12 ]; then fallo "WhatsApp '$wa' con longitud rara (${#wa} dígitos)"
    else ok "WhatsApp del cliente: $wa"; fi
  fi

  # 3) restos de la demo (NO debe quedar 'Market Burger')
  if [ "$modo" = "cliente" ]; then
    local restos
    restos=$(grep -rilE "market burger" "$dir" --include="*.html" --include="*.js" 2>/dev/null | wc -l)
    if [ "$restos" -gt 0 ]; then
      fallo "quedan $restos archivo(s) con texto 'Market Burger' (resto de la demo)"
      grep -rilE "market burger" "$dir" --include="*.html" --include="*.js" 2>/dev/null | sed 's/^/        /'
    else ok "sin restos de la demo"; fi

    # 4) número de WhatsApp de la demo vieja (no debe aparecer)
    if grep -rqE "573233316186|3233316186" "$dir" --include="*.html" --include="*.js" 2>/dev/null; then
      fallo "aparece el WhatsApp de la demo (3233316186) — debe ser el del cliente"
    else ok "sin WhatsApp de la demo"; fi
  else
    ok "modo motor: se omiten los restos de la demo (son esperados aquí)"
  fi

  # 5) bug del carrito (mediSel en vez de medioSel)
  if grep -q "mediSel" "$dir/assets/carrito.js" 2>/dev/null; then
    fallo "BUG del carrito: variable 'mediSel' (debe ser 'medioSel')"
  else ok "carrito sin el bug mediSel"; fi

  # 6) precios sin separador de miles (ej: $5000 en vez de $5.000)
  local malos
  malos=$(grep -oE '\$[0-9]{4,}' "$demo" 2>/dev/null | sort -u | tr '\n' ' ')
  if [ -n "$malos" ]; then fallo "precios sin formato de miles: $malos"
  else ok "precios con formato correcto"; fi

  # 7) botón flotante de WhatsApp sin número fijo
  if grep -q 'id="wa-flotante"' "$dir/tienda.html" 2>/dev/null; then ok "botón flotante dinámico presente"
  else aviso "no se encontró el botón flotante (#wa-flotante)"; fi

  # 8) QR
  if [ -s "$dir/qr.png" ]; then ok "QR presente"
  else aviso "no hay qr.png"; fi

  # 9) autocontenido coherente con el cliente
  if [ -f "$dir/assets/tienda_autocontenida.html" ]; then
    if [ "$modo" = "cliente" ] && grep -qiE "market burger" "$dir/assets/tienda_autocontenida.html"; then
      fallo "el archivo autocontenido tiene restos de la demo"
    else ok "autocontenido coherente"; fi
  fi

  # 10) archivos de valor añadido (vista previa, app, menú imprimible)
  local faltan=""
  for f in assets/portada.png assets/favicon.png assets/icono.png; do
    [ -s "$dir/$f" ] || faltan="$faltan $f"
  done
  if [ -z "$faltan" ]; then ok "portada e íconos presentes"; else fallo "faltan (vista previa):$faltan"; fi
  [ -s "$dir/assets/menu.png" ] && ok "menú imprimible presente" || aviso "no hay menú imprimible (assets/menu.png)"
  [ -s "$dir/manifest.webmanifest" ] && ok "manifest (Agregar a inicio) presente" || aviso "no hay manifest.webmanifest"

  # 11) etiquetas de vista previa (Open Graph)
  if grep -q 'property="og:title"' "$dir/tienda.html" 2>/dev/null; then
    ok "vista previa al compartir (og:title) presente"
  else aviso "sin og:title (la vista previa al compartir no se verá)"; fi

  # 12) links compartibles SIEMPRE con HTTPS (nunca file:// ni http://IP)
  local malos_links
  malos_links=$(grep -rhoE "(file://|http://[0-9]{1,3}(\.[0-9]{1,3}){3})[^\"' ]*" "$dir" --include="*.html" 2>/dev/null | sort -u | head -5)
  if [ -n "$malos_links" ]; then
    fallo "links/vista previa sin HTTPS (usa el dominio):"
    echo "$malos_links" | sed 's/^/        /'
  else ok "links y vista previa con HTTPS/relativos"; fi

  echo "    → $([ "$FALLOS" -eq 0 ] && echo "${VERDE}APROBADA${NC}" || echo "${ROJO}CON $FALLOS FALLO(S)${NC}") · avisos: $AVISOS"
  TOTAL_FALLOS=$((TOTAL_FALLOS+FALLOS)); TOTAL_AVISOS=$((TOTAL_AVISOS+AVISOS)); N_TIENDAS=$((N_TIENDAS+1))
}

# ── a quién revisamos ──
if [ "${1:-}" = "02_DEMO" ] || [ "${1:-}" = "motor" ]; then
  revisar_tienda "$PROY/02_DEMO" "MOTOR (02_DEMO)" motor
elif [ -n "${1:-}" ]; then
  revisar_tienda "$CLIENTES/$1" "CLIENTE: $1" cliente
else
  encontrados=0
  for d in "$CLIENTES"/*/; do
    [ -f "${d}tienda.html" ] || continue
    revisar_tienda "${d%/}" "CLIENTE: $(basename "${d%/}")" cliente
    encontrados=$((encontrados+1))
  done
  if [ "$encontrados" -eq 0 ]; then echo "No hay tiendas de clientes todavía en 05_CLIENTES/"; fi
  # también el motor como referencia
  revisar_tienda "$PROY/02_DEMO" "MOTOR (02_DEMO)" motor
fi

echo ""
echo "════════════════════════════════════════════════════════"
if [ "$TOTAL_FALLOS" -eq 0 ]; then
  echo "${VERDE}✅ TODO EN ORDEN${NC} — tiendas revisadas: $N_TIENDAS · avisos: $TOTAL_AVISOS"
  exit 0
else
  echo "${ROJO}🚨 HAY $TOTAL_FALLOS FALLO(S)${NC} — corrígelos antes de publicar. Avisos: $TOTAL_AVISOS"
  exit 1
fi
