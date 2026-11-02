#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  KIT DE RECUPERACIÓN · MARKETATTACK
#  Se ejecuta todas las medianoches y envía el kit a Telegram.
#  Si el chat se borra, tú abres Telegram, bajas el kit, y sigues.
# ═══════════════════════════════════════════════════════════════
set -u
LOCK=/run/kit.lock
exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

W=/tmp/kit
IP=157.137.203.223
FECHA=$(date +%Y%m%d_%H%M)
DIR="$W/kit_$FECHA"
mkdir -p "$DIR"/{chat,config,scripts,estado}

echo "→ preparando kit..."

# ── 1) conversación vigente del opencode del VPS ──
sudo python3 /usr/local/bin/exportar_sesion.py \
  /home/ubuntu/.local/share/opencode/opencode.db \
  "$DIR/chat/conversacion" "marketattack" > "$DIR/chat/_resumen.txt" 2>&1
cat "$DIR/chat/_resumen.txt" | sed 's/^/   /'

# ── 2) estado del proyecto ──
{
  echo "ESTADO DEL PROYECTO · $(date '+%F %H:%M')"
  echo ""
  echo "── SERVICIOS ──"
  for s in nginx opencode puente-telegram; do
    echo "  $s: $(systemctl is-active $s)"
  done
  echo ""
  echo "── PÁGINAS (código real medido) ──"
  for u in "/" "/tienda.html" "/kit.html"; do
    echo "  http://$IP$u -> $(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "http://127.0.0.1$u")"
  done
  echo ""
  echo "── TIENDAS DE CLIENTES ──"
  for d in /var/www/marketattack/clientes/*/; do
    [ -d "$d" ] || continue
    s=$(basename "$d")
    echo "  $s -> http://$IP/clientes/$s/tienda.html ($(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "http://127.0.0.1/clientes/$s/tienda.html"))"
  done
  echo ""
  echo "── RESPALDOS ──"
  ls -1t /var/backups/marketattack/*.tar.gz 2>/dev/null | head -7 | while read f; do
    echo "  $(basename $f)  $(du -h "$f" | cut -f1)"
  done
  echo ""
  echo "── RECURSOS ──"
  echo "  Disco: $(df -h / | awk 'NR==2{print $4" libres de "$2}')"
  echo "  RAM:   $(free -m | awk '/Mem:/{print $7" MB libres de "$2}')"
  echo "  Uptime: $(uptime -p)"
  echo ""
  echo "── LLAVES AUTORIZADAS (huellas, NO las llaves) ──"
  sudo ssh-keygen -l -f /home/ubuntu/.ssh/authorized_keys
} > "$DIR/estado/ESTADO.txt" 2>&1

# ── 3) configuración y scripts (sin secretos) ──
# los scripts son de root: hay que leerlos con sudo
sudo cp /usr/local/bin/*.sh "$DIR/scripts/" 2>/dev/null
sudo cp /usr/local/bin/*.py "$DIR/scripts/" 2>/dev/null
sudo sed -E 's/(OPENCODE_SERVER_PASSWORD=)\S+/\1[OCULTA -- mira en el servidor]/' \
  /etc/systemd/system/opencode.service > "$DIR/config/opencode.service" 2>/dev/null
sudo sed -E 's/^(TELEGRAM_TOKEN|TELEGRAM_CHAT_ID)=.*/\1="[OCULTO -- mira en el servidor]"/' \
  /etc/marketattack/telegram.conf > "$DIR/config/telegram.conf.EJEMPLO" 2>/dev/null
sudo crontab -l > "$DIR/config/cron.txt" 2>/dev/null
sudo cp /etc/nginx/sites-available/marketattack "$DIR/config/nginx.conf" 2>/dev/null

# ── 3b) restaurador y prompt de pegado ──
sudo cp /usr/local/bin/RESTAURAR.sh "$DIR/RESTAURAR.sh" 2>/dev/null
sudo cp /usr/local/bin/PEGAME_ESTO_EN_EL_CHAT.txt "$DIR/PEGAME_ESTO_EN_EL_CHAT.txt" 2>/dev/null
chmod +x "$DIR/RESTAURAR.sh" 2>/dev/null


# ── 4) memoria del proyecto ──
cp "/home/personalamd/Documentos/Default Project/CONTEXTO.md" "$DIR/CONTEXTO.md" 2>/dev/null

# ── 4b) VALIDACIÓN: nunca enviar un kit incompleto ──
FALTAN=""
for req in RESTAURAR.sh PEGAME_ESTO_EN_EL_CHAT.txt CONTEXTO.md \
           chat/conversacion.md chat/conversacion.json estado/ESTADO.txt; do
  [ -s "$DIR/$req" ] || FALTAN="$FALTAN $req"
done
if [ -n "$FALTAN" ]; then
  echo "🚨 KIT INCOMPLETO, no se envía. Falta:$FALTAN"
  exit 1
fi
echo "  ✓ kit completo: restaurador, prompt, contexto, chat y estado"

# ── 5) auditoría de secretos (obligatoria) ──
# Se construye con los secretos REALES de ahora, así detecta también
# cualquier clave que se rote en el futuro.
CLAVE_ACTUAL=$(sudo grep -oE 'OPENCODE_SERVER_PASSWORD=\S+' /etc/systemd/system/opencode.service 2>/dev/null | cut -d= -f2-)
TOKEN_ACTUAL=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf 2>/dev/null | cut -d= -f2- | tr -d '"')
# SECRETO = cosas que NUNCA deben salir y se pueden enmascarar sin danar nada:
# llaves privadas reales, la clave vigente, el token vigente y las ya rotadas.
# Los patrones genericos van aparte en SOSPECHOSO: solo avisan, nunca tapan,
# porque un token de ejemplo en la documentacion no es una fuga real.
SECRETO="-----BEGIN[A-Z ]*PRIVATE KEY-----|OPENCODE_SERVER_PASSWORD=[A-Za-z0-9]|TELEGRAM_TOKEN=[0-9]|gsk_[A-Za-z0-9]{40,}"
SOSPECHOSO="[0-9]{8,10}:[A-Za-z0-9_-]{35}|gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9_-]{20,}"
esc() { printf '%s' "$1" | sed 's/[.[\*^$]/\\&/g'; }
[ -n "$CLAVE_ACTUAL" ] && SECRETO="$SECRETO|$(esc "$CLAVE_ACTUAL")"
[ -n "$TOKEN_ACTUAL" ] && SECRETO="$SECRETO|$(esc "$TOKEN_ACTUAL")"
# TODAS las claves ya rotadas: si una se filtra al kit, tambien se detecta
NROT=0
if [ -f /etc/marketattack/claves_rotadas.txt ]; then
  while IFS= read -r k; do
    k=$(printf '%s' "$k" | tr -d '\r')
    [ -z "$k" ] && continue
    case "$k" in \#*) continue ;; esac
    SECRETO="$SECRETO|$(esc "$k")"
    NROT=$((NROT+1))
  done < <(sudo cat /etc/marketattack/claves_rotadas.txt 2>/dev/null)
