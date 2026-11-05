#!/usr/bin/env bash
# ═══ PRUEBA DE ACEPTACIÓN — MARKETATTACK ═══
# Hace de verdad todo lo que se hace con un cliente nuevo:
#   1. genera la tienda con el generador real
#   2. revisa tienda, productos, WhatsApp, QR, menú, portada y PWA
#   3. prueba el chat con IA (local y por internet)
#   4. revisa el recibo de cobro
#   5. borra la tienda de prueba y confirma que el sitio sigue bien
#
# Uso:  sudo /usr/local/bin/prueba_aceptacion.sh
#       MA_KEEP=1 sudo ...   (deja la tienda de prueba si algo falla)
set -uo pipefail

WEB=/var/www/marketattack
PROY="/home/personalamd/Documentos/Default Project"
URL_BASE="${MA_URL_BASE:-https://marketattack.duckdns.org}"
URL_BASE="${URL_BASE%/}"
SLUG=prueba-aceptacion
NOMBRE="Prueba Aceptacion"
WA=573001112233
fallos=0
inicio=$(date +%s)

ok(){   echo "     ✅ $1"; }
mal(){  echo "     ❌ $1"; fallos=$((fallos+1)); }
paso(){ echo ""; echo "── $1 ──"; }

limpiar(){
  if [ "${MA_KEEP:-0}" = "1" ] && [ "$fallos" -gt 0 ]; then
    echo "   (se conserva $SLUG para revisar: MA_KEEP=1)"
    return
  fi
  rm -rf "$WEB/clientes/$SLUG" "$PROY/05_CLIENTES/$SLUG" 2>/dev/null
}
trap limpiar EXIT

echo "═══ PRUEBA DE ACEPTACIÓN — $(date '+%F %H:%M') ═══"

# ── 0) punto de partida ──
paso "0) el sitio está sano antes de empezar"
c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://127.0.0.1/)
[ "$c" = "200" ] && ok "sitio principal 200" || mal "sitio principal $c"
c=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 15 "$URL_BASE/")
[ "$c" = "200" ] && ok "sitio público 200" || mal "sitio público $c"
H=$(curl -s --max-time 8 http://127.0.0.1:8787/api/chat/health)
echo "$H" | grep -q '"ok": *true' && ok "chat con IA activo" || mal "chat no responde: $H"

# limpiar restos de una prueba anterior
rm -rf "$WEB/clientes/$SLUG" "$PROY/05_CLIENTES/$SLUG" 2>/dev/null

# ── 1) generar cliente ──
paso "1) generar una tienda nueva con el generador real"
t0=$(date +%s)
SALIDA=$(python3 /usr/local/bin/nuevo_cliente.py \
  --nombre "$NOMBRE" \
  --whatsapp "$WA" \
  --tagline "Prueba real de punta a punta" \
  --horario "Lunes a sábado de 8:00 a.m. a 6:00 p.m." \
  --ubicacion "Bogotá" \
  --contacto "Pedidos: 300 111 2233" \
  --menu "Producto Uno|12000|Producto de prueba con descripción" \
  --menu "Producto Dos|8500|Segundo producto de prueba" \
  --menu "Producto Tres|3000|Tercer producto" \
  --promo "Promoción de prueba: 10% en el primer pedido" \
  --url-base "$URL_BASE" 2>&1)
t1=$(date +%s)
echo "$SALIDA" | sed 's/^/     /'

V=$(echo "$SALIDA" | grep -oE '^VERIFICADO=.*' | cut -d= -f2-)
case "$V" in
  200|LOCAL_OK) ok "el generador terminó verificado ($V)" ;;
  *) mal "el generador falló ($V)" ;;
esac
[ -d "$WEB/clientes/$SLUG" ] && ok "tienda publicada en el servidor" \
  || mal "no se creó la carpeta de la tienda"
