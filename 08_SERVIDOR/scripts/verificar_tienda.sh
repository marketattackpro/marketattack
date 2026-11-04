#!/usr/bin/env bash
# ═══ Verificador independiente de tiendas ═══
# uso: verificar_tienda.sh <slug>      (o "todas")
# Revisa la tienda por dentro (servidor) y por fuera (internet real).
# El QR se LEE con un decodificador: si no escanea, no aprueba.
set -u
WEB=/var/www/marketattack
URL_BASE="${MA_URL_BASE:-https://marketattack.duckdns.org}"
URL_BASE="${URL_BASE%/}"
total=0

rojo(){ printf '\033[31m%s\033[0m' "$1"; }
verde(){ printf '\033[32m%s\033[0m' "$1"; }

verificar() {
  local s="$1" f=0
  echo "  ── $s ──"

  if [ ! -d "$WEB/clientes/$s" ]; then
    echo "     ❌ la carpeta no existe"; return 1
  fi

  # 1) abre en el servidor
  local c
  c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
      "http://127.0.0.1/clientes/$s/tienda.html")
  if [ "$c" = "200" ]; then echo "     ✅ tienda 200"
  else echo "     ❌ tienda $c"; f=$((f+1)); fi

  # 2) datos del cliente (demo.js)
  local js n
  js=$(curl -s --max-time 10 "http://127.0.0.1/clientes/$s/assets/demo.js")
  n=$(printf '%s' "$js" | grep -c '"nombre":')
  if [ "$n" -gt 0 ]; then echo "     ✅ $n productos cargados"
  else echo "     ❌ 0 productos"; f=$((f+1)); fi

  if printf '%s' "$js" | grep -q "\"$s\""; then
    echo "     ✅ datos del cliente corresponden a $s"
  else echo "     ❌ los datos NO corresponden a $s"; f=$((f+1)); fi

  # 3) WhatsApp utilizable
  local w num
  w=$(printf '%s' "$js" | grep -oE '"whatsapp": *"[0-9]{6,}"' | head -1)
  num=$(printf '%s' "$w" | grep -oE '[0-9]{6,}')
  if printf '%s' "$num" | grep -qE '^[0-9]{10,12}$'; then
    echo "     ✅ WhatsApp $num"
  else echo "     ❌ WhatsApp inválido ('$num')"; f=$((f+1)); fi

  # 4) archivos que la tienda necesita
  local a
  for a in style.css carrito.js demo.js favicon.png portada.png; do
    c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        "http://127.0.0.1/clientes/$s/assets/$a")
    if [ "$c" = "200" ]; then echo "     ✅ assets/$a"
    else echo "     ❌ assets/$a ($c)"; f=$((f+1)); fi
  done

  # 5) menú imprimible
  for a in menu.png menu.pdf; do
    c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        "http://127.0.0.1/clientes/$s/assets/$a")
    if [ "$c" = "200" ]; then echo "     ✅ assets/$a"
    else echo "     ❌ assets/$a ($c)"; f=$((f+1)); fi
  done

  # 6) QR: que exista, sea PNG y SE PUEDA LEER
  local q esperado leido
  esperado="$URL_BASE/clientes/$s/tienda.html"
  q=$(curl -s -o /tmp/_qr_$s.bin -w "%{http_code}" --max-time 10 \
      "http://127.0.0.1/clientes/$s/qr.png")
  if [ "$q" = "200" ] && [ -s "/tmp/_qr_$s.bin" ] \
     && head -c 4 "/tmp/_qr_$s.bin" | od -An -tx1 | grep -q "89 50 4e 47"; then
    if command -v zbarimg >/dev/null 2>&1; then
      leido=$(zbarimg -q --raw "/tmp/_qr_$s.bin" 2>/dev/null | head -1)
      if [ "$leido" = "$esperado" ]; then
        echo "     ✅ QR escanea y apunta al link correcto"
      elif [ -n "$leido" ]; then
        echo "     ❌ el QR apunta a: $leido"; f=$((f+1))
      else
        echo "     ❌ el QR NO se puede leer (logo o imagen dañada)"; f=$((f+1))
      fi
    else
      echo "     ⚠ QR en PNG, pero no hay lector para comprobarlo"
    fi
  else
    echo "     ❌ QR $q (no es un PNG válido)"; f=$((f+1))
  fi
  rm -f "/tmp/_qr_$s.bin"

  # 7) visible desde internet (HTTPS real)
  c=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 15 \
      "$URL_BASE/clientes/$s/tienda.html")
  if [ "$c" = "200" ]; then echo "     ✅ visible en internet ($URL_BASE)"
  else echo "     ❌ internet $c"; f=$((f+1)); fi

  return $f
}

if [ "${1:-todas}" = "todas" ]; then
  L=$(ls -1 "$WEB/clientes" 2>/dev/null)
  [ -z "$L" ] && { echo "No hay tiendas todavía."; exit 0; }
  for s in $L; do
    verificar "$s"; total=$((total + $?))
  done
else
  verificar "$1"; total=$?
fi

echo ""
if [ "$total" -eq 0 ]; then
  echo "🎉 TODO CORRECTO"
else
  echo "🚨 $total PROBLEMA(S)"
fi
exit "$total"
