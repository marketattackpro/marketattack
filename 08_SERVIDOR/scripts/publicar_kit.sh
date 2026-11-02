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
      <code>ssh ubuntu@157.137.203.223</code> (o <code>ssh marketattack</code> desde tu PC)</li>
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