[ -d "$PROY/05_CLIENTES/$SLUG" ] && ok "ficha del cliente guardada" \
  || mal "no se guardó la ficha del cliente"
echo "     (generación: $((t1-t0))s)"

# ── 2) verificador de tiendas ──
paso "2) verificador independiente de la tienda"
SAL=$(/usr/local/bin/verificar_tienda.sh "$SLUG" 2>&1); rc=$?
echo "$SAL" | sed 's/^/     /'
[ "$rc" -eq 0 ] && ok "verificador: TODO CORRECTO" \
  || mal "verificador: $rc problema(s)"

# ── 3) contenido exacto ──
paso "3) contenido de la tienda"
JS=$(curl -s --max-time 10 "http://127.0.0.1/clientes/$SLUG/assets/demo.js")
grep -Fq '"nombreComercial": "'"$NOMBRE"'"' <<<"$JS" && ok "nombre del negocio" || mal "nombre del negocio"
grep -Fq '"whatsapp": "'"$WA"'"' <<<"$JS" && ok "WhatsApp correcto" || mal "WhatsApp incorrecto"
grep -Fq 'Producto Uno' <<<"$JS" && ok "producto 1 con nombre" || mal "falta producto 1"
grep -Fq 'Producto Tres' <<<"$JS" && ok "producto 3 con nombre" || mal "falta producto 3"
grep -Fq '12.000' <<<"$JS" && ok "precio formateado (\$12.000)" || mal "precio mal formateado"
grep -Fq 'Promoción de prueba' <<<"$JS" && ok "promoción incluida" || mal "falta la promoción"
grep -Fq "$NOMBRE" <<<"$JS" && ok "el nombre aparece en los datos" || mal "el nombre no aparece"

HTML=$(curl -s --max-time 10 "http://127.0.0.1/clientes/$SLUG/tienda.html")
grep -Fq 'assets/demo.js' <<<"$HTML" && ok "la página carga demo.js" || mal "falta demo.js"
grep -Fq 'assets/carrito.js' <<<"$HTML" && ok "la página carga el carrito" || mal "falta el carrito"
if M=$(grep -oiE 'empresa ficticia|tienda demo ia|para probar la demo|dashboard del negocio' <<<"$HTML"); then
  mal "la página conserva textos de DEMO: $(echo $M | tr '\n' ' ')"
else
  ok "la página no tiene textos de demo"
fi
AUTO="$WEB/clientes/$SLUG/assets/tienda_autocontenida.html"
if M=$(grep -oiE 'empresa ficticia|tienda demo ia|para probar la demo|dashboard del negocio' "$AUTO" 2>/dev/null); then
  mal "la versión autocontenida conserva textos de DEMO: $(echo $M | tr '\n' ' ')"
else
  ok "la versión autocontenida está limpia"
fi

# el pedido de WhatsApp debe armarse ANTES de vaciar el carrito
CART="$WEB/clientes/$SLUG/assets/carrito.js"
if grep -Fq 'urlPedido' "$CART" 2>/dev/null; then
  ok "el carrito arma el pedido con urlPedido()"
  l_url=$(grep -n 'var url = urlPedido()' "$CART" | head -1 | cut -d: -f1)
  l_vac=$(grep -n 'CARRITO = \[\]' "$CART" | tail -1 | cut -d: -f1)
  if [ -n "$l_url" ] && [ -n "$l_vac" ] && [ "$l_url" -lt "$l_vac" ]; then
    ok "el pedido se arma antes de vaciar el carrito"
  else
    mal "el carrito se vacía antes de armar el pedido (llegaría vacío)"
  fi
  grep -Fq 'nombreComercial' "$CART" && ok "el pedido lleva el nombre del negocio" \
    || mal "el pedido no lleva el nombre del negocio"
else
  mal "el carrito no usa urlPedido() (riesgo de pedido vacío)"
fi