fi
[ "$NROT" -gt 0 ] && echo "  auditoria: clave actual + token + $NROT clave(s) rotada(s)"
# avisos: patrones que PODRIAN ser secretos, pero no se tapan (evita destruir texto)
SOSP=$(grep -rlIE -- "$SOSPECHOSO" "$DIR" 2>/dev/null | wc -l)
[ "$SOSP" -gt 0 ] && echo "  aviso: $SOSP archivo(s) con texto tipo token/api-key (revisar a mano, NO se tapa)"
FUGA=$(grep -rlIE -- "$SECRETO" "$DIR" 2>/dev/null)
if [ -n "$FUGA" ]; then
  echo "🚨 FUGA DE SECRETOS DETECTADA: $FUGA"
  echo "$FUGA" | while read f; do
    sed -i -E "s/$SECRETO/[SECRETO OCULTO]/g" "$f"
  done
fi

NLEAK=$(grep -rlIE -- "$SECRETO" "$DIR" 2>/dev/null | wc -l)
echo "  auditoría de secretos: $NLEAK archivos con fuga (0 = seguro)"

# ── 6) guía dentro del kit ──
cat > "$DIR/LEEME_PRIMERO.txt" <<'GUIA'
╔══════════════════════════════════════════════════════════════╗
║  KIT DE RECUPERACIÓN · MARKETATTACK                         ║
║  Para quoi: si se borró el chat, abres Telegram,           ║
║  descargas esto y continúas donde quedaste.                 ║
╚══════════════════════════════════════════════════════════════╝

