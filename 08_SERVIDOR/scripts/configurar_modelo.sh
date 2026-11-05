#!/usr/bin/env bash
# ═══ Deja el bot de Telegram con un modelo que SÍ responde ═══
# Lee la clave de IA que ya usa la tienda (/etc/marketattack/ia.conf),
# la registra en OpenCode como proveedor "groq" y reinicia los servicios.
#
# Uso:  sudo configurar_modelo.sh
#
# Se puede correr después de restaurar un respaldo, porque la clave de IA
# NO viaja dentro de los respaldos (es un secreto).
set -uo pipefail

CONF=/etc/marketattack/ia.conf
TG=/etc/marketattack/telegram.conf
SERV=/etc/systemd/system/opencode.service
PROVEEDOR="${MODELO_PROVEEDOR:-groq}"
MODELO="${MODELO_ID:-openai/gpt-oss-120b}"

log(){ echo "   $1"; }

[ -f "$CONF" ] || { echo "✗ falta $CONF (clave de IA)"; exit 1; }
KEY=$(grep -E '^IA_API_KEY=' "$CONF" | cut -d= -f2- | tr -d '"' | tr -d "'")
[ -n "$KEY" ] || { echo "✗ la clave de IA está vacía en $CONF"; exit 1; }

PASS=$(grep -o 'OPENCODE_SERVER_PASSWORD=[^ ]*' "$SERV" | cut -d= -f2-)
[ -n "$PASS" ] || { echo "✗ no encontré la clave del servidor OpenCode"; exit 1; }

# 1) recordar el modelo en la configuración del bot
if ! grep -q '^MODELO_PROVEEDOR=' "$TG" 2>/dev/null; then
  echo "MODELO_PROVEEDOR=$PROVEEDOR" >> "$TG"
fi
if ! grep -q '^MODELO_ID=' "$TG" 2>/dev/null; then
  echo "MODELO_ID=$MODELO" >> "$TG"
fi
chmod 640 "$TG" 2>/dev/null || true

# 2) registrar la clave en OpenCode
python3 - "$KEY" "$PROVEEDOR" "$PASS" <<'PY'
import sys, json, base64, urllib.request
key, proveedor, pw = sys.argv[1], sys.argv[2], sys.argv[3]
auth = "Basic " + base64.b64encode(("opencode:" + pw).encode()).decode()
req = urllib.request.Request(
    f"http://127.0.0.1:4096/auth/{proveedor}",
    data=json.dumps({"type": "api", "key": key}).encode(), method="PUT")
req.add_header("Authorization", auth)
req.add_header("Content-Type", "application/json")
with urllib.request.urlopen(req, timeout=30) as r:
    print("   clave registrada:", r.status)
PY
[ $? -eq 0 ] || { echo "✗ OpenCode no aceptó la clave"; exit 1; }

# 3) reiniciar para que tome el proveedor nuevo
systemctl restart opencode
sleep 5
systemctl restart puente-telegram
sleep 3
systemctl is-active --quiet opencode || { echo "✗ opencode no arrancó"; exit 1; }
systemctl is-active --quiet puente-telegram || { echo "✗ puente-telegram no arrancó"; exit 1; }

# 4) prueba real: pedir una respuesta corta
python3 - "$PROVEEDOR" "$MODELO" <<'PY'
import sys, json, base64, urllib.request
proveedor, modelo = sys.argv[1], sys.argv[2]
pw = ""
for l in open("/etc/systemd/system/opencode.service"):
    if "OPENCODE_SERVER_PASSWORD=" in l:
        pw = l.split("OPENCODE_SERVER_PASSWORD=", 1)[1].split()[0]
auth = "Basic " + base64.b64encode(("opencode:" + pw).encode()).decode()
def call(m, path, body=None, t=90):
    req = urllib.request.Request(
        "http://127.0.0.1:4096" + path,
        data=json.dumps(body).encode() if body else None, method=m)
    req.add_header("Authorization", auth)
    if body: req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=t) as r:
        return json.loads(r.read())
sid = call("POST", "/session", {"title": "Prueba de modelo"})["id"]
try:
    r = call("POST", f"/session/{sid}/message",
             {"model": {"providerID": proveedor, "modelID": modelo},
              "parts": [{"type": "text", "text": "Responde solo: OK"}]})
    txt = " ".join(p.get("text", "") for p in r.get("parts", [])
                   if p.get("type") == "text").strip()
    print("   respuesta del modelo:", (txt or "(vacía)")[:60])
    if not txt:
        raise SystemExit("✗ el modelo no devolvió texto")
finally:
    try: call("DELETE", f"/session/{sid}")
    except Exception: pass
PY
[ $? -eq 0 ] || { echo "✗ el modelo no respondió"; exit 1; }

echo "✓ MODELO CONFIGURADO: $PROVEEDOR/$MODELO"