# archivos de imagen y menú
for a in portada.png favicon.png icono.png menu.png; do
  head -c 4 "$WEB/clientes/$SLUG/assets/$a" 2>/dev/null | od -An -tx1 | grep -q "89 50 4e 47" \
    && ok "assets/$a es PNG válido" || mal "assets/$a inválido"
done
head -c 4 "$WEB/clientes/$SLUG/assets/menu.pdf" 2>/dev/null | grep -q '%PDF' \
  && ok "menú PDF válido ($(stat -c%s "$WEB/clientes/$SLUG/assets/menu.pdf" 2>/dev/null) bytes)" \
  || mal "menú PDF inválido"
[ -s "$WEB/clientes/$SLUG/assets/tienda_autocontenida.html" ] \
  && ok "versión autocontenida (para compartir)" || mal "falta tienda_autocontenida.html"

# manifiesto PWA
M=$(curl -s --max-time 10 "http://127.0.0.1/clientes/$SLUG/manifest.webmanifest")
python3 -c "import json,sys; d=json.loads(sys.argv[1]); assert d.get('name') and d.get('icons')" "$M" 2>/dev/null \
  && ok "manifiesto PWA válido" || mal "manifiesto PWA inválido"

# ── 4) QR se lee de verdad ──
paso "4) el QR escanea y apunta al link"
esperado="$URL_BASE/clientes/$SLUG/tienda.html"
leido=$(zbarimg -q --raw "$WEB/clientes/$SLUG/qr.png" 2>/dev/null | head -1)
if [ "$leido" = "$esperado" ]; then ok "QR = $leido"
else mal "el QR dice '$leido' (esperado '$esperado')"; fi

# ── 5) chat con IA (local y público, con el catálogo real) ──
paso "5) chat con IA"
PREG='{"mensaje":"¿Qué productos venden y a qué precio? Responde corto.","negocio":{"nombre":"Prueba Aceptacion","horario":"Lunes a sábado de 8:00 a.m. a 6:00 p.m.","menu":[{"n":"Producto Uno","p":"$12.000","d":"Producto de prueba"},{"n":"Producto Dos","p":"$8.500","d":"Segundo producto"}],"promos":["PROMO: 10% en el primer pedido"],"faqs":[]}}'
R=$(curl -s --max-time 45 -X POST http://127.0.0.1:8787/api/chat \
      -H "Content-Type: application/json" -d "$PREG")
echo "$R" | python3 -c "
import json,sys
d=json.load(sys.stdin)
r=(d.get('respuesta') or '').strip()
assert d.get('ok') is True and len(r)>10, d
assert ('producto' in r.lower()) or ('12.000' in r), 'no usó el catálogo: '+r
print('     respuesta:', r[:140].replace('\n',' '))
" 2>/dev/null && ok "chat local usa el catálogo real" || mal "chat local no usó el catálogo: $R"

R=$(curl -s --max-time 45 -X POST "$URL_BASE/api/chat" \
      -H "Content-Type: application/json" -d "$PREG")
echo "$R" | python3 -c "
import json,sys
d=json.load(sys.stdin)
r=(d.get('respuesta') or '').strip()
assert d.get('ok') is True and len(r)>10, d
assert ('producto' in r.lower()) or ('12.000' in r), 'no usó el catálogo: '+r
" 2>/dev/null && ok "chat por internet (nginx) usa el catálogo" || mal "chat por internet falló: $R"

# ── 6) recibo de cobro ──
paso "6) recibo de cobro"
REC="$PROY/07_COBROS/recibo.html"
if [ -f "$REC" ]; then
  ok "el recibo existe"
  grep -Fq '323 331 6186' "$REC" && ok "trae el número de pago" || mal "no trae el número de pago"
  for p in Esencial Profesional Escala; do
    grep -Fq "$p" "$REC" && ok "plan $p" || mal "falta el plan $p"
  done
else mal "no existe 07_COBROS/recibo.html"; fi

