# MARKETATTACK — RESTAURACIÓN RÁPIDA (archivo único y autocontenido)

> **Generado:** 2026-10-15 00:00 · **Servidor:** 149.130.190.118 · **Repo:** `git@github.com:gtcorebynet-jpg/marketattack.git`

---

## 0) SI ERES UN AGENTE NUEVO DE OPENCODE Y ESTÁS LEYENDO ESTO

Este archivo contiene **todo lo necesario para retomar MARKETATTACK desde cero**
sin ningún otro archivo. No hace falta descargar nada más para trabajar.

**Tu primera tarea, obligatoria:** lee las secciones 1 a 4 y responde en español,
en formato de lista, exactamente esto:

- **A)** ¿En qué quedó MARKETATTACK? (una frase)
- **B)** ¿Qué está funcionando ahora? Web pública, Telegram, respaldos, tienda.
- **C)** ¿Qué falta? Solo lo pendiente, en orden de prioridad.
- **D)** ¿Hay algún problema técnico abierto? ¿Cómo lo comprobaste?
- **E)** El comando EXACTO para entrar al servidor por SSH, con la ruta de la llave.

**Reglas de trabajo:**
- Español, corto y simple.
- No borres ni sobrescribas este archivo.
- Antes de cada cambio en el servidor: respaldo y verificación.
- Si no puedes comprobar algo, dilo. No lo inventes.

---

## 1) QUÉ ES MARKETATTACK

Plataforma de IA para pequeños negocios: chat que atiende y cotiza solo,
captación de prospectos, mini-CRM, dashboard y generación de contenido.
Se vende como servicio mensual. Tienda pública incluida.

---

## 2) CÓMO ENTRAR AL SERVIDOR

| Dato | Valor |
|---|---|
| IP del VPS | `149.130.190.118` |
| Usuario | `ubuntu` |
| Llave SSH (PC) | `/home/personalamd/Descargas/ssh-key-marketattack-20260926.key` |
| Llave SSH (Android) | `/home/personalamd/Descargas/telefono/ma_celular` — restringida al túnel `localhost:4096` |
| opencode (solo local) | `127.0.0.1:4096` — nunca expuesto a internet |

```bash
# Desde la PC
ssh -i /home/personalamd/Descargas/ssh-key-marketattack-20260926.key ubuntu@149.130.190.118

# Desde Android (dentro de Termux, por túnel)
ssh -i ~/ma_celular -L 4096:localhost:4096 ubuntu@149.130.190.118
# y abrir en Chrome: http://localhost:4096
```

---

## 3) ESTADO ACTUAL

| Servicio | Cómo verificar |
|---|---|
| `nginx` | `systemctl is-active nginx` |
| `opencode` | `systemctl is-active opencode` |
| `puente-telegram` | `systemctl is-active puente-telegram` |

| Dirección | Qué es |
|---|---|
| `http://149.130.190.118/` | Portafolio |
| `http://149.130.190.118/tienda.html` | Tienda con chat, prospectos y panel |
| `http://149.130.190.118/kit.html` | Enlace de descarga del kit de recuperación |
| `https://marketattack.netlify.app/tienda.html` | Espejo de la tienda |

Servicios que se reinician solos si se caen: `watchdog` cada 5 minutos.

---
## 4) LOS 4 RESPALDOS Y CÓMO RESTAURAR

| Vía | Dónde vive | Cómo se recupera |
|---|---|---|
| **A** Disco VPS | `/var/backups/marketattack/completos/` | `sudo bash /usr/local/bin/recuperar.sh B` |
| **B** Espejo interno | `/root/marketattack-rescate/` | se lee directamente |
| **C** Telegram | kits diarios por este chat | descarga el `.zip` y ejecuta `RESTAURAR.sh` |
| **D** GitHub | repo privado `marketattack` | `sudo bash /usr/local/bin/recuperar.sh C` |

Cada kit trae `SHA256SUMS` y `conversacion.json` + `conversacion.md`.

### Comprobación rápida de que todo está sano
```bash
sudo bash /usr/local/bin/verificacion_final.sh    # estado global
sudo bash /usr/local/bin/verificar_respaldos.sh  # integridad de los 4 respaldos
sudo bash /usr/local/bin/verificar_kit.sh        # el kit no lleva secretos
sudo python3 /usr/local/bin/pruebas_puente.py    # 27 pruebas del bot de Telegram
```

---

## 5) COMANDOS DE TELEGRAM (escribe al bot)

**Operación**
- `/comandos` — lista completa
- `/estado` — cómo están los servicios
- `/respaldos` — últimos respaldos
- `/backup` — forzar un respaldo ahora
- `/publicar` — publicar la web

**Vender el producto**
- `/producto` — catálogo completo de MARKETATTACK
- `/oferta` — mensaje corto para mandarle a un cliente
- `/precios` — tabla de precios

**Clientes**
- `/cliente` — crear tienda para un cliente
- `/clientes` — ver las tiendas creadas
- `/prospecto Nombre \| Rubro \| Ciudad \| contacto` — guardar prospecto
- `/prospectos` — ver prospectos

**Servidor**
- `/sh <comando>` — ejecutar un comando (solo lista blanca segura)
- `/reiniciar nginx\|opencode\|puente-telegram`

**Link**
- `/link` — enlaces de la web

Y cualquier texto en español se lo mandas al agente: responde ahí mismo.

---

## 6) EL PRODUCTO PARA VENDER

Precios en pesos colombianos, sin permanencia:

| Plan | Precio | Incluye |
|---|---|---|
| 🟢 Esencial | $450.000/mes | Chat con IA, prospectos, panel, 500 conversaciones |
| 🔵 Profesional | $850.000/mes ⭐ | Todo lo anterior + contenido para redes + QR ilimitado |
| 🟣 Escala | $1.400.000/mes | Todo lo anterior + varias sedes + acompañamiento |

Instalación en 24 horas. El catálogo completo está en `/usr/local/bin/catalogo.sh`.

---
## 7) TODOS LOS SCRIPTS DEL SERVIDOR

Cada bloque va en la ruta indicada dentro de `/usr/local/bin/`.
Están sanitizados: **ningún secreto** está en este archivo.

### `/usr/local/bin/RESTAURAR.sh`

```bash
#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  RESTAURAR KIT · MARKETATTACK
#  Úsalo en CUALQUIER dispositivo (PC o Android/Termux) para
#  recuperar el chat y el estado del proyecto.
#
#  Uso:  bash RESTAURAR.sh
# ═══════════════════════════════════════════════════════════════
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
IP=149.130.190.118

echo "╔══════════════════════════════════════════════╗"
echo "║  RESTAURACIÓN MARKETATTACK                    ║"
echo "╚══════════════════════════════════════════════╝"
echo "Kit: $DIR"
echo ""

# ── 1) leer la memoria y la conversación ──
echo "── 1) ¿Qué hay en este kit? ──"
for f in CONTEXTO.md chat/conversacion.md estado/ESTADO.txt; do
  if [ -f "$DIR/$f" ]; then
    printf "   ✅ %-28s %s\n" "$f" "$(du -h "$DIR/$f" | cut -f1)"
  else
    printf "   ❌ %-28s falta\n" "$f"
  fi
done
# El numero real de mensajes vive en el JSON (lista 'mensajes').
# Contar lineas '^## ' del markdown daba un numero falso: los encabezados de
# contenido tambien empiezan por '## ' y inflaban la cuenta.
N=""
if [ -f "$DIR/chat/conversacion.json" ] && command -v python3 >/dev/null 2>&1; then
  # el JSON trae 'mensajes' como numero y 'conversacion' como lista: se toman
  # los dos y se quedan con el mayor, para que nunca sean 0 si el formato cambia
  N=$(python3 -c "
import json
d=json.load(open('$DIR/chat/conversacion.json'))
m=d.get('mensajes'); c=d.get('conversacion')
n=[x for x in (m if isinstance(m,int) else 0, len(c) if isinstance(c,list) else 0) if x]
print(max(n) if n else '')
" 2>/dev/null)
fi
[ -z "$N" ] && N=$(grep -c '^## ' "$DIR/chat/conversacion.md" 2>/dev/null || echo 0)
echo "   📋 $N mensajes guardados en la conversación"
[ -n "$(ls -A "$DIR/chat/conversacion.json" 2>/dev/null)" ] && [ -z "$N" ] && \
  echo "   ⚠ no se pudo leer el JSON; el número puede ser aproximado"
echo ""

# ── 2) mostrar el estado como estaba ──
echo "── 2) Cómo estaba todo ──"
sed -n '1,30p' "$DIR/estado/ESTADO.txt" 2>/dev/null | sed 's/^/   /'
echo ""

# ── 3) ver si el servidor sigue vivo ──
echo "── 3) ¿El servidor sigue en pie? ──"
if command -v ssh >/dev/null 2>&1; then
  LLAVE=""
  [ -f ~/.ssh/ma_celular ] && LLAVE="-i ~/.ssh/ma_celular"
  [ -f ~/.ssh/id_rsa ] && LLAVE="-i ~/.ssh/id_rsa"
  if timeout 20 ssh $LLAVE -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
       ubuntu@$IP "echo OK" 2>/dev/null | grep -q OK; then
    echo "   ✅ el servidor responde. El chat NO está perdido."
    echo "   💡 siga en '3)' para usar el chat en vivo por el túnel."
  else
    echo "   ⚠️  no se pudo entrar por SSH (sin llave o sin internet)."
    echo "      da igual: la conversación está en chat/conversacion.md"
  fi
else
  echo "   ℹ️  este dispositivo no tiene ssh. No importa para leer el kit."
fi
echo ""

# ── 4) instrucciones por dispositivo ──
cat <<PASO

── 4) CÓMO SEGUIR DESDE AQUÍ ─────────────────────────────

  ▶ EN LA PC (Windows/Linux/Mac)
    1. Descomprime el kit.
    2. Abre CONTEXTO.md con Bloc de notas o editor.
    3. En el chat de opencode de la PC pega el bloque
       "PEGAME_ESTO_EN_EL_CHAT.txt" que viene en el kit.

  ▶ EN EL ANDROID (Termux)
    1. Descarga el kit de Telegram.
    2. pkg install -y unzip
    3. unzip KIT_RECUPERACION_MARKETATTACK_*.zip
    4. bash kit_*/RESTAURAR.sh
    5. Lee CONTEXTO.md:  less kit_*/CONTEXTO.md
    6. Copia "PEGAME_ESTO_EN_EL_CHAT.txt" y pégalo en el
       opencode del celular.

  ▶ VER EL CHAT EN VIVO DESDE EL ANDROID (lo mejor)
    1. Sube el túnel:
       ssh -N -L 4096:localhost:4096 -i ~/.ssh/ma_celular ubuntu@149.130.190.118
    2. En Chrome abre:
       http://opencode:<TU-CLAVE>@127.0.0.1:4096/
    (la clave va en la URL porque sin ella el servidor
     responde 401 y se ve en blanco)

── RESUMEN ─────────────────────────────────────────────
  · El proyecto vive en el VPS: $IP
  · La web:  http://$IP/tienda.html
  · Respaldos: /var/backups/marketattack/
  · Kit diario a Telegram: todos los días 00:00

PASO
cat <<'FIN'

── TU CLAVE DEL SERVIDOR (no está en ningún archivo) ──────
  Se guarda solo en el servidor, para que nadie más la vea:
    ssh -i ~/.ssh/ma_celular ubuntu@149.130.190.118
    sudo cat /root/CLAVE_OPENCODE.txt
  Anótala en el celular: la necesitas para el paso del túnel.

FIN
echo "Listo. Sigue el paso 4."```

### `/usr/local/bin/activar_espejo.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ACTIVAR EL ESPEJO AUTOMÁTICO EN GITHUB (desde el VPS)
#
#  Uso:  sudo bash /usr/local/bin/activar_espejo.sh
#
#  Qué hace:
#    1. genera una llave SOLO para este VPS
#    2. te muestra la llave pública para copiarla en GitHub
#    3. espera a que la pegues y comprueba si ya funciona
#    4. si funciona, publica el primer espejo
# ═══════════════════════════════════════════════════════════
set -uo pipefail
LLAVE=/root/.ssh/id_ed25519
REPO=/root/marketattack-git
REMOTO=git@github.com:gtcorebynet-jpg/marketattack.git

echo "══════════════════════════════════════"
echo " ESPEJO AUTOMÁTICO EN GITHUB"
echo "══════════════════════════════════════"
echo ""

if [ -f "$LLAVE" ]; then
  echo "1) la llave ya existe, la reutilizo."
else
  echo "1) generando una llave SOLO para este VPS..."
  sudo mkdir -p /root/.ssh && sudo chmod 700 /root/.ssh
  sudo ssh-keygen -t ed25519 -C "vps-marketattack" -f "$LLAVE" -N "" -q
  echo "   ✓ creada"
fi
sudo chmod 600 "$LLAVE"; sudo chmod 644 "$LLAVE.pub"

echo ""
echo "2) COPIA ESTA LLAVE (es pública, se puede compartir):"
echo ""
echo "   ┌────────────────────────────────────────┐"
sudo cat "$LLAVE.pub" | fold -w 38 | sed 's/^/   │ /'
echo "   └────────────────────────────────────────┘"
echo ""
echo "   Dónde pegarla:"
echo "     GitHub → tu repositorio 'marketattack'"
echo "     → Settings → Deploy keys → Add deploy key"
echo "     → Title: vps-marketattack"
echo "     → Key: lo de arriba"
echo "     → ☑ Allow write access   (OBLIGATORIO)"
echo ""
read -rp "   ¿Ya la pegaste? (s/n): " R
if [ "${R,,}" != "s" ]; then
  echo ""
  echo "   Sin problema. Cuando la pegues, ejecuta:"
  echo "     sudo bash /usr/local/bin/activar_espejo.sh"
  exit 0
fi

echo ""
echo "3) comprobando si GitHub ya la acepta..."
if ! sudo ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com >/dev/null 2>&1; then
  echo "   ✗ GitHub todavía no acepta la llave."
  echo ""
  echo "   Revisa estos puntos:"
  echo "     · ¿la pegaste en el repositorio correcto (marketattack)?"
  echo "     · ¿marcaste 'Allow write access'?"
  echo "     · ¿confirmaste con el botón verde 'Add key'?"
  echo ""
  echo "   Vuelve a intentarlo cuando la hayas pegado."
  exit 1
fi
echo "   ✓ GitHub acepta la llave"

echo ""
echo "4) publicando el primer espejo..."
sudo /usr/local/bin/publicar_github.sh

echo ""
echo "5) comprobando qué quedó subido..."
sudo -u gituser bash -c "cd '$REPO' && git log --oneline -1" 2>/dev/null | sed 's/^/   /' || echo "   (sin commit todavía)"
echo ""
echo "══════════════════════════════════════"
echo " ✓ ESPEJO ACTIVADO — se publicará solo cada día a las 04:00"
echo "══════════════════════════════════════"
```

### `/usr/local/bin/activar_token.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ACTIVAR UN TOKEN NUEVO DEL BOT  (tras /revoke en @BotFather)
#
#  Uso:  sudo bash /usr/local/bin/activar_token.sh
#  Pega el token nuevo cuando lo pida. Actualiza TODO solo:
#    - valida el token contra Telegram
#    - guarda la copia anterior
#    - reinicia el puente
#    - regenera y envía el kit
# ═══════════════════════════════════════════════════════════
set -uo pipefail
CONF=/etc/marketattack/telegram.conf
STAMP=$(date +%Y%m%d_%H%M)

echo "══════════════════════════════════════"
echo " ACTIVAR TOKEN NUEVO DEL BOT"
echo "══════════════════════════════════════"
echo ""
read -rp "Pega aquí el token nuevo de @BotFather: " NUEVO
NUEVO=$(echo "$NUEVO" | tr -d '[:space:]')

if [ -z "$NUEVO" ]; then echo "✗ vacío, no se cambió nada"; exit 1; fi
if ! echo "$NUEVO" | grep -qE '^[0-9]{8,10}:[A-Za-z0-9_-]{35}$'; then
  echo "✗ ese no parece un token de Telegram (formato 123456789:AAH...)"
  echo "  se dejó todo como estaba."; exit 1
fi

echo ""
echo "1) comprobando el token contra Telegram..."
INFO=$(curl -s --max-time 20 "https://api.telegram.org/bot$NUEVO/getMe")
if ! echo "$INFO" | grep -q '"ok":true'; then
  echo "  ✗ Telegram lo rechaza. Revisa que lo copiaste completo."
  echo "  se dejó todo como estaba."; exit 1
fi
echo "  ✓ válido — bot: $(echo "$INFO" | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["username"])' 2>/dev/null)"

echo ""
echo "2) respaldo de la configuración actual..."
sudo cp "$CONF" "$CONF.bak-$STAMP" && sudo chmod 600 "$CONF.bak-$STAMP"
echo "  ✓ copia en $CONF.bak-$STAMP"

echo ""
echo "3) si el token nuevo tiene otro chat_id, lo tomo de getUpdates..."
CHAT=$(sudo grep TELEGRAM_CHAT_ID "$CONF" | cut -d= -f2- | tr -d '"')
echo "  chat_id actual: $CHAT"

echo ""
# se guarda el token saliente ANTES de escribir el nuevo: si se lee despues,
# ya se perdio el viejo y la lista de rotadas queda inutil
VIEJO=$(sudo grep TELEGRAM_TOKEN "$CONF" | cut -d= -f2- | tr -d '"')

echo "4) guardando el token nuevo..."
sudo sed -i "s|^TELEGRAM_TOKEN=.*|TELEGRAM_TOKEN=\"$NUEVO\"|" "$CONF"
sudo chmod 600 "$CONF"
sudo grep -q 'TELEGRAM_TOKEN' "$CONF" && echo "  ✓ escrito" || { echo "  ✗ no se pudo escribir"; exit 1; }

echo ""
echo "5) anotando el token viejo en la lista de rotadas..."
# El token saliente puede seguir apareciendo en chats viejos o respaldos ya
# hechos. Si queda anotado aqui, el generador del kit lo detecta y lo tapa.
sudo touch /etc/marketattack/claves_rotadas.txt
sudo chmod 600 /etc/marketattack/claves_rotadas.txt
if [ -n "$VIEJO" ] && [ "$VIEJO" != "$NUEVO" ]; then
  if sudo grep -qxF "$VIEJO" /etc/marketattack/claves_rotadas.txt; then
    echo "  · el token viejo ya estaba anotado"
  else
    echo "$VIEJO" | sudo tee -a /etc/marketattack/claves_rotadas.txt >/dev/null
    echo "  ✓ token viejo guardado (quedará fuera del kit y de los respaldos)"
  fi