CONTENIDO
  CONTEXTO.md          memoria del proyecto (léelo primero)
  chat/conversacion.md la conversación completa, en texto
  chat/conversacion.json  la misma, para programas
  estado/ESTADO.txt    cómo estaba todo al momento de este kit
  config/              opencode, nginx, cron, telegram (SANEADOS)
  scripts/             backup, publicar, watchdog, nuevo_cliente...
  RESTAURAR.sh         restaurador de un clic (bash RESTAURAR.sh)
  PEGAME_ESTO_EN_EL_CHAT.txt   prompt para pegar en opencode y recuperar

──────────────────────────────────────────────────────────────
SI EL CHAT SE BORRÓ: CÓMO VOLVER
──────────────────────────────────────────────────────────────
PASO 1. Copia CONTEXTO.md y chat/conversacion.md a una carpeta
        de tu computadora.

PASO 2. En la terminal, mira cómo sigue el servidor:
        ssh -i ~/.ssh/ma_celular ubuntu@157.137.203.223
        systemctl status opencode puente-telegram
        curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/tienda.html

PASO 3. Si el servidor sigue vivo, el chat NO está perdido:
        el bot de Telegram sigue respondiendo, y la conversación
        se conserva en el opencode del servidor.

PASO 4. Si quieres leer la conversación vieja sin instalar nada:
        abre chat/conversacion.md con cualquier editor de texto.

PASO 5. Si el opencode se reinició y perdió la sesión, crea una
        nueva y pega al inicio:
        "Lee CONTEXTO.md y chat/conversacion.md. Este es el estado
         de MARKETATTACK. Retomamos desde aquí."