# ── 7) limpiar y confirmar que el sitio sigue bien ──
paso "7) borrar la prueba y comprobar que no se rompió nada"
rm -rf "$WEB/clientes/$SLUG" "$PROY/05_CLIENTES/$SLUG"
c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1/clientes/$SLUG/tienda.html")
[ "$c" = "404" ] && ok "la tienda de prueba ya no existe (404)" || mal "la tienda de prueba sigue visible ($c)"
c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1/")
[ "$c" = "200" ] && ok "sitio principal sigue 200" || mal "sitio principal $c"
c=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 15 "$URL_BASE/clientes/arepas-dona-rosa/tienda.html")
[ "$c" = "200" ] && ok "tienda demo (Doña Rosa) sigue 200" || mal "tienda demo $c"
SAL=$(/usr/local/bin/verificar_tienda.sh todas 2>&1); rc=$?
[ "$rc" -eq 0 ] && ok "todas las tiendas siguen aprobadas" || mal "alguna tienda quedó con problemas"
[ "$rc" -eq 0 ] || echo "$SAL" | sed 's/^/     /'

# ── 8) recepción de datos por Telegram ──
paso "8) recepción de datos por Telegram"
python3 - <<'PY' && ok "guarda fichas, capturas, adjuntos y limpia" || mal "la recepción de datos por Telegram falló"
import importlib.util, os, glob, tempfile, shutil
spec = importlib.util.spec_from_file_location("pt", "/usr/local/bin/puente_telegram.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
tmp = tempfile.mkdtemp(prefix="ma_tg_")
m.DIR_ENTRADAS = os.path.join(tmp, "entradas")
m.DIR_ADJUNTOS = os.path.join(tmp, "adjuntos")
m.ARCHIVO_CAPTURA = os.path.join(tmp, "captura.json")
try:
    ficha = ("Nombre del negocio: Prueba Telegram\n"
             "WhatsApp para pedidos: 3001234567\n"
             "Ciudad: Soacha\n"
             "Horario: Lun-Sab 6am-8pm\n"
             "Productos: Pan | 2000 | Caliente\n"
             "Métodos de pago: Nequi")
    assert m._parece_ficha(ficha)
    assert not m._parece_ficha("Hola, ¿cómo estás?")
    r = m.procesar(ficha)
    assert "Datos guardados" in r, r
    assert len(glob.glob(os.path.join(m.DIR_ENTRADAS, "cliente_*.txt"))) == 1
    assert len(glob.glob(os.path.join(m.DIR_ENTRADAS, "cliente_*.json"))) == 1
    r = m.procesar("/datos\nNombre del negocio: Prueba Dos\nWhatsApp: 3002223344\n"
                   "Ciudad: Bogotá\nProductos: Café | 3000 | Caliente")
    assert "Datos guardados" in r, r
    assert "CAPTURA ACTIVADA" in m.procesar("/captura")
    assert "Guardado" in m.procesar("Nombre del negocio: Prueba Captura")
    assert "Guardado" in m.procesar("WhatsApp: 3003334455")
    assert "Datos guardados" in m.procesar("/fin")
    assert "CAPTURA ACTIVADA" in m.procesar("/captura")
    assert "cancelada" in m.procesar("/cancelar")
    assert m._leer_captura() is None
    assert not glob.glob(os.path.join(m.DIR_ENTRADAS, "_borrador_*.txt"))
    print("     ficha, /datos, captura y cancelación OK")
finally:
    shutil.rmtree(tmp, ignore_errors=True)
PY

# ── resultado ──
fin=$(date +%s)
echo ""
echo "── RESULTADO ──"
echo "tiempo total: $((fin-inicio))s"
if [ "$fallos" -eq 0 ]; then
  echo "RESULTADO: ACEPTACIÓN COMPLETA — TODO FUNCIONA"
  exit 0
else
  echo "RESULTADO: $fallos FALLO(S)"
  exit 1
fi