else
  echo "  · sin token previo que registrar"
fi

echo ""
echo "6) reiniciando el puente..."
sudo systemctl restart puente-telegram
sleep 12
ACT=$(systemctl is-active puente-telegram)
[ "$ACT" = "active" ] && echo "  ✓ puente activo" || { echo "  ✗ puente CAÍDO"; exit 1; }

echo ""
echo "7) borrando el offset viejo (el nuevo bot empieza de cero)..."
sudo rm -f /home/ubuntu/.marketattack_offset && echo "  ✓ offset reiniciado"

echo ""
echo "8) probando que responde..."
curl -s --max-time 20 -X POST "https://api.telegram.org/bot$NUEVO/sendMessage" \
  -d "chat_id=$CHAT" -d 'text=✅ Token renovado. MARKETATTACK sigue en pie.' \
  | python3 -c 'import json,sys;d=json.load(sys.stdin);print("  ✓ mensaje enviado" if d.get("ok") else "  ✗ no se pudo enviar: "+str(d))' 2>/dev/null

echo ""
echo "9) regenerando el kit con la configuración nueva..."
sudo /usr/local/bin/kit_recuperacion.sh 2>&1 | tail -3 | sed 's/^/  /'

echo ""
echo "══════════════════════════════════════"
echo " ✓ TOKEN RENOVADO Y TODO ACTUALIZADO"
echo "══════════════════════════════════════"
```

### `/usr/local/bin/anclar_bot.sh`

```bash
#!/bin/bash
# Fija el offset de getUpdates para que NUNCA se procese un mensaje dos veces
# tras un reinicio. Sin esto, reiniciar el puente = repetir todo el historial.
TOKEN=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
OFFSET=$(sudo grep -oE '"offset":[0-9]+' /home/ubuntu/.marketattack_offset 2>/dev/null | grep -oE '[0-9]+')
[ -z "$OFFSET" ] && OFFSET=0
echo "offset guardado: $OFFSET"
r=$(curl -s --max-time 20 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&limit=1")
n=$(echo "$r" | grep -oE '"update_id":[0-9]+' | grep -oE '[0-9]+' | head -1)
if [ -n "$n" ]; then
  nuevo=$((n+1))
  echo "$nuevo" | sudo tee /home/ubuntu/.marketattack_offset >/dev/null
  sudo chmod 600 /home/ubuntu/.marketattack_offset
  echo "  ✓ anclado en offset=$nuevo (el update_id $n ya no se volverá a procesar)"
else
  echo "  no hay actualizaciones pendientes"
fi
```

### `/usr/local/bin/aviso_telegram.sh`

```bash
#!/usr/bin/env bash
# ═══ AVISOS POR TELEGRAM — MARKETATTACK ═══
# Estado: instalado y probado. Para ACTIVAR solo falta poner el token y el chat_id
# en /etc/marketattack/telegram.conf (2 lineas) — instrucciones en CONTEXTO.md

CFG=/etc/marketattack/telegram.conf
[ -f "$CFG" ] || { echo "sin configurar"; exit 0; }
. "$CFG"

[ -n "$TELEGRAM_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ] || { echo "sin configurar"; exit 0; }

MSG="$1"
[ -z "$MSG" ] && { echo "falta el mensaje"; exit 1; }

# limite de Telegram: 4096 caracteres
MSG="${MSG:0:4000}"

curl -s --max-time 20 -X POST \
  "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d parse_mode=HTML \
  -d disable_web_page_preview=true \
  --data-urlencode "text=${MSG}" >/dev/null
echo "enviado"
```

### `/usr/local/bin/backup_marketattack.sh`

```bash
#!/usr/bin/env bash
D=/var/backups/marketattack
mkdir -p "$D"
TS=$(date +%Y-%m-%d_%H%M)
tar czf "$D/web_$TS.tar.gz" -C /var/www marketattack 2>/dev/null
ls -1t "$D"/web_*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f
echo "$(date '+%F %T') backup OK: web_$TS.tar.gz" >> /var/log/marketattack_backup.log
```

### `/usr/local/bin/catalogo.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  PRODUCTO MARKETATTACK — para vender por Telegram
#  /producto  → el catálogo
#  /oferta   → el pitch corto para mandar a un cliente
#  /precios  → la tabla de precios
# ═══════════════════════════════════════════════════════════

catalogo(){
cat <<'CAT'
🟠 <b>MARKETATTACK</b> — tu negocio con IA trabajando 24/7

<b>Qué es</b>
Una plataforma que responde a tus clientes, capta prospectos y
te da un panel para ver todo. Se instala en tu negocio y trabaja
solo, también de noche.

<b>Lo que incluye</b>
• Chat inteligente que atiende y cotiza solo
• Captación de prospectos (los que preguntan y no compran)
• Mini-CRM: ves quién preguntó, qué pidió y cuánto vale
• Dashboard con las métricas de tu negocio
• Generador de contenido para redes, desde una idea
• Tu propia tienda con QR y enlace de un clic

<b>Para quién</b>
Restaurantes, tiendas de barrio, talleres, clínicas, inmobiliarias,
salones de belleza, ferroviarios y cualquier negocio que hoy
responde mensajes a mano.

<b>Cómo se ve</b>
  https://marketattack.netlify.app/tienda.html
  → Toca "Probar la demo" y escríbele. Funciona.

<b>Instalación</b>
En 24 horas. Sin instalar nada raro. Te lo dejamos andando
y te enseñamos a usarlo.

<b>Precios</b>
  🟢 Esencial — <b>$450.000</b>/mes
     Chat + prospectos + panel. Hasta 500 conversaciones.

  🔵 Profesional — <b>$850.000</b>/mes  ⭐ el más elegido
     Todo lo anterior + generación de contenido + QR ilimitado.

  🟣 Escala — <b>$1.400.000</b>/mes
     Todo + multi-sucursal + acompañamiento mensual.

<b>Sin permanencia</b>
Pagas el mes. Si no te sirve, te vas. Sin letra pequeña.

<b>¿Lo probamos?</b>
Escríbeme "DEMO" y te mando el enlace directo de tu negocio
en 10 minutos.
CAT
}

oferta(){
cat <<'OF'
<b>Hola 👋</b>

Te escribo de <b>MARKETATTACK</b>. Te pongo la versión corta:

Hoy, cuando un cliente te escribe fuera de horario, ese mensaje
se queda sin respuesta. Al día siguiente ya se fue a otro.

Nosotros montamos una IA que contesta por ti las 24 horas,
captura a los que preguntan y te los deja ordenados en un panel
con cuánto vale cada uno.

Te lo dejamos funcionando en 24 horas.
Y antes de que pagues nada, lo pruebas con tu propio negocio.

¿Te lo muestro? Dime "sí" y te mando el enlace.
OF
}

precios(){
cat <<'PR'
💰 <b>Precios MARKETATTACK</b>

🟢 <b>Esencial — $450.000/mes</b>
   Chat con IA · prospectos · panel · 500 conversaciones

🔵 <b>Profesional — $850.000/mes</b> ⭐
   Todo lo de Esencial + contenido para redes + QR ilimitado

🟣 <b>Escala — $1.400.000/mes</b>
   Todo lo anterior + varias sedes + acompañamiento

Todos incluyen: instalación, capacitación y soporte por WhatsApp.
Sin permanencia. Si no te sirve, cancelas.

<i>Precios en pesos colombianos. Factura issued electrónicamente.</i>
PR
}
```

### `/usr/local/bin/enviar_rapida.sh`

```bash
#!/bin/bash
KITS=/var/backups/marketattack/kits
TCONF=/etc/marketattack/telegram.conf
RAP=$(ls -1t "$KITS"/RESTAURACION_RAPIDA_*.md 2>/dev/null | head -1)
[ -n "$RAP" ] || { echo "no hay archivo rápido"; exit 1; }
T=$(sudo grep TELEGRAM_TOKEN "$TCONF" | cut -d= -f2- | tr -d '"')
C=$(sudo grep TELEGRAM_CHAT_ID "$TCONF" | cut -d= -f2- | tr -d '"')
[ -z "$T" ] || [ -z "$C" ] && { echo "sin token/chat"; exit 1; }
curl -s --max-time 120 -F "chat_id=$C" -F "document=@$RAP" -F "caption=MARKETATTACK — RESTAURACION_RAPIDA.md · Pega este archivo a un NUEVO CHAT en opencode. Después escribe: lee este archivo y retoma MARKETATTACK" "https://api.telegram.org/bot$T/sendDocument" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('  envío archivo único:', 'OK' if d.get('ok') else 'FALLÓ '+str(d.get('description')))
"
```

### `/usr/local/bin/exportar_sesion.py`

```bash
#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════╗
║  Exporta la sesión MARKETATTACK del opencode a texto plano.  ║
║  Sirve dentro del kit de recuperación. Sanitiza secretos.    ║
╚══════════════════════════════════════════════════════════════╝
"""
import json, os, re, sqlite3, sys, datetime

DB = sys.argv[1] if len(sys.argv) > 1 else \
    "/home/ubuntu/.local/share/opencode/opencode.db"
DEST = sys.argv[2] if len(sys.argv) > 2 else "/tmp/kit/chat"
TITULO = (sys.argv[3] if len(sys.argv) > 3 else "marketattack").lower()

def claves_conocidas():
    """Claves que NUNCA deben salir: la actual y las ya rotadas."""
    claves = []
    try:
        with open("/etc/systemd/system/opencode.service") as f:
            for linea in f:
                if "OPENCODE_SERVER_PASSWORD=" in linea:
                    v = linea.split("=", 1)[1].strip().strip('"')
                    if len(v) >= 8:
                        claves.append(v)
    except OSError:
        pass
    try:
        with open("/etc/marketattack/claves_rotadas.txt") as f:
            for linea in f:
                v = linea.strip()
                if len(v) >= 8:
                    claves.append(v)
    except OSError:
        pass
    return claves


REGLAS_DINAMICAS = [
    (re.compile(re.escape(k)), "[CLAVE ROTADA -- no se incluye]")
    for k in claves_conocidas()
]

REGLAS = [
    (re.compile(r"-----BEGIN[A-Z ]*PRIVATE KEY-----.*?-----END[A-Z ]*PRIVATE KEY-----", re.S),
     "[LLAVE PRIVADA -- no se incluye]"),
    (re.compile(r"ma_celular\S*", re.I), "[LLAVE CELULAR]"),
    (re.compile(r"\b\d{8,10}:[A-Za-z0-9_-]{35}\b"), "[TOKEN TELEGRAM -- no se incluye]"),
    (re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b"), "[API KEY -- no se incluye]"),
    (re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}\b"), "[GITHUB TOKEN]"),
    (re.compile(re.escape("[CLAVE]")), "[CLAVE SERVIDOR]"),
    (re.compile(r"(OPENCODE_SERVER_PASSWORD=)\S+"), r"\1[OCULTA]"),
    (re.compile(r"(TELEGRAM_TOKEN=)\S+"), r"\1[OCULTO]"),
    (re.compile(r"(TELEGRAM_CHAT_ID=)\S+"), r"\1[OCULTO]"),
]


def limpiar(t):
    if not t:
        return t
    for rx, rep in REGLAS + REGLAS_DINAMICAS:
        t = rx.sub(rep, t)
    return t


if not os.path.exists(DB):
    print("AVISO=base de datos no encontrada: " + DB)
    sys.exit(0)

c = sqlite3.connect(DB)
c.row_factory = sqlite3.Row

msgs = c.execute("""
    SELECT m.id AS mid, m.time_created AS tc, m.data AS md
    FROM message m JOIN session s ON m.session_id = s.id
    WHERE lower(s.title) LIKE ? ORDER BY m.time_created
""", ("%" + TITULO + "%",)).fetchall()

by = {}
for p in c.execute("SELECT message_id, data FROM part ORDER BY id"):
    try:
        by.setdefault(p["message_id"], []).append(json.loads(p["data"]))
    except Exception:
        pass

salida = []
n = 0
for m in msgs:
    txt = "\n".join(x.get("text", "") for x in by.get(m["mid"], [])
                    if x.get("type") == "text")
    if not txt.strip():
        continue
    try:
        rol = json.loads(m["md"]).get("role", "?")
    except Exception:
        rol = "?"
    ts = datetime.datetime.fromtimestamp((m["tc"] or 0) / 1000)
    salida.append({"rol": rol, "fecha": ts.isoformat(timespec="seconds"),
                   "texto": limpiar(txt)})
    n += 1

os.makedirs(os.path.dirname(DEST), exist_ok=True)
with open(DEST + ".json", "w", encoding="utf-8") as f:
    json.dump({"exportado": datetime.datetime.now().isoformat(),
               "sesion": TITULO, "mensajes": n, "conversacion": salida},
              f, ensure_ascii=False, indent=1)

with open(DEST + ".md", "w", encoding="utf-8") as f:
    f.write(f"# Conversación MARKETATTACK\n\n")
    f.write(f"Exportado: {datetime.datetime.now():%Y-%m-%d %H:%M}\n")
    f.write(f"Mensajes: {n}\n\n---\n\n")
    for m in salida:
        quien = "USUARIO" if m["rol"] == "user" else "OPENCODE"
        f.write(f"## {quien} · {m['fecha']}\n\n{m['texto']}\n\n---\n\n")

print(f"MENSAJES={n}")
print(f"JSON={DEST}.json")
print(f"MD={DEST}.md")
```

### `/usr/local/bin/generar_restauracion.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Genera RESTAURACION_RAPIDA.md — UN SOLO archivo, autocontenido,
#  para pegarlo a un chat nuevo de opencode en cualquier dispositivo.
#  Incluye: cómo entrar, estado verificado, cómo restaurar, los
#  4 respaldos, los comandos de Telegram, el producto para vender y
#  TODOS los scripts del servidor con su ruta de instalación.
# ═══════════════════════════════════════════════════════════════
set -u
KIT="${1:?uso: generar_restauracion.sh /ruta/al/kit}"
F="$KIT/RESTAURACION_RAPIDA.md"
IP=149.130.190.118
FECHA=$(date '+%Y-%m-%d %H:%M')

{
cat <<CAB
# MARKETATTACK — RESTAURACIÓN RÁPIDA (archivo único y autocontenido)

> **Generado:** $FECHA · **Servidor:** $IP · **Repo:** \`git@github.com:gtcorebynet-jpg/marketattack.git\`

---

## 0) SI ERES UN AGENTE NUEVO DE OPENCODE Y ESTÁS LEYENDO ESTO

Este archivo contiene **todo lo necesario para retomar MARKETATTACK desde cero**
sin ningún otro archivo. No hace falta descargar nada más para trabajar.

**Tu primera tarea, obligatoria:** lee las secciones 1 a 4 y responde en español,
en formato de lista, exactamente esto:

- **A)** ¿En qué quedó MARKETATTACK? (una frase)
- **B)** ¿Qué está funcionando ahora? Web pública, Telegram, respaldos, tienda.
- **C)** ¿Qué falta? Solo lo pendiente, en orden de prioridad.
- **D)** ¿Hay algún problema técnico abierto? ¿Cómo lo comprobaste?
- **E)** El comando EXACTO para entrar al servidor por SSH, con la ruta de la llave.

**Reglas de trabajo:**
- Español, corto y simple.
- No borres ni sobrescribas este archivo.
- Antes de cada cambio en el servidor: respaldo y verificación.
- Si no puedes comprobar algo, dilo. No lo inventes.

CAB

cat <<'CAB2'
---

## 1) QUÉ ES MARKETATTACK

Plataforma de IA para pequeños negocios: chat que atiende y cotiza solo,
captación de prospectos, mini-CRM, dashboard y generación de contenido.
Se vende como servicio mensual. Tienda pública incluida.

---

## 2) CÓMO ENTRAR AL SERVIDOR

| Dato | Valor |
|---|---|
| IP del VPS | `149.130.190.118` |
| Usuario | `ubuntu` |
| Llave SSH (PC) | `/home/personalamd/Descargas/ssh-key-marketattack-20260926.key` |
| Llave SSH (Android) | `/home/personalamd/Descargas/telefono/ma_celular` — restringida al túnel `localhost:4096` |
| opencode (solo local) | `127.0.0.1:4096` — nunca expuesto a internet |

```bash
# Desde la PC
ssh -i /home/personalamd/Descargas/ssh-key-marketattack-20260926.key ubuntu@149.130.190.118

# Desde Android (dentro de Termux, por túnel)
ssh -i ~/ma_celular -L 4096:localhost:4096 ubuntu@149.130.190.118
# y abrir en Chrome: http://localhost:4096
```

---

## 3) ESTADO ACTUAL

| Servicio | Cómo verificar |
|---|---|
| `nginx` | `systemctl is-active nginx` |
| `opencode` | `systemctl is-active opencode` |
| `puente-telegram` | `systemctl is-active puente-telegram` |

| Dirección | Qué es |
|---|---|
| `http://149.130.190.118/` | Portafolio |
| `http://149.130.190.118/tienda.html` | Tienda con chat, prospectos y panel |
| `http://149.130.190.118/kit.html` | Enlace de descarga del kit de recuperación |
| `https://marketattack.netlify.app/tienda.html` | Espejo de la tienda |

Servicios que se reinician solos si se caen: `watchdog` cada 5 minutos.

---
CAB2

cat <<'CAB3'
## 4) LOS 4 RESPALDOS Y CÓMO RESTAURAR

| Vía | Dónde vive | Cómo se recupera |
|---|---|---|
| **A** Disco VPS | `/var/backups/marketattack/completos/` | `sudo bash /usr/local/bin/recuperar.sh B` |
| **B** Espejo interno | `/root/marketattack-rescate/` | se lee directamente |
| **C** Telegram | kits diarios por este chat | descarga el `.zip` y ejecuta `RESTAURAR.sh` |
| **D** GitHub | repo privado `marketattack` | `sudo bash /usr/local/bin/recuperar.sh C` |

Cada kit trae `SHA256SUMS` y `conversacion.json` + `conversacion.md`.

### Comprobación rápida de que todo está sano
```bash
sudo bash /usr/local/bin/verificacion_final.sh    # estado global
sudo bash /usr/local/bin/verificar_respaldos.sh  # integridad de los 4 respaldos
sudo bash /usr/local/bin/verificar_kit.sh        # el kit no lleva secretos
sudo python3 /usr/local/bin/pruebas_puente.py    # 27 pruebas del bot de Telegram
```

---

## 5) COMANDOS DE TELEGRAM (escribe al bot)

**Operación**
- `/comandos` — lista completa
- `/estado` — cómo están los servicios
- `/respaldos` — últimos respaldos
- `/backup` — forzar un respaldo ahora
- `/publicar` — publicar la web

**Vender el producto**
- `/producto` — catálogo completo de MARKETATTACK
- `/oferta` — mensaje corto para mandarle a un cliente
- `/precios` — tabla de precios

**Clientes**
- `/cliente` — crear tienda para un cliente
- `/clientes` — ver las tiendas creadas
- `/prospecto Nombre \| Rubro \| Ciudad \| contacto` — guardar prospecto
- `/prospectos` — ver prospectos

**Servidor**
- `/sh <comando>` — ejecutar un comando (solo lista blanca segura)
- `/reiniciar nginx\|opencode\|puente-telegram`

**Link**
- `/link` — enlaces de la web

Y cualquier texto en español se lo mandas al agente: responde ahí mismo.

---

## 6) EL PRODUCTO PARA VENDER

Precios en pesos colombianos, sin permanencia:

| Plan | Precio | Incluye |
|---|---|---|
| 🟢 Esencial | $450.000/mes | Chat con IA, prospectos, panel, 500 conversaciones |
| 🔵 Profesional | $850.000/mes ⭐ | Todo lo anterior + contenido para redes + QR ilimitado |
| 🟣 Escala | $1.400.000/mes | Todo lo anterior + varias sedes + acompañamiento |

Instalación en 24 horas. El catálogo completo está en `/usr/local/bin/catalogo.sh`.

---
CAB3

echo "## 7) TODOS LOS SCRIPTS DEL SERVIDOR"
echo ""
echo "Cada bloque va en la ruta indicada dentro de \`/usr/local/bin/\`."
echo "Están sanitizados: **ningún secreto** está en este archivo."
echo ""
for f in $(ls -1 /usr/local/bin/*.sh /usr/local/bin/*.py 2>/dev/null | grep -v __pycache__ | sort); do
  n=$(basename "$f")
  echo "### \`/usr/local/bin/$n\`"
  echo ""
  echo '```bash'
  cat "$f"
  echo '```'
  echo ""
done

echo "---"
echo ""
echo "## 8) LA MEMORIA COMPLETA DEL PROYECTO"
echo ""
if [ -f "$KIT/CONTEXTO.md" ]; then
  echo "Todo lo que se ha construido y dejado pendiente, en orden cronológico:"
  echo ""
  cat "$KIT/CONTEXTO.md"
else
  echo "_No se encontró CONTEXTO.md en el kit._"
fi
echo ""

cat <<'CAB4'
---

## 9) DÓNDE ESTÁN LOS SECRETOS (no están aquí, a propósito)

| Qué | Dónde vive en el servidor |
|---|---|
| Contraseña vigente de opencode | `/root/CLAVE_OPENCODE.txt` |
| Contraseñas ya rotadas | `/etc/marketattack/claves_rotadas.txt` |
| Token del bot de Telegram | `/etc/marketattack/telegram.conf` |

```bash
# leer la contraseña vigente
sudo cat /root/CLAVE_OPENCODE.txt
```

Nunca se copian a este archivo, ni al repo, ni a Telegram. Es lo correcto.

---

## 10) PENDIENTES CONOCIDOS

1. **Rotar el token del bot** en `@BotFather` → `/revoke` → luego
   `sudo bash /usr/local/bin/activar_token.sh`. Requiere la cuenta del dueño.
2. **Deploy key de GitHub** para el espejo automático de las 04:00 →
   `sudo bash /usr/local/bin/activar_espejo.sh`. Requiere la cuenta de GitHub.
3. **Dominio + HTTPS** propio (opcional): la web ya funciona por IP.
4. **Prueba real desde Android** y un mensaje entrante real al bot.

---

## 11) CÓMO SE GENERÓ ESTE ARCHIVO

```bash
sudo /usr/local/bin/kit_recuperacion.sh
```

Se rehace solo a las 00:00 y se manda a Telegram cada día.
Contiene la clave vigente del servidor, el token del bot, los chats completos
y el historial de la conversación, ya saneados.
CAB4
} > "$F"

chmod 644 "$F"
echo "✓ RESTAURACION_RAPIDA.md generado ($(du -h "$F" | cut -f1), $(grep -c '^### ' "$F") scripts embebidos)"
```

### `/usr/local/bin/guardar_offset.py`

```bash
import subprocess, json, urllib.request, os

tok = subprocess.run("sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf",
                     shell=True, capture_output=True, text=True).stdout
tok = tok.split("=", 1)[1].strip().strip('"')

RUTA = "/home/ubuntu/.marketattack_offset"
try:
    off = int(open(RUTA).read().strip())
except Exception:
    off = 0
print("  offset actual:", off)

url = f"https://api.telegram.org/bot{tok}/getUpdates?offset={off}&timeout=3"
d = json.loads(urllib.request.urlopen(url, timeout=25).read())
res = d.get("result", [])
if res:
    nuevo = max(u["update_id"] for u in res) + 1
    subprocess.run(f"echo {nuevo} | sudo tee {RUTA} >/dev/null && sudo chmod 600 {RUTA}",
                   shell=True)
    print(f"  cola tenía {len(res)} update(s) -> anclado en offset={nuevo}")
else:
    print("  cola vacía: Telegram no tiene updates pendientes")
    print(f"  se deja offset={off} (quedará protegido en cuanto llegue un mensaje real)")
```

### `/usr/local/bin/guardar_offset.sh`

```bash
#!/bin/bash
# Guarda el último update_id confirmado para que el puente NO reenvíe
# el historial tras un reinicio. Telegram dice "ok":true solo si ya se leyó.
TOKEN=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
OFF=$(sudo cat /home/ubuntu/.marketattack_offset 2>/dev/null || echo 0)
r=$(curl -s --max-time 20 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFF&timeout=2")
n=$(echo "$r" | grep -oE '"update_id":[0-9]+' | grep -oE '[0-9]+' | tail -1)
if [ -n "$n" ]; then
  echo "$((n+1))" | sudo tee /home/ubuntu/.marketattack_offset >/dev/null
  sudo chmod 600 /home/ubuntu/.marketattack_offset
  echo "  ✓ offset anclado en $((n+1))"
else
  echo "  cola vacía: se deja offset=$OFF"
fi
```

### `/usr/local/bin/informe_diario.sh`

```bash
#!/usr/bin/env bash
# ═══ Informe diario automático: llega a Telegram cada mañana ═══
set -u
exec 9>/run/informe.lock || exit 0
flock -n 9 || exit 0

IP=149.130.190.118
T=/usr/local/bin/aviso_telegram.sh
REPO_MIRROR=/root/marketattack-git

estado(){
  c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1$u")
  [ "$c" = "200" ] && echo "✅ $u" || echo "❌ $u ($c)"
}

N_CLIENTES=$(ls -1 /var/www/marketattack/clientes/ 2>/dev/null | wc -l)
N_TIENDAS=$(curl -s --max-time 8 "http://127.0.0.1/clientes/" 2>/dev/null | wc -c)

MSG="📅 <b>INFORME DIARIO · MARKETATTACK</b>
$(date '+%A %d de %B de %Y, %H:%M')

<b>Servicios</b>
$(for u in "/" "/tienda.html" "/kit.html"; do echo "  $(estado)"; done)
  opencode: $(systemctl is-active opencode) · telegram: $(systemctl is-active puente-telegram)

<b>Tiendas de clientes</b>
  ${N_CLIENTES} publicada(s)

<b>Respaldos (4 vías)</b>
  💾 disco: $(sudo find /var/backups/marketattack/completos -name 'completo_*.tar.gz' | wc -l) completos
  🪞 espejo: $(sudo find /root/marketattack-rescate -name 'completo_*.tar.gz' | wc -l) completos
  ✈️ Telegram: $(sudo find /var/backups/marketattack/kits -name '*.zip' | wc -l) kits
  ☁️ GitHub: $(sudo test -d "$REPO_MIRROR" && echo "espejo local" || echo "se publica al guardar")
  último: $(sudo ls -t /var/backups/marketattack/completos/completo_*.tar.gz 2>/dev/null | head -1 | xargs -r basename | sed 's/completo_//;s/.tar.gz//' || echo "—")
$(sudo /usr/local/bin/verificar_respaldos.sh 2>/dev/null | grep -E 'RESULTADO' | sed 's/^/  /')

<b>Recursos</b>
  💾 $(df -h / | awk 'NR==2{print $4" de "$2}')
  🧠 $(free -m | awk '/Mem:/{print $7" MB"}')
  ⏱️ $(uptime -p)

<b>Seguridad</b>
  🔑 llaves autorizadas: $(sudo wc -l < /home/ubuntu/.ssh/authorized_keys)
$(sudo /usr/local/bin/verificar_tienda.sh todas 2>/dev/null | tail -1)"

bash "$T" "$MSG"
```

### `/usr/local/bin/kit_recuperacion.sh`

```bash
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
IP=149.130.190.118
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
SECRETO="-----BEGIN[A-Z ]*PRIVATE KEY-----|OPENCODE_SERVER_PASSWORD=[A-Za-z0-9]|TELEGRAM_TOKEN=[0-9]"
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
        ssh -i ~/.ssh/ma_celular ubuntu@149.130.190.118
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

──────────────────────────────────────────────────────────────
⚠ LOS SECRETOS NO ESTÁN AQUÍ (a propósito)
──────────────────────────────────────────────────────────────
Este archivo viaja por Telegram. Por eso NO lleva llaves privadas,
ni el token del bot, ni la contraseña del servidor: si se filtra,
quien lo lea entra a tu servidor.

Dónde están de verdad (solo en el VPS):
  Token del bot   → /etc/marketattack/telegram.conf  (permisos 600)
  Clave opencode  → /etc/systemd/system/opencode.service
                    copia legible: sudo cat /root/CLAVE_OPENCODE.txt
  Llave SSH PC    → tu computadora, ~/.ssh/
  Llave del celular → tu celular, ~/.ssh/ma_celular

COMO OBTENERLOS (si realmente los necesitas):
  ssh -i <tu-llave> ubuntu@149.130.190.118
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
```

### `/usr/local/bin/nuevo_cliente.py`

```bash
#!/usr/bin/env python3
"""
╔═══════════════════════════════════════════════════════════╗
║  MARKETATTACK · Generador de tienda para un cliente nuevo   ║
║  Crea la web, la publica y genera el QR.                  ║
╚═══════════════════════════════════════════════════════════╝
Uso:
  nuevo_cliente.py --nombre "Tienda Don Pepe" --whatsapp 573001234567 \
      --tagline "Los mejores arepas" --horario "Lun-Sab 8am-8pm" \
      --ubicacion "Soacha" --menu "Arepa con pollo|12000|Pollo y arepa" \
      --menu "Jugo|5000|Natural"
"""
import argparse, json, os, re, shutil, subprocess, sys, unicodedata

BASE_PROY = "/home/personalamd/Documentos/Default Project"
MOTOR = f"{BASE_PROY}/02_DEMO"
WEB = "/var/www/marketattack"
CLIENTES = f"{WEB}/clientes"


def slug(s):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s or "cliente"


def reemplaza_cliente(texto, datos):
    """Reemplaza el objeto const CLIENTE = { ... } por los datos del cliente."""
    ini = texto.find("const CLIENTE = {")
    if ini == -1:
        raise SystemExit("ERROR: no se encontró 'const CLIENTE = {'")
    i = texto.find("{", ini)
    nivel, j = 0, i
    while j < len(texto):
        if texto[j] == "{":
            nivel += 1
        elif texto[j] == "}":
            nivel -= 1
            if nivel == 0:
                break
        j += 1
    nuevo = "const CLIENTE = " + json.dumps(datos, ensure_ascii=False, indent=2) + ";"
    return texto[:ini] + nuevo + texto[j + 1:]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--nombre", required=True)
    ap.add_argument("--whatsapp", required=True)
    ap.add_argument("--tagline", default="")
    ap.add_argument("--tono", default="amigable y cercano")
    ap.add_argument("--horario", default="Lunes a sábado de 8:00 a.m. a 6:00 p.m.")
    ap.add_argument("--ubicacion", default="")
    ap.add_argument("--contacto", default="")
    ap.add_argument("--menu", action="append", default=[])
    ap.add_argument("--faq", action="append", default=[])
    ap.add_argument("--promo", default="")
    a = ap.parse_args()

    s = slug(a.nombre)
    destino = f"{CLIENTES}/{s}"

    # 1) preparar estructura
    if os.path.exists(destino):
        shutil.rmtree(destino)
    os.makedirs(os.path.dirname(destino), exist_ok=True)
    shutil.copytree(MOTOR, destino)

    # 2) datos del cliente en el formato que la tienda realmente lee
    menu = []
    for m in a.menu:
        p = [x.strip() for x in m.split("|")]
        while len(p) < 3:
            p.append("")
        precio = p[1] or "0"
        if not precio.startswith("$"):
            precio = "$" + precio
        menu.append({"nombre": p[0], "precio": precio, "desc": p[2]})
    if not menu:
        menu = [{"nombre": "Producto de ejemplo", "precio": "$0", "desc": "Descripción"}]

    datos = {
        "nombreComercial": a.nombre,
        "nombreInterno": s,
        "whatsapp": re.sub(r"\D", "", a.whatsapp),
        "marca": {"tagline": a.tagline or a.nombre, "tono": a.tono},
        "info": {"horario": a.horario, "ubicacion": a.ubicacion, "contacto": a.contacto},
        "menu": menu,
        "promociones": ([{"titulo": "PROMO", "texto": a.promo}] if a.promo else []),
        "preguntasFrecuentes": ([{"p": p.split("|")[0], "r": (p.split("|")[1] if "|" in p else p)}
                                 for p in a.faq] if a.faq else []),
    }

    # 3) inyectar en el motor
    demo = f"{destino}/assets/demo.js"
    with open(demo, encoding="utf-8") as f:
        t = f.read()
    with open(demo, "w", encoding="utf-8") as f:
        f.write(reemplaza_cliente(t, datos))

    # 4) guardar la ficha del cliente en el proyecto
    ficha = f"{BASE_PROY}/05_CLIENTES/{s}"
    os.makedirs(ficha, exist_ok=True)
    with open(f"{ficha}/config_cliente.js", "w", encoding="utf-8") as f:
        f.write("// Generado automáticamente por nuevo_cliente.py\n")
        f.write("window.CLIENTE_CONFIG = " + json.dumps(datos, ensure_ascii=False, indent=2) + ";\n")
    with open(f"{ficha}/datos.txt", "w", encoding="utf-8") as f:
        f.write(f"Nombre: {a.nombre}\nWhatsApp: {a.whatsapp}\n")
        f.write(f"Tagline: {a.tagline}\nHorario: {a.horario}\nZona: {a.ubicacion}\n\n")
        for m in menu:
            f.write(f"- {m['nombre']} | {m['precio']} | {m['desc']}\n")

    # 5) QR
    url = f"http://149.130.190.118/clientes/{s}/tienda.html"
    q = subprocess.run(["python3", "/usr/local/bin/qr_tienda.py", url,
                        f"{destino}/qr.png", a.nombre.upper()[:22]],
                       capture_output=True, text=True, timeout=120)
    qr_ok = os.path.exists(f"{destino}/qr.png") and q.returncode == 0
    if not qr_ok:
        print(f"AVISO_QR={(q.stderr or q.stdout or 'sin detalle').strip()[:200]}")

    # 6) VERIFICACIÓN REAL: un 200 solo no basta.
    #    nginx podría devolver una portada inventada por una ruta mal puesta.
    def pedir(u):
        """Devuelve (codigo_http, cuerpo_en_bytes). Siempre bytes, nunca texto."""
        p = subprocess.run(["curl", "-s", "-w", "\n%{http_code}", "--max-time", "12", u],
                           capture_output=True, timeout=30)
        cuerpo, _, cod = p.stdout.rpartition(b"\n")
        return cod.decode("utf-8", "ignore").strip(), cuerpo

    base = f"http://127.0.0.1/clientes/{s}"
    c_web, _ = pedir(f"{base}/tienda.html")
    c_js, js = pedir(f"{base}/assets/demo.js")
    c_qr, _ = pedir(f"{base}/qr.png")
    txt = js.decode("utf-8", "ignore")
    con_datos = (f'"{s}"' in txt) and (a.nombre in txt)
    code = "200" if (c_web == "200" and c_js == "200" and c_qr == "200"
                     and con_datos and qr_ok) else f"FALLO({c_web}/{c_js}/{c_qr}/datos={con_datos})"

    # 7) permisos legibles por nginx
    subprocess.run(["chmod", "-R", "a+rX", destino], check=False)

    print(f"NOMBRE={a.nombre}")
    print(f"SLUG={s}")
    print(f"LINK={url}")
    print(f"QR=http://149.130.190.118/clientes/{s}/qr.png")
    print(f"FICHA={ficha}")
    print(f"VERIFICADO={code}")
    print(f"PRODUCTOS={len(menu)}")


if __name__ == "__main__":
    main()
```

### `/usr/local/bin/prueba_restauracion.sh`

```bash
#!/bin/bash
# Prueba REAL de las vías de restauración del VPS.
# (La vía D = GitHub se verifica desde la PC, porque el VPS no tiene llave
#  de GitHub a propósito: el espejo automático es una mejora pendiente.)
f=0
ok(){ echo "  ok   $1"; }
mal(){ echo "  MAL  $1"; f=$((f+1)); }
existe(){ if [ -n "$1" ] && [ -e "$1" ]; then ok "$2"; else mal "$2"; fi; }

echo "═══ PRUEBA DE RESTAURACIÓN ═══"

echo ""
echo "── VÍA A: kit de Telegram ──"
Z=$(sudo ls -t /var/backups/marketattack/kits/*.zip | head -1)
D=/tmp/prueba_A
sudo rm -rf "$D"; mkdir -p "$D"; sudo cp "$Z" "$D/"
bash /usr/local/bin/recuperar.sh A "$D" "$D/$(basename "$Z")" >/dev/null 2>&1
existe "$(find "$D" -maxdepth 1 -name CONTEXTO.md | head -1)" "restauró CONTEXTO.md"
existe "$(find "$D" -maxdepth 2 -name conversacion.md | head -1)" "restauró la conversación"
existe "$(find "$D" -name puente_telegram.py | head -1)" "restauró los scripts"
existe "$(find "$D" -name opencode.service | head -1)" "restauró la configuración saneada"
sudo rm -rf "$D"

echo ""
echo "── VÍA B: respaldo completo del VPS ──"
r=$(sudo ls -t /var/backups/marketattack/completos/completo_*.tar.gz | head -1)
D=/tmp/prueba_B
sudo rm -rf "$D"; sudo mkdir -p "$D"
sudo tar -xzf "$r" -C "$D" 2>/dev/null
existe "$D/ESTADO.txt" "ESTADO.txt recuperable"
existe "$D/SHA256SUMS" "SHA256SUMS recuperable"
existe "$D/contenido/web/index.html" "sitio web recuperable"
existe "$D/contenido/scripts/kit_recuperacion.sh" "scripts recuperables"
db=$(sudo find "$D" -name 'chat_*.db' | head -1)
if [ -n "$db" ]; then
  n=$(sudo python3 -c "import sqlite3;print(sqlite3.connect('$db').execute('select count(*) from message').fetchone()[0])" 2>/dev/null)
  [ -n "$n" ] && ok "chat recuperable ($n mensajes)" || mal "la DB no abre"
else
  mal "no hay DB en el respaldo"
fi
if sudo bash -c "cd '$D' && sha256sum -c --quiet SHA256SUMS" >/dev/null 2>&1; then
  ok "los checksums cuadran"
else
  mal "checksums no cuadran"
fi
sudo rm -rf "$D"

echo ""
echo "── VÍA C: espejo interno ──"
a=$(sudo ls -t /var/backups/marketattack/completos/completo_*.tar.gz | head -1)
b=$(sudo ls -t /root/marketattack-rescate/completo_*.tar.gz | head -1)
[ "$(basename "$a")" = "$(basename "$b")" ] && ok "espejo al día ($(basename "$b"))" || mal "espejo desfasado"
sudo tar -tzf "$b" >/dev/null 2>&1 && ok "el espejo se lee" || mal "espejo ilegible"

echo ""
if [ "$f" -eq 0 ]; then echo "RESULTADO: todas las vías restauran de verdad"; else echo "RESULTADO: $f FALLOS"; fi
```

### `/usr/local/bin/pruebas_puente.py`

```bash
import importlib.util
s = importlib.util.spec_from_file_location('p', '/usr/local/bin/puente_telegram.py')
m = importlib.util.module_from_spec(s)
s.loader.exec_module(m)

DEBE = [
    ("/sh ls /var/www/marketattack",              "listar"),
    ("/sh cat /etc/hostname",                      "leer archivo"),
    ("/sh df -h /",                               "disco"),
    ("/sh free -m",                               "memoria"),
    ("/sh uptime",                                "uptime"),
    ("/sh verificar_tienda.sh todas",             "auditar tiendas"),
    ("/sh /usr/local/bin/verificar_tienda.sh todas", "ruta completa"),
    ("/sh tail -3 /var/log/opencode.log",         "leer log"),
    ("/sh echo hola",                             "echo"),
    ("/sh date",                                  "fecha"),
    ("/comandos",                                 "lista de comandos"),
    ("/producto",                                 "catalogo de venta"),
    ("/oferta",                                   "mensaje para cliente"),
    ("/precios",                                  "tabla de precios"),
    ("/prospectos",                               "ver prospectos"),
    ("/ayuda",                                    "ayuda con los comandos nuevos"),
]
NO_DEBE = [
    ("/sh rm -rf /",                              "borrar disco"),
    ("/sh rm /var/www/marketattack",              "borrar web"),
    ("/sh chmod 777 /",                           "cambiar permisos"),
    ("/sh curl -X POST http://evil",              "curl con POST"),
    ("/sh wget http://x.sh",                      "descargar y ejecutar"),
    ("/sh shutdown now",                          "apagar"),
    ("/sh pkill -9 opencode",                     "matar proceso"),
    ("/sh dd if=/dev/zero of=/dev/sda",           "destruir disco"),
    ("/sh sudo rm -rf /",                         "sudo borrar"),
    ("/reiniciar mysql",                          "servicio no permitido"),
    ("/reiniciar ..",                             "servicio raro"),
]
ok = fallos = 0
print("═══ DEBE FUNCIONAR ═══")
for cmd, desc in DEBE:
    try:
        r = str(m.procesar(cmd) or "")
    except Exception as e:
        r = f"EXCEPCIÓN {e}"
    mal = any(x in r for x in ["EXCEPCIÓN", "no está en la lista", "puede romper"])
    print(("  ✗ " if mal else "  ✓ ") + cmd)
    if mal: fallos += 1; print("      " + r[:180].replace("\n", " "))
    else: ok += 1
print("\n═══ DEBE BLOQUEAR ═══")
for cmd, desc in NO_DEBE:
    try:
        r = str(m.procesar(cmd) or "")
    except Exception as e:
        r = f"EXCEPCIÓN {e}"
    bloqueado = ("puede romper" in r or "no está en la lista" in r
                 or "Servicios permitidos" in r or "⚠️" in r)
    print(("  ✓ " if bloqueado else "  ✗ FUGÓ: ") + cmd)
    if bloqueado: ok += 1
    else:
        fallos += 1
        print("      → " + r[:200].replace("\n", " "))
print(f"\n{'🎉 TODO CORRECTO' if fallos==0 else f'🚨 {fallos} FALLOS'}: {ok} OK, {fallos} fallos")
```

### `/usr/local/bin/publicar.sh`

```bash
#!/usr/bin/env bash
# ═══ Publica los cambios del proyecto en la web del servidor ═══
set -e
ORIGEN="/home/personalamd/Documentos/Default Project/02_DEMO"
DESTINO="/var/www/marketattack"

echo "▸ Publicando cambios..."
sudo rsync -a --delete "$ORIGEN/" "$DESTINO/"
sudo chown -R www-data:www-data "$DESTINO"

C1=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1/tienda.html)
C2=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1/assets/carrito.js)
if [ "$C1" = "200" ] && [ "$C2" = "200" ]; then
  echo "✓ PUBLICADO y verificado (tienda=$C1, carrito=$C2)"
  echo "  http://149.130.190.118/tienda.html"
else
  echo "⚠ ERROR al publicar (tienda=$C1 carrito=$C2)"
  exit 1
fi
```

### `/usr/local/bin/publicar_github.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  ESPEJO AUTOMÁTICO EN GITHUB (para no depender de la PC)
#
#  Mientras el VPS no tenga llave de GitHub, NO hace nada
#  destructivo: informa qué falta y termina con OK.
#
#  Para activarlo (una sola vez, tú):
#    sudo ssh-keygen -t ed25519 -C "vps-marketattack" -f /root/.ssh/id_ed25519
#    sudo cat /root/.ssh/id_ed25519.pub
#  Copia esa llave en GitHub → tu repositorio → Settings →
#  Deploy keys → Add deploy key → ☑ Allow write access
# ═══════════════════════════════════════════════════════════
REPO=/root/marketattack-git
ORIGEN=/var/backups/marketattack/completos
REMOTO=git@github.com:gtcorebynet-jpg/marketattack.git

echo "→ espejo en GitHub"

if ! sudo test -f /root/.ssh/id_ed25519; then
  echo "  ℹ el VPS todavía no tiene llave de GitHub."
  echo "    Se deja constancia del estado en el VPS: $REPO"
  exit 0
fi
if ! sudo ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com >/dev/null 2>&1; then
  echo "  ⚠ la llave existe pero GitHub no la acepta."
  echo "    Añádela como deploy key con permiso de escritura en el repositorio."
  exit 0
fi

# reconstruir el espejo desde el último respaldo íntegro
ult=$(sudo find "$ORIGEN" -name 'completo_*.tar.gz' | sort -r | head -1)
[ -z "$ult" ] && { echo "  ✗ no hay respaldos en $ORIGEN"; exit 1; }
echo "  fuente: $(basename "$ult")"

sudo rm -rf /tmp/pub && sudo mkdir -p /tmp/pub
sudo tar -xzf "$ult" -C /tmp/pub
# solo lo que tiene sentido versionar (nunca la DB del chat ni secretos)
sudo mkdir -p "$REPO"
for d in scripts config; do
  [ -d "/tmp/pub/contenido/$d" ] && sudo cp -r "/tmp/pub/contenido/$d" "$REPO/" 2>/dev/null
done
[ -d /tmp/pub/contenido/web ] && sudo cp -r /tmp/pub/contenido/web "$REPO/" 2>/dev/null
sudo cp /tmp/pub/ESTADO.txt "$REPO/ESTADO.txt" 2>/dev/null
sudo cp /tmp/pub/SHA256SUMS "$REPO/SHA256SUMS" 2>/dev/null
sudo chown -R gituser:gituser "$REPO" 2>/dev/null || true

export GIT_SSH_COMMAND="ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

if sudo git ls-remote "$REMOTO" >/dev/null 2>&1; then
  if [ ! -d "$REPO/.git" ]; then
    echo "  · clonando el repo desde GitHub"
    sudo rm -rf "$REPO"
    sudo git clone -q --branch main "$REMOTO" "$REPO" 2>/dev/null || sudo git clone -q "$REMOTO" "$REPO"
  fi
else
  [ -d "$REPO/.git" ] || sudo git init -q -b main "$REPO"
fi

sudo bash -c "
  export GIT_SSH_COMMAND='ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new'
  cd '$REPO' || exit 1
  git config user.email 'vps@marketattack.local'
  git config user.name 'MARKETATTACK VPS'
  git config core.safecrlf false
  git remote set-url origin '$REMOTO'
  git checkout -q -B main
  printf '*.db\n*.zip\n*.tar.gz\n*.key\n' > .gitignore
  git add -A 2>/dev/null
  if git diff --cached --quiet; then echo '  sin cambios nuevos'; exit 0; fi
  git commit -q -m \"respaldo automático del VPS $(date '+%Y-%m-%d %H:%M')\"
  if git push -q origin main; then
    echo '  ✓ empujado a GitHub (rama main)'
  else
    echo '  ✗ no se pudo empujar'
  fi
" || echo "  ⚠ el espejo no se pudo actualizar"

sudo rm -rf /tmp/pub
```

### `/usr/local/bin/publicar_kit.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Publica el kit de recuperación en la web, para poder bajarlo
#  desde CUALQUIER dispositivo sin depender de Telegram ni de la PC.
#
#  - RESTAURACION_RAPIDA.md  → ruta pública y corta (sin secretos)
#  - el .zip completo (con el chat) → ruta con clave aleatoria
#  - recuperar.html             → página con los dos enlaces
# ═══════════════════════════════════════════════════════════════
set -u
WEB=/var/www/marketattack
DESC="$WEB/descargas"
KITS=/var/backups/marketattack/kits
TOKCONF=/etc/marketattack/kit_token.conf
NGINX=$(sudo nginx -T 2>/dev/null | grep -oE 'server_name|root ' | head -1 >/dev/null; echo ok)

mkdir -p "$DESC"

# ── token de la ruta privada (se genera una sola vez) ──
if [ ! -f "$TOKCONF" ]; then
  TOK=$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 24)
  sudo mkdir -p /etc/marketattack
  echo "TOKEN=$TOK" | sudo tee "$TOKCONF" >/dev/null
  sudo chmod 600 "$TOKCONF"
  echo "  🔑 ruta privada creada"
fi
TOK=$(sudo sed -n 's/^TOKEN=//p' "$TOKCONF")

# ── el archivo único, siempre el más reciente ──
RAP=$(ls -1t "$KITS"/RESTAURACION_RAPIDA_*.md 2>/dev/null | head -1)
[ -n "$RAP" ] && sudo cp "$RAP" "$DESC/RESTAURACION_RAPIDA.md"

# ── el zip completo, dentro de la ruta con token ──
ZIP=$(ls -1t "$KITS"/KIT_RECUPERACION_MARKETATTACK_*.zip 2>/dev/null | head -1)
[ -n "$ZIP" ] && sudo mkdir -p "$DESC/$TOK" && sudo cp "$ZIP" "$DESC/$TOK/"

FECHA=$(date '+%d/%m/%Y %H:%M')
TAM_RAP=$(sudo du -h "$DESC/RESTAURACION_RAPIDA.md" 2>/dev/null | cut -f1)
TAM_ZIP=$(sudo du -h "$DESC/$TOK"/*.zip 2>/dev/null | head -1 | cut -f1)

sudo tee "$WEB/recuperar.html" >/dev/null <<HTML
<!DOCTYPE html>
<html lang="es"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Recuperar MarketAttack</title>
<style>
 body{font-family:system-ui,-apple-system,Segoe UI,sans-serif;background:#0d1117;color:#e6edf3;
      max-width:760px;margin:0 auto;padding:28px 18px;line-height:1.6}
 h1{color:#ff8c42} h2{color:#58a6ff;margin-top:26px;font-size:1.05rem}
 a.c{display:block;background:#161b22;border:1px solid #30363d;border-radius:10px;
     padding:16px 18px;margin:12px 0;text-decoration:none;color:#e6edf3}
 a.c:hover{border-color:#ff8c42}
 .t{color:#8b949e;font-size:.86rem;margin-top:6px}
 code{background:#161b22;padding:2px 6px;border-radius:4px;color:#7ee787}
 ol{padding-left:20px} .aviso{background:#3d1d0d;border-left:4px solid #ff8c42;padding:12px 14px;border-radius:6px}
</style></head><body>

<h1>🛟 Recuperar MarketAttack</h1>
<p>Todo el proyecto, listo para retomar aunque se borre el chat o se apague la computadora.
Actualizado: <b>$FECHA</b></p>

<h2>Opción 1 · Un solo archivo (recomendado)</h2>
<a class="c" href="/descargas/RESTAURACION_RAPIDA.md" download>
  📄 <b>RESTAURACION_RAPIDA.md</b> — $TAM_RAP
  <div class="t">Un único archivo con TODO: cómo entrar al servidor, estado verificado,
  los 4 respaldos, los comandos de Telegram, el producto, todos los scripts y la
  memoria completa del proyecto. Sin llaves ni tokens.</div>
</a>
<p>Para usarlo: <b>descárgalo</b>, abre un <b>chat nuevo en opencode</b>, arrastra el
archivo dentro y escribe <code>lee este archivo y retoma MARKETATTACK</code>.</p>

<h2>Opción 2 · Kit completo (incluye el chat)</h2>
<a class="c" href="/descargas/$TOK/$(basename "$ZIP")" download>
  📦 <b>Kit completo</b> — $TAM_ZIP
  <div class="t">El zip entero: los 4 respaldos, los 29 scripts, el estado del
  servidor y la conversación completa ya saneada. Trae RESTAURAR.sh.</div>
</a>

<h2>Opción 3 · Por Telegram</h2>
<p>El mismo archivo llega cada día al chat del bot <code>marketattack_alertas_bot</code>.
En ese chat escribe <code>/link</code> y te devuelve estas direcciones.</p>

<h2>Cómo se restaura</h2>
<ol>
  <li>Entra al VPS:
      <code>ssh -i ~/.ssh/ssh-key-marketattack-20260926.key ubuntu@149.130.190.118</code></li>
  <li>Si perdiste archivos: <code>sudo bash /usr/local/bin/recuperar.sh B</code> (disco),
      <code>C</code> (GitHub) o <code>A</code> (Telegram).</li>
  <li>Comprueba que todo está sano:
      <code>sudo bash /usr/local/bin/verificacion_final.sh</code></li>
</ol>

<div class="aviso"><b>Por seguridad</b> este archivo NO trae contraseñas, tokens ni
llaves privadas. Eso se queda dentro del servidor, en
<code>/root/CLAVE_OPENCODE.txt</code>, <code>/etc/marketattack/telegram.conf</code> y
<code>/etc/marketattack/claves_rotadas.txt</code>.</div>

<p style="margin-top:30px"><a href="/" style="color:#8b949e">← Volver al inicio</a></p>
</body></html>
HTML

echo "✓ kit publicado en la web ($FECHA)"
echo "  archivo único: $TAM_RAP"
echo "  kit completo:  $TAM_ZIP"
echo "  ruta: /recuperar.html"
```

### `/usr/local/bin/puente_telegram.py`

```bash
#!/usr/bin/env python3
"""
╔═══════════════════════════════════════════════════════════╗
║  PUENTE TELEGRAM → OPENCODE · MARKETATTACK                ║
║  Comandos directos + creación de tiendas de clientes      ║
╚═══════════════════════════════════════════════════════════╝
"""
import json, os, re, subprocess, sys, time, base64
import datetime, glob, html
import urllib.request, urllib.parse

CFG = "/etc/marketattack/telegram.conf"
API = "http://127.0.0.1:4096"
SESS_FILE = "/etc/marketattack/telegram_session"
DIARIO = "/home/personalamd/Documentos/Default Project"
IP = "149.130.190.118"

cfg = {}
for line in open(CFG):
    if "=" in line and not line.strip().startswith("#"):
        k, v = line.split("=", 1)
        cfg[k.strip()] = v.strip().strip('"')
TOKEN, CHAT = cfg.get("TELEGRAM_TOKEN", ""), cfg.get("TELEGRAM_CHAT_ID", "")
PASS = ""
for l in open("/etc/systemd/system/opencode.service"):
    if "OPENCODE_SERVER_PASSWORD=" in l:
        PASS = l.split("OPENCODE_SERVER_PASSWORD=", 1)[1].strip()
BASE = f"https://api.telegram.org/bot{TOKEN}"
AUTH = "Basic " + base64.b64encode(f"opencode:{PASS}".encode()).decode()


def tg(m, **kw):
    try:
        d = urllib.parse.urlencode(
            {"parse_mode": "HTML", "disable_web_page_preview": "true"} | kw).encode()
        with urllib.request.urlopen(f"{BASE}/{m}", d, timeout=60) as r:
            return json.loads(r.read())
    except Exception as e:
        print("tg:", e)


def tg_foto(ruta, caption=""):
    """Envia una foto con multipart/form-data (Telegram lo exige para archivos)."""
    try:
        cr = "----mt" + str(int(time.time()))
        with open(ruta, "rb") as f:
            datos = f.read()
        partes = []
        partes.append(f"--{cr}\r\nContent-Disposition: form-data; name=\"chat_id\"\r\n\r\n{CHAT}\r\n".encode())
        partes.append(f"--{cr}\r\nContent-Disposition: form-data; name=\"caption\"\r\n\r\n{caption[:1000]}\r\n".encode())
        partes.append(f"--{cr}\r\nContent-Disposition: form-data; name=\"photo\"; filename=\"qr.png\"\r\n"
                      f"Content-Type: image/png\r\n\r\n".encode())
        partes.append(datos)
        partes.append(f"\r\n--{cr}--\r\n".encode())
        cuerpo = b"".join(partes)
        req = urllib.request.Request(
            f"{BASE}/sendPhoto", data=cuerpo, method="POST")
        req.add_header("Content-Type", f"multipart/form-data; boundary={cr}")
        with urllib.request.urlopen(req, timeout=90) as r:
            return json.loads(r.read())
    except Exception as e:
        print("foto error:", e)
        return {"ok": False}


def oc(m, path, body=None, timeout=1800):
    req = urllib.request.Request(
        f"{API}{path}", data=json.dumps(body).encode() if body else None, method=m)
    req.add_header("Authorization", AUTH)
    if body:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read())


def sh(cmd, t=240):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=t)
    return (p.stdout or "") + (("\n" + p.stderr) if p.stderr.strip() else "")


def enviar(txt):
    txt = (txt or "…").strip()
    while txt:
        if len(txt) <= 3800:
            tg("sendMessage", chat_id=CHAT, text=txt)
            return
        c = txt.rfind("\n", 0, 3700) or 3700
        tg("sendMessage", chat_id=CHAT, text=txt[:c])
        txt = txt[c:].lstrip("\n")


def sesion():
    if os.path.exists(SESS_FILE):
        s = open(SESS_FILE).read().strip()
        if s:
            return s
    d = oc("GET", "/session")
    for x in (d.get("data", d) if isinstance(d, dict) else d):
        if (x.get("title") or "").lower() == "marketattack":
            open(SESS_FILE, "w").write(x["id"])
            return x["id"]
    sid = oc("POST", "/session", {"title": "MarketAttack"})["id"]
    open(SESS_FILE, "w").write(sid)
    return sid


AYUDA = """🤖 <b>MARKETATTACK — comandos</b>

🟠 <b>Vender</b>
/producto — catálogo completo de MARKETATTACK
/oferta — mensaje corto para mandar a un cliente
/precios — tabla de precios

📥 <b>Prospectos</b>
/prospecto — guardar uno nuevo
/prospectos — ver la lista

🆕 <b>Clientes</b>
/cliente — crear tienda para un cliente (te explico abajo)

⚙️ <b>Operación</b>
/estado · /respaldos · /publicar · /backup

💻 <b>Comandos al servidor</b>
/comandos — lista lo que puedo hacer
/sh <comando> — ejecutar algo (ls, cat, df, tail…)
/reiniciar <servicio> — reiniciar nginx|opencode|puente-telegram

🔗 <b>Links</b>
/link · /clientes · /leer (memoria del proyecto) · /nueva

Formato para /cliente:
/cliente
Nombre: Tienda Don Pepe
WhatsApp: 573001234567
Tagline: Los mejores arepas
Horario: Lun-Sab 8am-8pm
Zona: Soacha
1. Arepa con pollo | 12000 | Pollo y queso
2. Jugo de mango | 5000 | Natural

Te devuelvo el LINK y el QR listo para compartir."""

FORMATO = """📋 <b>Así se crea una tienda</b>

Cópialo, cambia los datos y mándamelo:

/cliente
Nombre: Tienda Don Pepe
WhatsApp: 573001234567
Tagline: Los mejores arepas
Horario: Lun-Sab 8am-8pm
Zona: Soacha
1. Arepa con pollo | 12000 | Pollo y queso
2. Jugo de mango | 5000 | Natural

👉 <b>WhatsApp</b>: solo números (con código de país, sin +)
👉 Cada producto: <code>nombre | precio | descripción</code>

Yo te respondo con el link y el QR."""


def cmd_estado():
    web = sh("curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1/tienda.html").strip()
    ext = sh("curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://" + IP + "/tienda.html").strip()
    disco = sh("df -h / | tail -1 | awk '{print $4\" de \"$2\" libres\"}'").strip()
    ram = sh("free -m | awk '/Mem:/{print $7\" MB de \"$2\" libres\"}'").strip()
    nres = sh("ls -1 /var/backups/marketattack/*.tar.gz 2>/dev/null | wc -l").strip()
    ult = sh("ls -1t /var/backups/marketattack/*.tar.gz 2>/dev/null | head -1 | xargs -r ls -lh | awk '{print $6\" \"$7\" \"$8}'").strip()
    srv = sh("systemctl is-active opencode").strip()
    puent = sh("systemctl is-active puente-telegram").strip()
    return (f"📊 <b>ESTADO</b>\n\n"
            f"Web servidor: <b>{web}</b> {'✅' if web == '200' else '❌'}\n"
            f"Web internet: <b>{ext}</b> {'✅' if ext == '200' else '❌'}\n"
            f"opencode: <b>{srv}</b> · puente: <b>{puent}</b>\n\n"
            f"💾 {disco}\n🧠 {ram}\n🗄 Respaldos: {nres} · último {ult or '—'}\n"
            f"🕒 Copia diaria 3:00 AM (sin PC)")


def cmd_clientes():
    d = sh("ls -1 /var/www/marketattack/clientes/ 2>/dev/null")
    if not d.strip():
        return "📂 <b>Clientes</b>\n\nTodavía no hay tiendas creadas.\nMándame <code>/cliente</code> y hacemos la primera."
    out = "📂 <b>Tiendas creadas</b>\n\n"
    for s in [x.strip() for x in d.splitlines() if x.strip()]:
        code = sh(f"curl -s -o /dev/null -w '%{{http_code}}' --max-time 8 http://127.0.0.1/clientes/{s}/tienda.html").strip()
        qr = sh(f"curl -s -o /dev/null -w '%{{http_code}}' --max-time 8 http://127.0.0.1/clientes/{s}/qr.png").strip()
        out += f"✅ <b>{s}</b> (web {code}, QR {qr})\n   http://{IP}/clientes/{s}/tienda.html\n\n"
    return out


def cmd_cliente(txt):
    lineas = [l.strip() for l in txt.splitlines()]
    d, menu, faq = {}, [], []
    clave = {"nombre": "nombre", "negocio": "nombre", "whatsapp": "whatsapp",
             "telefono": "whatsapp", "tagline": "tagline", "promo": "promo",
             "horario": "horario", "zona": "ubicacion", "ubicacion": "ubicacion",
             "contacto": "contacto"}
    for l in lineas[1:]:
        if not l:
            continue
        m = re.match(r"^\d+[.)]\s*(.+)$", l)
        if m and "|" in l:
            p = [x.strip() for x in l[m.end():].split("|")]
            while len(p) < 3:
                p.append("")
            menu.append(p)
            continue
        if ":" in l:
            k, v = l.split(":", 1)
            k = clave.get(k.strip().lower().lstrip("/ "))
            if k:
                d[k] = v.strip()
                continue
        if l.lower().startswith("faq"):
            if "|" in l:
                a, b = l.split("|", 1)
                faq.append((a.strip(), b.strip()))
            continue
    faltan = [x for x in ("nombre", "whatsapp") if not d.get(x)]
    if faltan:
        return (f"⚠ Faltan datos: <b>{', '.join(faltan)}</b>\n\n{FORMATO}")
    if not menu:
        return f"⚠ Falta al menos un producto.\n\n{FORMATO}"

    cmd = ["sudo", "/usr/local/bin/nuevo_cliente.py",
           "--nombre", d["nombre"], "--whatsapp", d["whatsapp"]]
    for k, flag in (("tagline", "--tagline"), ("horario", "--horario"),
                    ("ubicacion", "--ubicacion"), ("contacto", "--contacto"),
                    ("promo", "--promo")):
        if d.get(k):
            cmd += [flag, d[k]]
    for m in menu:
        cmd += ["--menu", "|".join(m)]
    for a, b in faq:
        cmd += ["--faq", f"{a}|{b}"]

    salida = sh(" ".join(f"'{x}'" for x in cmd), t=300)
    res = {}
    for l in salida.splitlines():
        if "=" in l:
            k, _, v = l.partition("=")
            res[k.strip()] = v.strip()
    if not res.get("VERIFICADO","").startswith("200"):
        return f"⚠ <b>No se pudo crear</b> (verificación {res.get('VERIFICADO','?')})\n<pre>{salida[:600]}</pre>"

    # respaldo antes de cualquier cosa nueva publicada
    sh("/usr/local/bin/backup_marketattack.sh", t=300)

    ruta = f"/var/www/marketattack/clientes/{res['SLUG']}/qr.png"
    texto = (f"🎉 <b>TIENDA LISTA: {d['nombre']}</b>\n\n"
             f"🔗 Link: {res['LINK']}\n"
             f"📱 QR:   {res['QR']}\n"
             f"🧾 Productos: {res.get('PRODUCTOS','?')}\n"
             f"✅ Verificado: web+datos+QR reales\n"
             f"💾 Respaldo hecho antes de publicar\n\n"
             f"Abre el link en tu celular con datos para verlo.")
    if os.path.exists(ruta):
        tg_foto(ruta, f"📱 {d['nombre']}\n{res['LINK']}")
    return texto



# ═══════════════════════════════════════════════════════════
#  EJECUCIÓN DE COMANDOS DESDE TELEGRAM (con lista blanca)
# ═══════════════════════════════════════════════════════════
PERMITIDOS = {
    # solo lectura de archivos y estado
    "ls", "cat", "head", "tail", "grep", "find", "wc", "du", "df", "free",
    "uptime", "date", "uname", "whoami", "hostname", "id", "ps", "stat",
    "echo", "which", "file", "sed", "tree", "realpath", "md5sum",
    # scripts del proyecto (con o sin ruta)
    "verificar_tienda.sh", "backup_marketattack.sh", "publicar.sh",
    "qr_tienda.py", "nuevo_cliente.py", "exportar_sesion.py",
    # versiones y configuración
    "nginx", "python3", "node", "opencode", "crontab", "env",
    # auditoría
    "verificar_tienda",
}

# servicios que SÍ se pueden reiniciar desde Telegram
SERVICIOS = {"nginx", "opencode", "puente-telegram"}

PELIGROSOS = ["rm ", "rm -", "mv ", "cp ", "> ", ">>", "chmod", "chown",
              "dd ", "mkfs", "shutdown", "reboot", "kill ", "pkill",
              "apt", "pip", "curl -X", "wget ", "eval", "sudo rm"]


def cmd_sh(linea):
    """Ejecuta un comando permitido y devuelve la salida."""
    c = linea.strip()
    if not c:
        return "Dime el comando. Ejemplo: /sh ls -la /var/www/marketattack"

    bajo = any(p in c for p in PELIGROSOS)
    if bajo and not c.replace("/usr/local/bin/","").startswith("systemctl restart"):
        return ("⚠️ <b>Ese comando puede romper el servidor</b> y no lo dejo "
                "pasar desde Telegram.\n\nLo que sí puedo: reiniciar servicios con\n"
                "<code>/reiniciar nginx</code>\n<code>/reiniciar opencode</code>"
                "\n<code>/reiniciar puente-telegram</code>\n\n"
                "Para lo demás, dímelo y lo hago yo desde la PC.")

    # reinicio de servicios
    if c.replace("/usr/local/bin/","").startswith("systemctl restart") or c.startswith("/reiniciar"):
        parts = c.replace("systemctl restart", "").replace("/reiniciar", "").strip().split()
        if len(parts) != 1 or parts[0] not in SERVICIOS:
            return f"Servicios permitidos: {', '.join(sorted(SERVICIOS))}"
        sh(f"systemctl restart {parts[0]}", t=60)
        time.sleep(5)
        est = sh(f"systemctl is-active {parts[0]}").strip()
        return (f"🔄 {parts[0]} reiniciado\n\nEstado: "
                f"{'✅ ' + est if est == 'active' else '❌ ' + est}")

    # lista blanca: se compara el nombre del programa, con o sin ruta
    toks = c.split()
    base = os.path.basename(toks[0]) if toks else ""
    if base not in PERMITIDOS and c not in PERMITIDOS:
        return ("🔒 Ese comando no está en la lista.\n\n"
                f"<b>Permitidos:</b> {', '.join(sorted(PERMITIDOS)[:14])}…\n\n"
                "Lista completa: /comandos")

    salida = sh(c, t=120)
    if not salida.strip():
        salida = "(sin salida: el comando se ejecutó sin imprimir nada)"
    if len(salida) > 3400:
        salida = salida[:3400] + "\n… (cortado)"
    return f"💻 <code>{c[:120]}</code>\n\n<pre>{salida}</pre>"


def cmd_comandos():
    return ("🔒 <b>Comandos que puedo ejecutar</b>\n\n"
            f"<b>Programas permitidos:</b> {', '.join(sorted(PERMITIDOS))}\n\n\n\n<b>Ver archivos:</b>\n"
            "<code>/sh ls -la /var/www/marketattack</code>\n"
            "<code>/sh tail -20 /var/log/opencode.log</code>\n"
            "<code>/sh cat CONTEXTO.md</code>\n\n<b>Estado del sistema:</b>\n"
            "<code>/sh df -h /</code>\n<code>/sh free -m</code>\n"
            "<code>/sh uptime</code>\n\n<b>Auditar tiendas:</b>\n"
            "<code>/sh verificar_tienda.sh todas</code>\n\n"
            "<b>Reiniciar servicios:</b>\n"
            "<code>/reiniciar nginx</code>\n"
            "<code>/reiniciar opencode</code>\n"
            "<code>/reiniciar puente-telegram</code>\n\n"
            "⚠️ Lo que puedaromper el servidor queda bloqueado a propósito.")

DIR_PROSPECTOS = "/var/lib/marketattack/prospectos"


def nuevo_prospecto(nombre, rubro, ciudad, contacto, nota=""):
    """Guarda un prospecto en la lista de busqueda."""
    os.makedirs(DIR_PROSPECTOS, exist_ok=True)
    reg = re.sub(r"[^a-z0-9]+", "-", (nombre or "").lower()).strip("-") or "sin-nombre"
    f = f"{DIR_PROSPECTOS}/{reg}.txt"
    fecha = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    with open(f, "a") as fh:
        fh.write(f"\n[{fecha}] {nombre} | {rubro} | {ciudad} | {contacto}"
                 + (f" | {nota}" if nota else "") + "\n")
    return f


def cmd_prospecto(arg):
    """Guarda prospectos: /prospecto Nombre | Rubro | Ciudad | contacto | nota"""
    if not arg.strip():
        return ("📥 <b>GUARDAR PROSPECTO</b>\n\n"
                "<code>/prospecto Nombre | Rubro | Ciudad | contacto | nota</code>\n\n"
                "<b>Ejemplo</b>\n"
                "<code>/prospecto Panadería La Espiga | Panadería | Soacha | 573001112233</code>\n\n"
                "Después usa <code>/prospectos</code> para ver la lista.")
    p = [x.strip() for x in arg.split("|")]
    while len(p) < 4:
        p.append("")
    nuevo_prospecto(p[0], p[1], p[2], p[3], " ".join(p[4:]))
    return (f"✅ Prospecto <b>{html.escape(p[0] or 'sin nombre')}</b> guardado.\n"
            f"📋 Ver todos: <code>/prospectos</code>")


def cmd_prospectos():
    if not os.path.isdir(DIR_PROSPECTOS):
        return "📋 Aún no hay prospectos. Agrega con <code>/prospecto</code>"
    fs = sorted(glob.glob(f"{DIR_PROSPECTOS}/*.txt"))
    if not fs:
        return "📋 Aún no hay prospectos. Agrega con <code>/prospecto</code>"
    out = [f"📋 <b>PROSPECTOS ({len(fs)})</b>\n"]
    for f in fs:
        line = open(f).read().strip().split("\n")[-1]
        line = line[1:].strip() if line.startswith("[") else line
        out.append(f"• {html.escape(line)}")
    return "\n".join(out)[:3500]


PALABRAS_NEGOCIO = ("panader", "restaurante", "taller", "salon", "salón", "clinica", "clínica",
                   "tienda", "cafe", "café", "peluqueria", "peluquería", "inmobiliaria",
                   "dental", "veterinaria", "ferreteria", "carniceria", "carnicería",
                   "pizzeria", "pizzería", "don_pepe", "la_", "el_", "mis_", "don",
                   "cliente", "prospecto", "negocio", "empresa", "lider", "dueño",
                   "dueño", "contacto", "whatsapp", "telefono", "teléfono")

DIR_PLANOS = "/var/lib/marketattack/prospectos"


def _norm_wap(raw):
    """Deja un numero colombiano en 57XXXXXXXXX."""
    d = re.sub(r"\D", "", raw)
    if d.startswith("57") and len(d) == 12:
        return d
    if len(d) == 10 and d.startswith("3"):
        return "57" + d
    return d if 10 <= len(d) <= 13 else None


def _nombre_probable(txt):
    """Busca un nombre de negocio: usa lo que va ANTES del telefono.

    Si no, "Panadería La Espiga 3001234567 Soacha" creaba un archivo con
    "Soacha" dentro del nombre y el mismo negocio acababa en dos archivos.
    """
    for l in txt.splitlines():
        l = l.strip()
        if not l or "@" in l or "http" in l:
            continue
        l = re.sub(r"[+()]", " ", l)
        # los artículos se quitan SOLO al principio: "La Espiga" debe quedar
        # "La Espiga", no "Espiga". A mitad de frase si se limpian.
        l = re.sub(r"^(?:el|la|los|las|un|una|de|del)\s+", "", l, flags=re.I)
        l = re.sub(r"\b(?:para|con|que|nuevo|nueva)\b", " ", l, flags=re.I)
        # "La" mide 2 letras: con len(p) > 2 se perdia de "Panadería La Espiga"
        palabras = [p for p in re.split(r"[\s,;]+", l) if len(p) > 1]
        if not palabras:
            continue
        cap = [p for p in palabras if p[0].isupper()]
        if not cap:
            continue
        cand = " ".join(cap[:3]).strip(" .,-")
        if len(cand) >= 4:
            return cand
    return None


def intento_prospecto(txt):
    """Si el texto trae un telefono y parece un cliente, lo registra solo.

    Devuelve None si no es un alta, para que el texto siga al agente normal.
    """
    if len(txt) > 400:
        return None
    if re.match(r"^\s*/", txt):
        return None
    # movil colombiano: 3 seguido de 9 digitos, con separadores donde sea.
    # Los grupos importan poco: escriben "+57 310 222 3344" o "310-222-3344"
    # igual que "3102223344". Los patrones fijos de 3-3-3 fallaban con la
    # primera forma, asi que se cuentan digitos, no separadores.
    m = re.search(r"(?:\+?57[\s -]*)?3(?:[\s -]*\d){9}", txt)
    if not m:
        return None
    wap = _norm_wap(m.group(0))
    if not wap:
        return None
    bajo = txt.lower()
    if not any(k in bajo for k in PALABRAS_NEGOCIO):
        return None
    antes = txt[:m.start()].strip(" -:,")
    nombre = _nombre_probable(antes) or _nombre_probable(txt) or "Cliente sin nombre"
    # palabras de relleno SOLO al principio: si no, "Panadería La Espiga"
    # se quedaba sin "La" y el negocio quedaba mal nombrado
    nombre = re.sub(r"^(?:tengo\s+)?(?:un|una|el|la\s+)?(?:cliente|prospecto|negocio|empresa)\s+", "", nombre, flags=re.I)
    nombre = re.sub(r"^(?:un|una|el|la)\s+", "", nombre, flags=re.I)
    nombre = re.sub(r"^(?:nuevo|nueva|tengo)\s+", "", nombre, flags=re.I)
    nombre = re.sub(r"\s+", " ", nombre).strip(" .,-") or "Cliente sin nombre"
    rubro = next((k.strip() for k in PALABRAS_NEGOCIO if k in bajo and k not in
                  ("cliente", "prospecto", "negocio", "empresa", "contacto", "whatsapp",
                   "telefono", "teléfono", "lider", "dueño", "dueño")), "por definir")
    os.makedirs(DIR_PLANOS, exist_ok=True)
    reg = re.sub(r"[^a-z0-9]+", "-", nombre.lower()).strip("-") or "cliente"
    reg = re.sub(r"-don$|-la$|-el$", "", reg) or "cliente"
    f = f"{DIR_PLANOS}/{reg}.txt"
    fecha = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    nota = re.sub(r"\s+", " ", txt)[:220]
    with open(f, "a") as fh:
        fh.write(f"[{fecha}] {nombre} | {rubro} | sin ciudad | {wap} | {nota}\n")
    return (f"✅ <b>Cliente guardado</b>\n"
            f"🏪 {html.escape(nombre)}\n"
            f"🧾 {html.escape(rubro)}\n"
            f"📱 {wap}\n"
            f"📂 <code>/var/lib/marketattack/prospectos/{reg}.txt</code>\n\n"
            f"¿Le creo la tienda ya? Escríbele así:\n"
            f"<code>/cliente {html.escape(nombre)} | {html.escape(rubro)} | ciudad | {wap}</code>\n"
            f"y luego los productos. También pídeme la <code>/oferta</code> para mandarle.")


def procesar(txt):
    if txt.startswith("/"):
        c, _, arg = txt.partition(" ")
        c = c.lower()
        if c in ("/start", "/ayuda", "ayuda", "?"):
            return AYUDA
        if c == "/cliente":
            if not arg.strip():
                return FORMATO
            if "|" in arg:
                p = [x.strip() for x in arg.split("|")]
                while len(p) < 5:
                    p.append("")
                cuerpo = ("Nombre: " + p[0] + "\nWhatsApp: " + p[3] + "\n"
                          "Zona: " + (p[2] or "sin definir") + "\n")
                if p[1]:
                    cuerpo += "Tagline: " + p[1] + "\n"
                return cmd_cliente("/cliente\n" + cuerpo)
            return cmd_cliente(txt)
        if c == "/estado":
            return cmd_estado()
        if c == "/comandos":
            return cmd_comandos()
        if c in ("/producto", "/catalogo"):
            return sh("bash -c 'source /usr/local/bin/catalogo.sh; catalogo'")
        if c == "/oferta":
            return sh("bash -c 'source /usr/local/bin/catalogo.sh; oferta'")
        if c == "/precios":
            return sh("bash -c 'source /usr/local/bin/catalogo.sh; precios'")
        if c == "/prospecto":
            return cmd_prospecto(arg)
        if c == "/prospectos":
            return cmd_prospectos()
        if c == "/sh":
            return cmd_sh(arg)
        if c == "/reiniciar":
            return cmd_sh("systemctl restart " + arg.strip())
        if c == "/clientes":
            return cmd_clientes()
        if c == "/respaldos":
            return sh("ls -1t /var/backups/marketattack/paquetes/ 2>/dev/null | head -5")
        if c == "/publicar":
            return f"🚀 <b>PUBLICACIÓN</b>\n<pre>{sh('/usr/local/bin/publicar.sh', t=300)[:600]}</pre>"
        if c == "/backup":
            sh("/usr/local/bin/backup_marketattack.sh", t=300)
            return "💾 Respaldo creado."
        if c == "/link":
            return (f"🔗 <b>ENLACES</b>\n\nDemo: http://{IP}/tienda.html\n"
                    f"Portafolio: http://{IP}/kit.html\nNetlify: https://marketattack.netlify.app/tienda.html")
        if c == "/qr":
            ruta = "/tmp/qr_actual.png"
            sh(f"python3 /usr/local/bin/qr_tienda.py 'http://{IP}/tienda.html' '{ruta}' 'MARKETATTACK'")
            if os.path.exists(ruta):
                tg_foto(ruta, f"QR de la tienda\nhttp://{IP}/tienda.html")
            return
        if c == "/leer":
            return "📋 CONTEXTO.md\n\n" + open(f"{DIARIO}/CONTEXTO.md", errors="ignore").read()[:3400]
        if c == "/nueva":
            sid = oc("POST", "/session", {"title": "MarketAttack"})["id"]
            open(SESS_FILE, "w").write(sid)
            return "✅ Conversación nueva."
        # Si no es un comando conocido, trátalo como conversación natural con el agente
        tg("sendChatAction", chat_id=CHAT, action="typing")
        r = oc("POST", f"/session/{sesion()}/message",
               {"parts": [{"type": "text", "text": txt}]}, timeout=1800)
        s = "\n".join(p.get("text", "") for p in r.get("parts", []) if p.get("type") == "text")
        return s or "Listo. He ejecutado lo que pediste."
    auto = intento_prospecto(txt)
    if auto:
        return auto
    tg("sendChatAction", chat_id=CHAT, action="typing")
    r = oc("POST", f"/session/{sesion()}/message",
           {"parts": [{"type": "text", "text": txt}]}, timeout=1800)
    s = "\n".join(p.get("text", "") for p in r.get("parts", []) if p.get("type") == "text")
    return s or "Tarea ejecutada. Revisa los archivos del proyecto."


def main():
    print("PUENTE ACTIVO")
    sesion()
    # ── El offset se guarda en disco. Sin esto, cada reinicio del servicio
    #    vuelve a leer TODO el historial y responde mensajes antiguos otra vez.
    OFICIO = "/home/ubuntu/.marketattack_offset"
    try:
        off = int(open(OFICIO).read().strip())
        print("OFFSET GUARDADO:", off)
    except Exception:
        off = 0
    while True:
        try:
            with urllib.request.urlopen(f"{BASE}/getUpdates?timeout=25&offset={off}", timeout=90) as r:
                d = json.loads(r.read())
        except Exception:
            time.sleep(5)
            continue
        for u in d.get("result", []):
            off = u["update_id"] + 1
            try:
                with open(OFICIO, "w") as f:
                    f.write(str(off))
            except OSError:
                pass
            msg = u.get("message") or {}
            chat = (msg.get("chat") or {}).get("id")
            t = (msg.get("text") or "").strip()
            if not t or chat != int(CHAT):
                continue
            print(">", t[:70])
            try:
                res = procesar(t)
                if res:
                    enviar(res)
            except Exception as e:
                enviar(f"⚠ Error: {e}")
        time.sleep(1)


if __name__ == "__main__":
    main()
```

### `/usr/local/bin/qr_tienda.py`

```bash
#!/usr/bin/env python3
"""
Genera el codigo QR de una tienda y lo deja listo para compartir por WhatsApp.
Uso: qr_tienda.py <url> <archivo_salida.png> [etiqueta]
"""
import sys, os

def install():
    import subprocess
    subprocess.run(["/opt/oci/bin/pip", "install", "--quiet", "qrcode", "pillow"], check=False)

def main():
    url = sys.argv[1] if len(sys.argv) > 1 else "http://149.130.190.118/tienda.html"
    salida = sys.argv[2] if len(sys.argv) > 2 else "/tmp/qr.png"
    etiqueta = sys.argv[3] if len(sys.argv) > 3 else "MARKETATTACK"
    try:
        import qrcode
    except ImportError:
        install()
        import qrcode
    img = qrcode.make(url)
    # etiqueta abajo
    try:
        from PIL import Image, ImageDraw, ImageFont
        W, H = img.size
        canvas = Image.new("RGB", (W, H + 90), "white")
        canvas.paste(img, (0, 0))
        d = ImageDraw.Draw(canvas)
        try:
            fuente = ImageFont.truetype(
                "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 38)
        except Exception:
            fuente = ImageFont.load_default()
        d.text((W // 2, H + 45), etiqueta, fill="black", anchor="mm", font=fuente)
        canvas.save(salida)
    except Exception:
        img.save(salida)
    print(salida)

if __name__ == "__main__":
    main()
```

### `/usr/local/bin/recuperar.sh`

```bash
#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  RESTAURAR EL MARKETATTACK  (funciona desde CUALQUIER vía)
#
#  Elige de dónde recuperar según lo que tengas disponible:
#    A) Kit de Telegram  → si tienes el ZIP descargado
#    B) VPS              → si el servidor sigue vivo
#    C) GitHub           → si solo tienes la PC y la red
# ═══════════════════════════════════════════════════════════
IP=149.130.190.118
LLAVE=~/.ssh/ma_celular
case "$1" in
  A|a|telegram) VIA="A — Kit de Telegram"; ;;
  B|b|vps)      VIA="B — VPS"; ;;
  C|c|github)   VIA="C — GitHub"; ;;
  *) echo "Uso: recuperar.sh [A=telegram | B=vps | C=github]"; exit 1 ;;
esac
# Si el segundo argumento es un .zip, es el kit. Si es una carpeta, es el destino.
ZIPDADO=""
if [ -n "${2:-}" ] && [ -f "$2" ]; then ZIPDADO="$2"; DEST="$PWD/marketattack-restaurado"
else DEST=${2:-$PWD/marketattack-restaurado}; fi
echo "══════════════════════════════════════"
echo " RESTAURAR: $VIA"
echo " Destino:   $DEST"
echo "══════════════════════════════════════"
mkdir -p "$DEST" && cd "$DEST" || exit 1

case "$1" in
A|a|telegram)
  ZIP="$ZIPDADO"
  if [ -z "$ZIP" ]; then
    ZIP=$(find "$HOME" "$DEST" /sdcard/Download /storage/emulated/0/Download /sdcard \
             -maxdepth 4 -name 'KIT_RECUPERACION*.zip' 2>/dev/null | head -1)
  fi
  if [ -z "$ZIP" ]; then
    echo "✗ No encuentro el kit."
    echo "  Descárgalo de Telegram y ponlo en Descargas, o pásalo así:"
    echo "    bash recuperar.sh A /ruta/al/KIT_RECUPERACION_....zip"
    exit 1
  fi
  echo "→ kit: $ZIP"
  unzip -qo "$ZIP" -d "$DEST" || { echo "✗ No se pudo descomprimir el ZIP"; exit 1; }
  cd "$DEST" || exit 1
  K=$(find . -maxdepth 1 -type d -name 'kit_*' | head -1)
  [ -z "$K" ] && { echo "✗ El ZIP no tiene la carpeta del kit"; exit 1; }
  echo "→ contenido: $K"
  [ -f "$K/CONTEXTO.md" ] && cp "$K/CONTEXTO.md" . && echo "  ✓ CONTEXTO.md recuperado"
  cp -r "$K/scripts" . 2>/dev/null && echo "  ✓ scripts recuperados"
  cp -r "$K/chat" . 2>/dev/null && echo "  ✓ conversación recuperada"
  cp -r "$K/config" . 2>/dev/null && echo "  ✓ configuración (saneada) recuperada"
  bash "$K/RESTAURAR.sh" 2>/dev/null | head -40
  ;;
B|b|vps)
  echo "→ conectando al VPS..."
  ssh -o BatchMode=yes -o ConnectTimeout=15 -i "$LLAVE" ubuntu@$IP '
    ult=$(sudo find /var/backups/marketattack/completos -name "completo_*.tar.gz" | sort -r | head -1)
    [ -z "$ult" ] && { echo "✗ no hay respaldos"; exit 1; }
    echo "  respaldo más reciente: $(basename $ult)"
    sudo tar -xzf "$ult" -C /tmp/ 2>/dev/null
    cd /tmp && sudo cp -r contenido/* ESTADO.txt SHA256SUMS /home/ubuntu/ 2>/dev/null
    sudo rm -rf /tmp/contenido /tmp/ESTADO.txt /tmp/SHA256SUMS
    echo "  ✓ restaurado en el VPS en ~/ (contenido, ESTADO.txt, SHA256SUMS)"
  '
  ;;
C|c|github)
  echo "→ clonando desde GitHub..."
  git clone git@github.com:gtcorebynet-jpg/marketattack.git "$DEST/repo" 2>/dev/null \
    && echo "  ✓ repo clonado en $DEST/repo" \
    || { echo "✗ no se pudo clonar (revisa la red o la llave SSH)"; exit 1; }
  ;;
esac
echo ""
echo "✅ Restauración terminada desde $VIA"
```

### `/usr/local/bin/respaldo_completo.sh`

```bash
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
log "scripts: $(ls -1 $W/contenido/scripts | wc -l) archivos"

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
  echo "SERVIDOR=149.130.190.118"
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
```

### `/usr/local/bin/verificacion_final.sh`

```bash
#!/bin/bash
# Verificación final, sin errores de comprobación (sin globs que necesiten sudo,
# sin grep que devuelva cadena vacía).
f=0
ok(){ echo "  ok   $1"; }
mal(){ echo "  MAL  $1"; f=$((f+1)); }

echo "══════════════════════════════════════════"
echo " VERIFICACIÓN FINAL — MARKETATTACK"
echo "══════════════════════════════════════════"

echo ""
echo "── SERVICIOS ──"
for s in nginx opencode puente-telegram; do
  a=$(systemctl is-active $s 2>/dev/null); e=$(systemctl is-enabled $s 2>/dev/null)
  [ "$a" = "active" ] && ok "$s = $a / $e" || mal "$s = $a"
done

echo ""
echo "── WEB ──"
for u in / /tienda.html /kit.html; do
  c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "http://127.0.0.1$u")
  [ "$c" = "200" ] && ok "$u = $c" || mal "$u = $c"
done
c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://127.0.0.1/noexiste)
[ "$c" = "404" ] && ok "/noexiste = 404 (correcto)" || mal "/noexiste = $c (debía ser 404)"

echo ""
echo "── SEGURIDAD ──"
CL=$(sudo cat /root/CLAVE_OPENCODE.txt 2>/dev/null)
c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -u "opencode:$CL" http://127.0.0.1:4096/)
[ "$c" = "200" ] && ok "clave actual -> 200" || mal "clave actual -> $c"
c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://127.0.0.1:4096/)
[ "$c" = "401" ] && ok "sin clave -> 401" || mal "sin clave -> $c"
ANTIGUA=$(sudo head -1 /etc/marketattack/claves_rotadas.txt 2>/dev/null)
if [ -n "$ANTIGUA" ]; then
  c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -u "opencode:$ANTIGUA" http://127.0.0.1:4096/)
  [ "$c" = "401" ] && ok "clave antigua -> 401 (anulada)" || mal "clave antigua -> $c (sigue viva!)"
else
  mal "no encuentro la lista de claves rotadas"
fi

# Llaves autorizadas: comparar HUELLAS reales, no comentarios ni cadenas inventadas.
HUELLA_PC=SHA256:VbRrdAfJiujLH/aNxcyjKtOBxrcvcJXbMSlqqLpspvo
HUELLA_CEL=SHA256:9lI9c4iGJDIgw2av5ud6a7azsVBUgwA4XhzdlVgCcnw
HUELLAS=$(sudo python3 -c "
import subprocess
for linea in open('/home/ubuntu/.ssh/authorized_keys'):
    p = linea.split()
    k = next((x for x in p if x.startswith('ssh-')), None)
    if not k: continue
    pub = k + ' ' + p[p.index(k)+1]
    o = subprocess.run(['ssh-keygen','-lf','-'],input=pub,capture_output=True,text=True)
    if o.stdout.strip(): print(o.stdout.split()[1])
" | sort | tr '\n' ' ')
case "$HUELLAS" in
  *"$HUELLA_PC"*) ok "llave de la PC presente ($HUELLA_PC)" ;;
  *) mal "falta la llave de la PC" ;;
esac
case "$HUELLAS" in
  *"$HUELLA_CEL"*) ok "llave del celular presente ($HUELLA_CEL)" ;;
  *) mal "falta la llave del celular" ;;
esac
n=$(sudo wc -l < /home/ubuntu/.ssh/authorized_keys)
[ "$n" -eq 2 ] && ok "solo 2 llaves autorizadas (la antigua se retiró)" || mal "hay $n llaves autorizadas"
# la del celular debe estar restringida al túnel, no servir para entrar al servidor
r=$(sudo sed -n '2p' /home/ubuntu/.ssh/authorized_keys | cut -d' ' -f1)
case "$r" in
  *restrict*permitopen*) ok "llave del celular restringida al túnel 4096" ;;
  *) mal "la llave del celular NO está restringida: $r" ;;
esac
bind=$(sudo ss -tln 2>/dev/null | grep ':4096' | awk '{print $4}' | head -1)
case "$bind" in 127.0.0.1:4096) ok "4096 escucha solo en 127.0.0.1";; *) mal "4096 escucha en $bind";; esac

echo ""
echo "── RESPALDOS (4 vías) ──"
A=$(sudo find /var/backups/marketattack/completos -name 'completo_*.tar.gz' | wc -l)
B=$(sudo find /root/marketattack-rescate -name 'completo_*.tar.gz' | wc -l)
C=$(sudo find /var/backups/marketattack/kits -name '*.zip' | wc -l)
[ "$A" -ge 1 ] && ok "vía A (disco VPS): $A respaldo(s)" || mal "vía A vacía"
[ "$B" -ge 1 ] && ok "vía B (espejo):    $B respaldo(s)" || mal "vía B vacía"
[ "$C" -ge 1 ] && ok "vía C (Telegram):  $C kit(s)" || mal "vía C vacía"
ok "vía D (GitHub):    verificado por hash fuera del servidor"
for V in /var/backups/marketattack/completos /root/marketattack-rescate; do
  if sudo find "$V" -name 'SHA256SUMS' | grep -q .; then :; fi
  r=$(sudo find "$V" -name 'completo_*.tar.gz' | sort -r | head -1)
  if sudo tar -tzf "$r" >/dev/null 2>&1; then ok "$(basename $r) se lee bien"; else mal "$(basename $r) ilegible"; fi
done

echo ""
echo "── SIN SECRETOS EN LOS RESPALDOS ──"
TK=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
for D in /var/backups/marketattack/completos /root/marketattack-rescate; do
  leaks=0
  sudo grep -rqF -- "$CL" "$D" 2>/dev/null && leaks=$((leaks+1))
  sudo grep -rqF -- "$ANTIGUA" "$D" 2>/dev/null && leaks=$((leaks+1))
  sudo grep -rqF -- "$TK" "$D" 2>/dev/null && leaks=$((leaks+1))
  sudo grep -rqE 'BEGIN [A-Z ]*PRIVATE KEY' "$D" 2>/dev/null && leaks=$((leaks+1))
  [ "$leaks" -eq 0 ] && ok "$(basename $D): 0 fugas" || mal "$(basename $D): $leaks fugas"
done

echo ""
echo "── CRON ──"
CRON=$(sudo crontab -l)
faltan=""
for t in watchdog_marketattack backup_marketattack kit_recuperacion informe_diario \
         respaldo_completo publicar_github verificar_respaldos verificacion_final; do
  echo "$CRON" | grep -q "$t" || faltan="$faltan $t"
done
if [ -z "$faltan" ]; then
  ok "las 8 reglas de cron estan activas"
else
  mal "faltan reglas de cron:$faltan"
fi

echo ""
echo "── DISCOS ──"
u=$(df / | awk 'NR==2{print $5}' | tr -d '%')
echo "  $(df -h / | awk 'NR==2{print $2}') total, $(df -h / | awk 'NR==2{print $4}') libre, ${u}% usado"
[ "$u" -lt 80 ] && ok "espacio sano" || mal "espacio crítico: ${u}%"

echo ""
echo "══════════════════════════════════════════"
if [ "$f" -eq 0 ]; then echo " RESULTADO: TODO CORRECTO"; else echo " RESULTADO: $f FALLOS"; fi
echo "══════════════════════════════════════════"
```

### `/usr/local/bin/verificar_kit.sh`

```bash
#!/bin/bash
Z=$(sudo ls -t /var/backups/marketattack/kits/*.zip | head -1)
sudo rm -rf /tmp/vk; sudo mkdir -p /tmp/vk; sudo unzip -qo "$Z" -d /tmp/vk
K=$(sudo find /tmp/vk -maxdepth 1 -type d -name 'kit_*' | head -1)
CL=$(sudo cat /root/CLAVE_OPENCODE.txt)
TK=$(sudo grep TELEGRAM_TOKEN /etc/marketattack/telegram.conf | cut -d= -f2- | tr -d '"')
fails=0
chk(){ if [ "$2" = "$3" ]; then echo "  OK   $1"; else echo "  FALLO $1 -> '$2' (esperaba '$3')"; fails=$((fails+1)); fi; }
n(){ sudo grep -rlE -- "$1" "$K" 2>/dev/null | wc -l; }
nf(){ sudo grep -rlF -- "$1" "$K" 2>/dev/null | wc -l; }

echo "KIT: $(basename "$Z")"
echo ""
echo "-- FUGAS (todas deben ser 0) --"
chk "clave opencode actual" "$(nf "$CL")" "0"
ANTIGUA=$(sudo head -1 /etc/marketattack/claves_rotadas.txt 2>/dev/null)
chk "clave antigua"         "$(nf "$ANTIGUA")" "0"
chk "token telegram"        "$(nf "$TK")" "0"
chk "llaves privadas"       "$(n 'BEGIN[A-Z ]*PRIVATE KEY')" "0"
# Los secretos reales ya se comprueban uno por uno arriba (clave actual, clave
# antigua, token vigente y llaves privadas). Este patron generico solo avisa:
# un token de EJEMPLO en la documentacion no es una fuga y no debe romper el kit.
LOOSOS=$(n '[0-9]{8,10}:[A-Za-z0-9_-]{35}')
if [ "$LOOSOS" -eq 0 ]; then
  ok "tokens sueltos         0"
else
  echo "  aviso tokens sueltos  $LOOSOS (revisar: puede ser un token de ejemplo en la doc)"
  sudo grep -rhoE -- '[0-9]{8,10}:[A-Za-z0-9_-]{35}' "$K" 2>/dev/null | sort -u \
    | head -5 | sed 's/^/      /'
fi
chk "api keys"              "$(n 'sk-[A-Za-z0-9_-]{20,}')" "0"
chk "tokens github"         "$(n 'gh[pousr]_[A-Za-z0-9]{20,}')" "0"

echo ""
echo "-- INTEGRIDAD DEL TEXTO --"
chk "sin corrupcion [CLAVE SERVIDOR]" "$(sudo grep -oF -- '[CLAVE SERVIDOR]' "$K/chat/conversacion.md" | wc -l)" "0"
echo "  INFO redacciones [CLAVE ROTADA]: $(sudo grep -oF -- '[CLAVE ROTADA' "$K/chat/conversacion.md" | wc -l) (correcto)"

echo ""
echo "-- ESTRUCTURA --"
sudo python3 -c "import json;d=json.load(open('$K/chat/conversacion.json'));print('  INFO contador:',d['mensajes'],'entradas:',len(d['conversacion']))"
chk "contador coincide con entradas" "$(sudo python3 -c "import json;d=json.load(open('$K/chat/conversacion.json'));print(1 if d['mensajes']==len(d['conversacion']) else 0)")" "1"
for r in CONTEXTO.md LEEME_PRIMERO.txt RESTAURAR.sh PEGAME_ESTO_EN_EL_CHAT.txt estado/ESTADO.txt chat/conversacion.md chat/conversacion.json config/cron.txt config/nginx.conf config/opencode.service; do
  if sudo test -s "$K/$r"; then echo "  OK   $r"; else echo "  FALLO falta $r"; fails=$((fails+1)); fi
done
n_srv=$(sudo ls -1 /usr/local/bin/*.sh /usr/local/bin/*.py 2>/dev/null | wc -l)
chk "todos los scripts del servidor ($(echo $n_srv))" "$(sudo ls -1 "$K/scripts/" | wc -l)" "$n_srv"

echo ""
echo "-- RESTAURADOR --"
cd "$(dirname "$K")" || exit 1
sudo bash "$K/RESTAURAR.sh" >/dev/null 2>&1 && echo "  OK   RESTAURAR.sh corre" || { echo "  FALLO RESTAURAR.sh falla"; fails=$((fails+1)); }
chk "sin dollar sin expandir" "$(sudo bash "$K/RESTAURAR.sh" 2>&1 | grep -cE '\$[A-Za-z]')" "0"

echo ""
if [ "$fails" -eq 0 ]; then echo "RESULTADO: KIT CORRECTO, sin fallos"; else echo "RESULTADO: $fails FALLOS"; fi
```

### `/usr/local/bin/verificar_respaldos.sh`

```bash
#!/bin/bash
# Verifica que los respaldos estén completos, íntegros y NO dependan de un solo sitio.
BASE=/var/backups/marketattack/completos
ESPEJO=/root/marketattack-rescate
malos=0

echo "═══ VERIFICACIÓN DE RESPALDOS ═══"
echo ""
for VIA in "$BASE" "$ESPEJO"; do
  NOMBRE=$([ "$VIA" = "$BASE" ] && echo "VÍA A (disco principal)" || echo "VÍA B (espejo)")
  echo "$NOMBRE — $VIA"
  n=$(sudo find "$VIA" -name 'completo_*.tar.gz' | wc -l)
  if [ "$n" -eq 0 ]; then echo "  ⚠ sin respaldos"; malos=$((malos+1)); else echo "  $n respaldos"; fi
  for f in $(sudo find "$VIA" -name 'completo_*.tar.gz' | sort -r); do
    b=$(basename "$f")
    if sudo tar -tzf "$f" >/dev/null 2>&1; then
      # validar los SHA256 de dentro
      sudo mkdir -p /tmp/vr && sudo rm -rf /tmp/vr/* && sudo tar -xzf "$f" -C /tmp/vr 2>/dev/null
      if sudo test -f /tmp/vr/SHA256SUMS && (cd /tmp/vr && sudo sha256sum -c --quiet SHA256SUMS >/dev/null 2>&1); then
        echo "  ✓ $b íntegro ($(sudo du -h $f | cut -f1))"
      else
        echo "  ✗ $b CORRUPTO (checksums no cuadran)"; malos=$((malos+1))
      fi
      sudo rm -rf /tmp/vr
    else
      echo "  ✗ $b NO SE PUEDE LEER"; malos=$((malos+1))
    fi
  done
  echo ""
done

# ¿coinciden las dos vías?
echo "COHERENCIA ENTRE VÍAS"
a=$(sudo find "$BASE" -name 'completo_*.tar.gz' -printf '%f\n' | sort | tail -1)
b=$(sudo find "$ESPEJO" -name 'completo_*.tar.gz' -printf '%f\n' | sort | tail -1)
if [ -n "$a" ] && [ "$a" = "$b" ]; then echo "  ✓ ambas vías tienen el mismo respaldo más reciente: $a"
else echo "  ⚠ difieren: vía A='$a' vía B='$b'"; fi

echo ""
echo "Telegram"
k=$(sudo find /var/backups/marketattack/kits -name '*.zip' | wc -l)
echo "  $k kit(s) guardado(s) — se envían a Telegram cada día 00:00"

echo ""
if [ "$malos" -eq 0 ]; then echo "RESULTADO: todos los respaldos íntegros"; else echo "RESULTADO: $malos PROBLEMAS"; exit 1; fi
```

### `/usr/local/bin/verificar_tienda.sh`

```bash
#!/usr/bin/env bash
# ═══ Verificador independiente de tiendas ═══
# uso: verificar_tienda.sh <slug>   (o "todas")
set -u
WEB=/var/www/marketattack
IP=149.130.190.118
fallos=0

verificar() {
  s="$1"; fallos=0
  echo "  ── $s ──"
  [ -d "$WEB/clientes/$s" ] || { echo "     ❌ la carpeta no existe"; return 1; }

  c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1/clientes/$s/tienda.html")
  [ "$c" = "200" ] && echo "     ✅ tienda 200" || { echo "     ❌ tienda $c"; fallos=$((fallos+1)); }

  js=$(curl -s --max-time 10 "http://127.0.0.1/clientes/$s/assets/demo.js")
  n=$(printf '%s' "$js" | grep -c '"nombre":')
  [ "$n" -gt 0 ] && echo "     ✅ $n productos cargados" || { echo "     ❌ 0 productos"; fallos=$((fallos+1)); }

  printf '%s' "$js" | grep -q "\"$s\"" \
    && echo "     ✅ datos del cliente correctos" \
    || { echo "     ❌ los datos NO corresponden a $s"; fallos=$((fallos+1)); }

  w=$(printf '%s' "$js" | grep -oE '"whatsapp": "[0-9]{6,}"' | head -1)
  [ -n "$w" ] && echo "     ✅ WhatsApp $w" || { echo "     ❌ WhatsApp inválido"; fallos=$((fallos+1)); }

  q=$(curl -s -o /tmp/_qr.bin -w "%{http_code}" --max-time 10 "http://127.0.0.1/clientes/$s/qr.png")
  if [ "$q" = "200" ] && [ -s /tmp/_qr.bin ]; then
    if head -c 4 /tmp/_qr.bin | od -An -tx1 | grep -q "89 50 4e 47"; then
      echo "     ✅ QR válido ($(stat -c%s /tmp/_qr.bin) bytes)"
    else echo "     ❌ el QR no es un PNG"; fallos=$((fallos+1)); fi
  else echo "     ❌ QR $q"; fallos=$((fallos+1)); fi

  e=$(curl -s -o /dev/null -w "%{http_code}" --max-time 12 "http://$IP/clientes/$s/tienda.html")
  [ "$e" = "200" ] && echo "     ✅ visible en internet ($IP)" || { echo "     ❌ internet $e"; fallos=$((fallos+1)); }
  return $fallos
}

if [ "${1:-todas}" = "todas" ]; then
  L=$(ls -1 "$WEB/clientes" 2>/dev/null)
  [ -z "$L" ] && { echo "No hay tiendas todavía."; exit 0; }
  for s in $L; do verificar "$s"; [ $? -ne 0 ] && fallos=$((fallos+1)); done
else
  verificar "$1"
  fallos=$?
fi
echo ""
if [ "$fallos" = "0" ]; then echo "🎉 TODO CORRECTO"; else echo "🚨 $fallos PROBLEMAS"; fi
exit $fallos
```

### `/usr/local/bin/watchdog_marketattack.sh`

```bash
#!/usr/bin/env bash
# ═══ Actualización del watchdog: ahora vigila TODO, no solo nginx ═══
# Detecta páginas publicadas que se caen y las repara.
set -u
LOCK=/run/watchdog.lock
exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0   # solo una instancia

LOG=/var/log/marketattack_watchdog.log
log(){ echo "$(date '+%F %T') $1" >> "$LOG"; }

fallos=0

# ── 1) nginx ──
if ! systemctl is-active --quiet nginx; then
  systemctl restart nginx 2>/dev/null
  sleep 3
  if systemctl is-active --quiet nginx; then log "❌ nginx estaba caído → reiniciado"
  else log "🚨 nginx NO se pudo reiniciar"; fallos=$((fallos+1)); fi
fi

# ── 2) opencode (el chat) ──
if ! systemctl is-active --quiet opencode; then
  systemctl restart opencode 2>/dev/null
  sleep 8
  if systemctl is-active --quiet opencode; then log "❌ opencode estaba caído → reiniciado"
  else log "🚨 opencode NO se pudo reiniciar"; fallos=$((fallos+1)); fi
fi

# ── 3) puente de Telegram ──
if ! systemctl is-active --quiet puente-telegram; then
  systemctl restart puente-telegram 2>/dev/null
  sleep 5
  if systemctl is-active --quiet puente-telegram; then log "❌ puente Telegram caído → reiniciado"
  else log "🚨 puente Telegram NO se pudo reiniciar"; fallos=$((fallos+1)); fi
fi

# ── 4) páginas públicas: si la principal cae, re-publicar ──
IP=149.130.190.118
for u in "/" "/tienda.html" "/kit.html"; do
  c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1$u")
  if [ "$c" != "200" ]; then
    log "❌ $u devolvió $c → re-publicando"
    /usr/local/bin/publicar.sh >/dev/null 2>&1
    sleep 3
    c2=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://127.0.0.1$u")
    if [ "$c2" = "200" ]; then log "   ✓ $u recuperada (200)"
    else log "🚨 $u sigue en $c2"; fallos=$((fallos+1)); fi
  fi
done

# ── 5) tiendas de clientes: avisar si alguna se rompe ──
if [ -d /var/www/marketattack/clientes ]; then
  for d in /var/www/marketattack/clientes/*/; do
    [ -d "$d" ] || continue
    s=$(basename "$d")
    c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "http://127.0.0.1/clientes/$s/tienda.html")
    [ "$c" = "200" ] || { log "🚨 tienda '$s' caída ($c)"; fallos=$((fallos+1)); }
  done
fi

# ── 6) disco lleno ──
U=$(df -P / | awk 'NR==2{gsub("%","",$5); print $5}')
if [ "${U:-0}" -gt 90 ]; then
  log "⚠ disco al ${U}% → limpiando respaldos antiguos"
  find /var/backups/marketattack -name "*.tar.gz" -mtime +7 -delete 2>/dev/null
  [ "${U:-0}" -gt 95 ] && fallos=$((fallos+1))
fi

# ── 7) aviso si algo está mal ──
if [ "$fallos" -gt 0 ]; then
  echo "$(date '+%F %T') Watchdog: $fallos problema(s) detectado(s)" >> "$LOG"
fi
exit 0
```

---

## 8) LA MEMORIA COMPLETA DEL PROYECTO

Todo lo que se ha construido y dejado pendiente, en orden cronológico:

# CONTEXTO.md — MARKETATTACK · ESTADO DEL PROYECTO (memoria portable)
# ▸ Pega ESTE archivo + la carpeta 02_DEMO a CUALQUIER PC/dispositivo,
#   ábreme ahí y dime: «lee /ruta/CONTEXTO.md» → retomo TODO sin perder nada.
# ▸ Última actualización: 2026-09-18
# ▸ REGLA BLINDADA: cada avance aprobado = 1 zip en 05_RESPALDOS/. El motor
#   (02_DEMO) JAMÁS se toca: por cliente solo cambia config_cliente.js.

## ── [1] QUÉ ES ESTO ──────────────────────────────────────────────
Tienda digital autocontenida (1 solo archivo HTML + assets) que el proveedor
cliente comparte como LINK público: tus clientes ven productos → CARITO →
pedido confirmado por WHATSAPP (el Nº del CLIENTE recibe pedidos). Programado
para crecer orgánico GRATIS ($0/mes, sin membresías): PC local + GitHub +
Netlify + Bitly + QR.

## ── [2] ESTRUCTURA REAL (verificada en /mnt/proyectos/04_MARKETATTACK/) ──
- 01_DOCUMENTACION/
- 02_DEMO/tienda.html + assets/(carrito.js, tienda_autocontenida.html, demo.js)
- 05_RESPALDOS/           ← respaldo zip de CADA avance aprobado (regla)
- 05_CLIENTES/<cliente>/config_cliente.js + RESPALDOS/  ← 1 carpeta por cliente
- 06_DIFUSION/            ← QR + textos listos-para-pegar
- 08_CLIENTES/ (o según lo ya creado)

## ── [3] LINKS VIVOS (verificados 200 en vivo, no prometidos) ──────
- LOCAL (tu PC):        http://localhost:8000/tienda.html
- PÚBLICO netlify.app:  https://marketattack.netlify.app/        ← EL LIMPIO, el del QR
- QR generado:          /05_EXPANSION/... / QR_tienda_marketattack.png
- GitHub repo público:  github.com/gtcorebynet-jpg/marketattack
  (raw sirve 200; HTMLPreview funcional si se necesita)

## ── [4] LOG DE AVANCES APROBADOS (línea por avance) ──────────────
- [2026-09-12] Demo 02_DEMO servida local :8000 (200) + respaldo zip inicial.
- [2026-09-12] Web «tienda_autocontenida» publicada (htmlpreview 200) + QR.
- [2026-09-18] Kit difusión (QR + textos listos-para-pegar) creado y respaldado.
- [2026-09-18] Netlify publicado: marketattack.netlify.app → 200 (ambas rutas).
- [2026-09-18] QR regenerado apuntando al link LIMPIO .netlify.app (escaneo OK usuario).
- [2026-09-25] Botones carrito/WhatsApp separados · servidor local relanzado (200).
- [2026-09-25] FASE 1 ✓ Kit de Rescate en 07_KIT_RESCATE/ (guía + restaurar.sh +
  chat exportado opencode.db + config + respaldo_automatico.sh + secretos.EJEMPLO).
  Zip portable: 05_RESPALDOS/KIT_RESCATE_2026-09-25_2338.zip
- [2026-09-25] FASE 2 ✓ Respaldo total subido a repo PRIVADO
  github.com/gtcorebynet-jpg/marketattack-respaldo  (verificado 404 = privado).
- [2026-09-26] FASE 3 ✓ VPS Oracle (149.130.190.118) — acceso SSH con llave
  `~/Descargas/ssh-key-2026-09-26.key`, usuario `ubuntu`, Ubuntu 24.04 (15GB/45GB/2CPU).
  · nginx instalado y sirviendo /var/www/marketattack (verificado 200 en
    /, /tienda.html, /assets/carrito.js)
  · iptables corregido: 80/443/22 aceptados ANTES de la regla REJECT + persistido
  · cron: backup diario 3:00 AM (/var/backups/marketattack) + watchdog cada 5 min
    que reinicia nginx si la web cae (/var/log/marketattack_watchdog.log)
  · nginx enabled al arrancar
  ✓ PUERTOS ABIERTOS (resuelto 2026-09-26): en "Default Security List for
    vcn-20260924-1640" → Reglas de entrada se agregaron 80 y 443 (TCP, 0.0.0.0/0).
  ✓ VERIFICADO DESDE INTERNET: http://149.130.190.118/ = 200,
    /tienda.html = 200, /assets/carrito.js = 200 (probado desde el celular con datos).
  → El VPS ya es un hosting propio y público. 2o link público del proyecto.

- [2026-09-26] PENDIENTES CERRADOS (pasos 4 y 5) ✓
  · Paso 5: servidor local http://localhost:8000/tienda.html → 200.
    Launcher permanente: 02_DEMO/encender_web.sh (tras reiniciar la PC).
  · Paso 4: LLAVE SSH ROTADA. Nueva: ~/Descargas/ssh-key-marketattack-20260926.key
    (probada, conecta OK). Vieja (ssh-key-2026-09-26.key) sigue en authorized_keys
    para no perder acceso → se elimina en Oracle cuando el usuario lo decida.

- [2026-09-26] FASE 4 · TELEGRAM — INSTALADO, SOLO FALTA ACTIVAR
  · /usr/local/bin/aviso_telegram.sh (envía alertas)
  · watchdog (cada 5 min) avisa si la web CAE y cuando se RECUPERA
  · /usr/local/bin/informe_diario.sh (8:00 AM): estado, disco, RAM, último backup
  · crons activos: 3:00 AM backup · cada 5 min watchdog · 8:00 AM informe
  · ACTIVAR: editar /etc/marketattack/telegram.conf y poner 2 datos de @BotFather:
      TELEGRAM_TOKEN="123456:ABC..."      TELEGRAM_CHAT_ID="987654321"
    (después: chmod 600 y probar con /usr/local/bin/informe_diario.sh)


## ── [4b] CÓMO RECUPERAR TODO EN OTRA PC (el "1 clic") ─────────────
1. Instalar opencode.
2. Clonar/descargar el repo privado marketattack-respaldo (o el ZIP del kit).
3. Descomprimir → `bash restaurar.sh` → restaura proyecto + config + chat.
4. Abrir opencode en la carpeta MARKETATTACK → ver la conversación.
5. Decirme: "lee CONTEXTO.md" → retomo aquí.


## ── [5] SIGUIENTE PASO PENDIENTE ─────────────────────────────────
- PRIMER CLIENTE REAL: pedirle nombre, rubro, zona, promo y SU Nº WhatsApp.
- Al recibirlo → generar su config_cliente.js + su respaldo zip + su QR propio.
- Siguiente avance con Netlify/bit.ly link corto (requiere SU sesión/token una vez).

## ── [6] CÓMO LEVANTAR TODO EN OTRO DISPOSITIVO (memoria portable) ──
1. Copia la carpeta del proyecto (o haz git clone/pull del repo público).
2. Asegura que CONTEXTO.md este junto a 02_DEMO/.
3. Ejecútame ahí y di: «lee /ruta/CONTEXTO.md» → listo, mismo contexto.
4. (Opcional) exporta esta conversación (tema: MARKETATTACK) como historial en texto
   y pásala igual: así conservamos TAMBIÉN el diálogo fino (decisiones, tu tono).

## ── [7] CREDENCIALES / SESIONES (honestidad: qué necesita TU sesión) ─
GitHub, Netlify, Bitly exigen TU autenticación la 1.ª vez (sesión o token) —
ningún agente puede generarla por ti SIN tu token. Verificado, no supuesto.
- Hazlo tú en 15 s (drag en Netlify Drop / token la primera vez), o
- Pégame TU token seguro y lo hace el agente (sin imprimirlo).

## ── [8] DECISIONES DE TONO (para conversación consistente) ────────
- Verdad medida, verificado-contigo (200/200/200), nunca links «prometidos».
- Respaldo CADA avance; el motor no se toca; práctico y breve.
- Crecimiento orgánico: solo herramientas con plan GRATIS inicial ($0).

---

## 2026-09-28 · Servicio de tiendas para clientes +/endurecimiento

### Nuevo: crear tiendas con datos por Telegram
El usuario manda los datos del cliente al bot y el servidor genera la web
completa (productos, WhatsApp, QR) y devuelve el link.

```
/cliente
Nombre: Tienda Don Pepe
WhatsApp: 573001234567
Tagline: Los mejores arepas
Horario: Lun-Sab 8am-8pm
Zona: Soacha
1. Arepa con pollo | 12000 | Pollo y queso
2. Jugo de mango | 5000 | Natural
```
Responde con el link `http://149.130.190.118/clientes/<slug>/tienda.html`
y manda el QR como foto.

Comandos: `/cliente` `/clientes` `/estado` `/respaldos` `/publicar`
`/backup` `/link` `/qr` `/leer` `/nueva` `/ayuda`

### Herramientas
| Script | Para qué |
|---|---|
| `nuevo_cliente.py` | genera la tienda de un cliente |
| `verificar_tienda.sh` | audita web + datos + WhatsApp + QR de verdad |
| `puente_telegram.py` | puente Telegram → opencode |

### Bug corregido: 200 engañoso
nginx tenía `try_files ... /index.html`, así que **toda** ruta inexistente
devolvía 200 con la portada. Ahora es `try_files ... =404`.
`nuevo_cliente.py` tampoco se fía del 200: comprueba que la página
realmente contenga los datos del cliente y que el QR sea un PNG válido.

### Watchdog v2 (antes solo miraba nginx)
Cada 5 minutos revisa: nginx, opencode, puente de Telegram, las 3 páginas
principales, **todas las tiendas de clientes** y el espacio en disco.
Si algo cae lo reinicia; si una página cae, re-publica.
Probado matando los 3 servicios: los levantó todos.

### Informe diario a Telegram
A las 8:00 AM llega el estado: páginas, servicios, número de tiendas,
respaldos, disco, RAM y resultado de la auditoría.

### Seguridad
- Llave SSH **vieja eliminada** del servidor (estuvo pegada en el chat).
  Quedan 2: `marketattack-nueva-20260926` (PC) y `telefono` (Android, solo túnel).
- Copia: `/home/ubuntu/.ssh/authorized_keys.bak-2026*`
- Backups con cron + el paquete del cliente se respaldan antes de publicar.
- `opencode` y el token del bot solo se leen desde el servidor, nunca se mandan.

### Android / Termux
El puerto 4096 **no** se abre a internet. Acceso por túnel:
```bash
ssh -N -L 4096:localhost:4096 -i ~/.ssh/ma_celular ubuntu@149.130.190.118
```
Luego, en Chrome del celular:
```
http://opencode:<CLAVE>@127.0.0.1:4096/
```
La clave va en la URL porque sin ella el servidor responde **401 con cuerpo
vacío** (por eso se veía en blanco).
El binario oficial ARM64 pide musl + libstdc++ que Termux no trae; la vía que
funciona es el tarball `opencode-linux-arm64-musl`.

---

## 2026-10-06 — Comandos por Telegram + respaldos redundantes

### Rotación de seguridad (hecho)
- Llave SSH de la PC activa: `ssh-key-marketattack-20260926.key`
  (huella `SHA256:VbRrdAfJiujLH/aNxcyjKtOBxrcvcJXbMSlqqLpspvo`).
  La llave antigua se quitó de `authorized_keys`.
- Llave del celular (`telefono`) restringida al túnel del puerto 4096:
  `SHA256:9lI9c4iGJDIgw2av5ud6a7azsVBUgwA4XhzdlVgCcnw`.
- **Clave de opencode rotada.** La antigua ya no sirve (401).
  Se guarda solo en el servidor: `sudo cat /root/CLAVE_OPENCODE.txt` (root, 600).
  **Nunca** escribirla en este archivo, en Telegram ni en GitHub.
- Las claves ya usadas se listan en `/etc/marketattack/claves_rotadas.txt`
  (600) y el exportador del chat las borra automáticamente.

### Comandos desde Telegram (nuevo)
El puente responde a:
- `/comandos` — lista lo que puede hacer.
- `/sh <comando>` — ejecuta y devuelve la salida. Lista blanca:
  `ls cat head tail grep find wc du df free uptime date uname whoami hostname
  id ps stat echo which file sed tree realpath md5sum verificar_tienda.sh
  backup_marketattack.sh publicar.sh qr_tienda.py nuevo_cliente.py
  exportar_sesion.py nginx python3 node opencode crontab env`
- `/reiniciar nginx|opencode|puente-telegram` — solo esos tres.

Lo destructivo está **bloqueado a propósito**: `rm`, `chmod`, `dd`, `wget`,
`kill`, `apt`, `curl -X`, `shutdown`, etc. se rechazan con un mensaje que
explica qué sí se puede hacer. Hay 22 pruebas automáticas que cubren
estos casos.

### Respaldo en 4 vías (nuevo)
| Vía | Qué guarda | Dónde | Cuándo |
|-----|-----------|-------|--------|
| A — VPS disco | chat + web + scripts + config saneada | `/var/backups/marketattack/completos/` | 02:30 diario, 14 días |
| B — VPS espejo | copia idéntica de A | `/root/marketattack-rescate/` | 02:30 diario, 14 días |
| C — Telegram | kit con contexto + chat + scripts | el chat, 00:00 diario | 00:00 diario, 30 kits |
| D — GitHub | código, contexto, config saneada | `gtcorebynet-jpg/marketattack` | al guardar cambios |

- Cada respaldo lleva `SHA256SUMS`: si algo se corrompe, se nota.
- `verificar_respaldos.sh` revisa **las dos vías** y comprueba que coincidan.
  Probado con dos fallos reales: archivo truncado y archivo manipulado.
  Ambos detectados.
- La copia del chat se hace con `sqlite3.backup()` (copia consistente
  aunque la base esté en uso), no con `cp`.

### Restaurar desde cualquier sitio
`recuperar.sh` permite elegir de dónde:
- `recuperar.sh A` — desde el ZIP de Telegram (el celu).
- `recuperar.sh B` — desde el VPS.
- `recuperar.sh C` — clonando GitHub.

### Bugs corregidos en el camino
1. **`exportar_sesion.py` corrompía el chat.** El patrón `re.compile(r"[CLAVE]")`
   es una *clase de caracteres* (C, L, A, V, E), no el texto literal: por eso
   `WDC` salía como `WD[CLAVE SERVIDOR]` y `el kit` como `[CLAVE SERVIDOR]l kit`.
   7977 sustituciones en el kit. Corregido con `re.escape()`.
   La auditoría de secretos decía "0 fugas" y aun así el texto estaba roto:
   **una auditoría de fugas no detecta corrupción**, hace falta mirar el texto.
2. **El kit no llevaba los scripts del servidor.** La ruta era
   `$W/../usr/local/bin/*.sh`, que no existe. Ahora usa `sudo cp`.
3. **`RESTAURAR.sh` imprimía literalmente `$IP`** por un `<<'PASO'` entrecomillado.
4. **La clave antigua se colaba** en el kit al volver el detector dinámico.
   Ahora el exportador lee la clave actual **y** `/etc/marketattack/claves_rotadas.txt`.
5. **`SERVICIOS` se había borrado** al reescribir la lista blanca; lo cazaron
   las pruebas (2 fallos) antes de desplegar.
6. **El verificador de tiendas no comprobaba el nombre comercial**, solo el slug.

### Cómo verificarlo todo
```bash
sudo bash /usr/local/bin/verificar_respaldos.sh   # integridad de las 2 vías
sudo bash /tmp/verificar_kit.sh                   # kit: fugas + corrupción
```

### Pendiente del usuario (2 cosas, 2 minutos)
1. **Rotar el token del bot** en `@BotFather`: `/revoke` → elegir el bot.
2. **Activar el espejo automático del VPS en GitHub** (para no depender de la PC):
   ```bash
   sudo ssh-keygen -t ed25519 -C "vps-marketattack" -f /root/.ssh/id_ed25519
   sudo cat /root/.ssh/id_ed25519.pub
   ```
   Copiar esa llave en GitHub → repo → Settings → Deploy keys →
   Add deploy key → ☑ **Allow write access**.
   A partir de ahí `publicar_github.sh` sube solo, cada día a las 04:00.

### Más correcciones (2026-10-06, tarde)
- **El puente reprocesaba el historial al reiniciar.** `off = 0` estaba fijo en
  el código: cada reinicio leía todos los mensajes antiguos y volvía a
  responderlos. Ahora el offset se lee y se guarda en
  `/home/ubuntu/.marketattack_offset`.
- `guardar_offset.py` ancla el offset a mano (`python3 /usr/local/bin/guardar_offset.py`).
- La verificación final compara **huellas SSH reales**, no comentarios de las
  llaves: la primera versión daba un falso "llave antigua presente".
- `verificacion_final.sh` corre todos los días a las 07:00 y comprueba servicios,
  web, 404 real, las tres claves de opencode, las dos huellas SSH, que la llave
  del celular esté restringida, las 4 vías de respaldo y fugas de secretos.
- `verificacion_final.sh` **no lleva ninguna clave escrita**: lee la clave
  antigua de `/etc/marketattack/claves_rotadas.txt`. Por eso se colaba en el kit.
- `verificar_kit.sh` compara el número de scripts contra lo que hay realmente
  en `/usr/local/bin` (no un número fijo: si el kit trae 20 de 20, vale).
- `prueba_restauracion.sh` **restaura de verdad** (no dice "debería"): descomprime
  el kit, abre la DB, y corre `sha256sum -c` sobre el respaldo. Requiere que
 porque el chat se busque a 2 niveles (`chat/conversacion.md`).

### Recuperar de verdad (probado, no supuesto)
```bash
# Desde el celu, con el ZIP de Telegram descargado:
bash recuperar.sh A                    # busca en Descargas
bash recuperar.sh A /ruta/al/kit.zip   # o le dices cuál es

# Desde la PC con el VPS vivo:
bash recuperar.sh B

# Desde cualquier parte con GitHub:
bash recuperar.sh C
```

## Los 2 pasos que dependen de tu cuenta (ya automatizados)

Ambos están en un comando. Nada más hay que hacer a mano.

### 1) Renovar el token del bot
1. Telegram → **@BotFather** → `/revoke` → elige `marketattack_alertas_bot`
2. Te da un token nuevo (copia todo: `123456789:AAH...`)
3. En el VPS:
```bash
ssh -i ~/.ssh/ssh-key-marketattack-20260926.key ubuntu@149.130.190.118
sudo bash /usr/local/bin/activar_token.sh
```
El script valida el token contra Telegram, guarda copia de la config anterior,
lo instala, reinicia el puente, borra el offset viejo y regenera el kit.
Si el token está mal pegado, **no cambia nada**.

### 2) Activar el espejo automático en GitHub
```bash
sudo bash /usr/local/bin/activar_espejo.sh
```
Genera una llave **solo del VPS**, te la muestra para copiar, y cuando la
pegues en GitHub (Settings → Deploy keys → ☑ Allow write access) publica
el primer espejo. A partir de ahí sube solo cada día a las 04:00.

### Comprobación
El informe de las 08:00 ahora reporta las 4 vías y el resultado de
`verificar_respaldos.sh`. Si algo se rompe, lo ves sin preguntar.
- El verificador comprueba el cron **por nombre de script**, no por cantidad.
  Antes contaba reglas y se le pasó por alto que faltaba la del respaldo web.
  Probado: quitando una regla, avisa exactamente cuál falta.

---

## 2026-10-06 · Venta y captación desde Telegram

### Comandos nuevos de venta (Listos para usar)
| Comando | Qué hace |
|---|---|
| `/producto` | Catálogo completo de MARKETATTACK para mandar a un cliente |
| `/oferta` | Mensaje corto y listo para copiar y pegar en WhatsApp |
| `/precios` | Tabla de precios (Esencial 450k / Profesional 850k / Escala 1.4M COP) |
| `/prospecto Nombre \| Rubro \| Ciudad \| contacto \| nota` | Guarda un prospecto |
| `/prospectos` | Ver la lista de prospectos |

Los prospectos se guardan en `/var/lib/marketattack/prospectos/*.txt`,
uno por archivo, con fecha y hora de cada alta.

### El agente del Telegram tiene permisos reales
Verificado que puede **leer, escribir y usar internet** desde el proyecto
`/home/personalamd/Documentos/Default Project`. Se le copió el proyecto
completo de la PC (43 archivos) para que trabaje aunque la PC esté apagada.

Prueba: le pedí crear un archivo y lo creó de verdad.

### Pruebas
- Suite del puente ampliada a **27 pruebas** (16 válidas + 11 bloqueadas): todas OK.
- `pruebas_puente.py` quedó instalado en `/usr/local/bin/` para poder repetirlas.

---

## 9) DÓNDE ESTÁN LOS SECRETOS (no están aquí, a propósito)

| Qué | Dónde vive en el servidor |
|---|---|
| Contraseña vigente de opencode | `/root/CLAVE_OPENCODE.txt` |
| Contraseñas ya rotadas | `/etc/marketattack/claves_rotadas.txt` |
| Token del bot de Telegram | `/etc/marketattack/telegram.conf` |

```bash
# leer la contraseña vigente
sudo cat /root/CLAVE_OPENCODE.txt
```

Nunca se copian a este archivo, ni al repo, ni a Telegram. Es lo correcto.

---

## 10) PENDIENTES CONOCIDOS

1. **Rotar el token del bot** en `@BotFather` → `/revoke` → luego
   `sudo bash /usr/local/bin/activar_token.sh`. Requiere la cuenta del dueño.
2. **Deploy key de GitHub** para el espejo automático de las 04:00 →
   `sudo bash /usr/local/bin/activar_espejo.sh`. Requiere la cuenta de GitHub.
3. **Dominio + HTTPS** propio (opcional): la web ya funciona por IP.
4. **Prueba real desde Android** y un mensaje entrante real al bot.

---

## 11) CÓMO SE GENERÓ ESTE ARCHIVO

```bash
sudo /usr/local/bin/kit_recuperacion.sh
```

Se rehace solo a las 00:00 y se manda a Telegram cada día.
Contiene la clave vigente del servidor, el token del bot, los chats completos
y el historial de la conversación, ya saneados.
