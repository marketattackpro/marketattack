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