PASO 6. Chat con IA real (si el servidor se rehizo):
        - Instala el backend:
            sudo cp scripts/chat_ia.py /usr/local/bin/marketattack_chat.py
            sudo chmod 755 /usr/local/bin/marketattack_chat.py
        - Crea la clave de IA (NO viene en el kit):
            sudo nano /etc/marketattack/ia.conf
            # contenido:
            # IA_PROVEEDOR="groq"
            # IA_MODELO="openai/gpt-oss-120b"
            # IA_API_KEY="gsk_... (se genera en console.groq.com)"
            sudo chmod 640 /etc/marketattack/ia.conf
            sudo chown root:www-data /etc/marketattack/ia.conf
        - Activa el servicio:
            sudo systemctl enable --now marketattack-chat
        - nginx debe tener: location ^~ /api/chat { proxy_pass http://127.0.0.1:8787; }
        - Comprueba: curl -s https://TU-DOMINIO/api/chat/health

──────────────────────────────────────────────────────────────
⚠ LOS SECRETOS NO ESTÁN AQUÍ (a propósito)
──────────────────────────────────────────────────────────────
Este archivo viaja por Telegram. Por eso NO lleva llaves privadas,
ni el token del bot, ni la contraseña del servidor: si se filtra,
quien lo lea entra a tu servidor.

Dónde están de verdad (solo en el VPS):
  Token del bot   → /etc/marketattack/telegram.conf  (permisos 600)
  Clave de IA     → /etc/marketattack/ia.conf        (permisos 640 root:www-data)
  Clave opencode  → /etc/systemd/system/opencode.service
                    copia legible: sudo cat /root/CLAVE_OPENCODE.txt
  Llave SSH PC    → tu computadora, ~/.ssh/
  Llave del celular → tu celular, ~/.ssh/ma_celular

COMO OBTENERLOS (si realmente los necesitas):
  ssh -i <tu-llave> ubuntu@157.137.203.223
  sudo grep TELEGRAM /etc/marketattack/telegram.conf
  sudo grep PASSWORD /etc/systemd/system/opencode.service
GUIA

# ── 7) STOP si hay fuga real: nunca sale un kit con secretos ──
NLEAK2=$(grep -rlIE -- "$SECRETO" "$DIR" 2>/dev/null | wc -l)
if [ "$NLEAK2" != "0" ]; then
  echo "🚨 DETENIDO: $NLEAK2 archivo(s) con secretos. NO se envía nada."
  grep -rlIE -- "$SECRETO" "$DIR" 2>/dev/null | sed 's/^/   /'
  exit 1
fi
echo "  ✓ verificación final: 0 secretos, se puede enviar"

# ── 7b) ARCHIVO ÚNICO para pegar a un chat nuevo de opencode ──
if /usr/local/bin/generar_restauracion.sh "$W/kit_$FECHA" 2>/dev/null; then
  echo "  ✓ RESTAURACION_RAPIDA.md (archivo único, autocontenido)"
  # la carpeta del kit se borra al comprimir: se guarda copia aparte
  cp "$W/kit_$FECHA/RESTAURACION_RAPIDA.md" /tmp/RESTAURACION_RAPIDA.md 2>/dev/null \
    && chmod 644 /tmp/RESTAURACION_RAPIDA.md
else
  echo "  ⚠ no se pudo generar RESTAURACION_RAPIDA.md"
fi

# ── 8) comprimir ──
cd "$W"
ZIP="$W/KIT_RECUPERACION_MARKETATTACK_$FECHA.zip"
zip -qr "$ZIP" "kit_$FECHA" && rm -rf "kit_$FECHA"
TAMA=$(du -h "$ZIP" | cut -f1)
NMSG=$(grep -oE "MENSAJES=[0-9]+" "$W/kit_$FECHA/chat/_resumen.txt" 2>/dev/null | cut -d= -f2)
[ -z "$NMSG" ] && NMSG=$(grep -m1 "^Mensajes:" /tmp/kit/kit_*/chat/conversacion.md 2>/dev/null | grep -oE "[0-9]+")

# ── 8) guardar en el servidor + enviar a Telegram ──
cp "$ZIP" /var/backups/marketattack/kits/ 2>/dev/null || \
  { sudo mkdir -p /var/backups/marketattack/kits; sudo cp "$ZIP" /var/backups/marketattack/kits/; }
ls -1t /var/backups/marketattack/kits/*.zip 2>/dev/null | tail -n +31 | xargs -r rm -f

bash /usr/local/bin/aviso_telegram.sh "🛟 <b>KIT DE RECUPERACIÓN LISTO</b>

📦 $TAMA · $NMSG mensajes guardados
💾 Guardado en el servidor también
🔑 Sin llaves ni tokens (a propósito)

<b>Si se borró el chat:</b> descarga este archivo, abre
<b>LEEME_PRIMERO.txt</b> y sigue los pasos. Traes la conversación
completa y el estado de todo.

Nombre: $(basename $ZIP)"

T=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2 | tr -d '"')
C=$(sudo grep TELEGRAM_CHAT_ID /etc/marketattack/telegram.conf | cut -d= -f2 | tr -d '"')
if [ -z "$T" ] || [ -z "$C" ]; then echo "🚨 sin token/chat: se guardó en disco pero no se envió"; exit 0; fi
sudo curl -s --max-time 300 -F "chat_id=$C" -F "document=@$ZIP" \
  "https://api.telegram.org/bot$T/sendDocument" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('  envío a Telegram:', 'OK' if d.get('ok') else 'FALLÓ '+str(d.get('description')))" 2>/dev/null

echo "✓ kit: $ZIP ($TAMA), $NMSG mensajes, secretos: $NLEAK"

# ── 9) también sueltos, para bajar UN solo archivo y pegarlo a otro chat ──
RAPIDA="/tmp/RESTAURACION_RAPIDA.md"
if [ -f "$RAPIDA" ]; then
  RAPIDA_SOLO="/var/backups/marketattack/kits/RESTAURACION_RAPIDA_$FECHA.md"
  sudo mkdir -p /var/backups/marketattack/kits
  sudo cp "$RAPIDA" "$RAPIDA_SOLO" && sudo chmod 644 "$RAPIDA_SOLO"
  ls -1t /var/backups/marketattack/kits/RESTAURACION_RAPIDA_*.md 2>/dev/null \
    | tail -n +15 | xargs -r sudo rm -f
  bash /usr/local/bin/aviso_telegram.sh "📄 <b>ARCHIVO ÚNICO DE RESTAURACIÓN</b>

Este es el que quieres para abrir un <b>chat nuevo</b> en opencode
en cualquier otro dispositivo.

<b>Cómo se usa (30 segundos):</b>
1. Descarga este archivo.
2. En opencode, nuevo chat, arrastra el archivo.
3. Escribe: <i>lee este archivo y retoma MARKETATTACK</i>

Trae todo dentro: cómo entrar al servidor, estado verificado, los
4 respaldos, los comandos de Telegram, el producto para vender,
<b>todos los scripts</b> y la memoria completa del proyecto.
Sin llaves ni tokens — eso se queda en el servidor.

Tamaño: $(sudo du -h "$RAPIDA_SOLO" | cut -f1)"
  sudo curl -s --max-time 120 -F "chat_id=$C" -F "document=@$RAPIDA_SOLO" \
    "https://api.telegram.org/bot$T/sendDocument" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print('  archivo único:', 'OK' if d.get('ok') else 'FALLÓ')" 2>/dev/null
fi

rm -rf "$W"
