#!/usr/bin/env python3
"""
╔═══════════════════════════════════════════════════════════╗
║  PUENTE TELEGRAM → OPENCODE · MARKETATTACK                ║
║  Comandos directos + creación de tiendas de clientes      ║
╚═══════════════════════════════════════════════════════════╝
"""
import json, os, re, subprocess, sys, time, base64
import datetime, glob, html, unicodedata
import urllib.request, urllib.parse

CFG = "/etc/marketattack/telegram.conf"
API = "http://127.0.0.1:4096"
SESS_FILE = "/etc/marketattack/telegram_session"
DIARIO = "/home/personalamd/Documentos/Default Project"
IP = "157.137.203.223"
WEB = "https://marketattack.duckdns.org"

cfg = {}
for line in open(CFG):
    if "=" in line and not line.strip().startswith("#"):
        k, v = line.split("=", 1)
        cfg[k.strip()] = v.strip().strip('"')
TOKEN, CHAT = cfg.get("TELEGRAM_TOKEN", ""), cfg.get("TELEGRAM_CHAT_ID", "")
# Modelo que usa el bot para conversar. Se puede cambiar en telegram.conf:
#   MODELO_PROVEEDOR=groq
#   MODELO_ID=openai/gpt-oss-120b
MODELO = {
    "providerID": cfg.get("MODELO_PROVEEDOR", "groq"),
    "modelID": cfg.get("MODELO_ID", "openai/gpt-oss-120b"),
}
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


def agente(txt):
    """Manda el mensaje al agente de OpenCode con un límite de tiempo corto.
    Si el modelo falla o se demora, responde algo claro en vez de quedarse mudo."""
    tg("sendChatAction", chat_id=CHAT, action="typing")
    try:
        r = oc("POST", f"/session/{sesion()}/message",
               {"model": MODELO, "parts": [{"type": "text", "text": txt}]},
               timeout=150)
        s = "\n".join(p.get("text", "") for p in r.get("parts", [])
                      if p.get("type") == "text").strip()
        if s:
            return s
        return "✅ Recibido. No hubo texto de respuesta, pero el mensaje quedó guardado."
    except Exception as e:
        print("agente:", type(e).__name__, e)
        return ("⚠ <b>No pude responder con el agente ahora mismo.</b>\n\n"
                "El mensaje sí me llegó y quedó en la conversación.\n"
                "Puedes seguir usando los comandos directos:\n"
                "• <code>/estado</code> — cómo está todo\n"
                "• <code>/captura</code> — guardar datos de un cliente\n"
                "• <code>/solicitud</code> — pedir la ficha al cliente\n"
                f"• <code>/ayuda</code> — todos los comandos\n\n"
                f"<i>Detalle técnico: {html.escape(type(e).__name__)}</i>")


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

📥 <b>Datos del cliente</b>
/solicitud — mensaje completo para pedir los datos
/solicitud corta — versión breve
/datos — guardar los datos de un solo mensaje
/captura — recibir por partes · /fin archiva · /cancelar descarta

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


# ═══════════════════════════════════════════════════════════
#  RECEPCIÓN DE DATOS DEL CLIENTE (Telegram)
#  Guarda lo que llegue en 05_CLIENTES/_entradas/ y deja un
#  JSON con los campos detectados. No publica nada solo.
# ═══════════════════════════════════════════════════════════
DIR_ENTRADAS = os.path.join(DIARIO, "05_CLIENTES", "_entradas")
DIR_ADJUNTOS = os.path.join(DIR_ENTRADAS, "adjuntos")
ARCHIVO_CAPTURA = "/var/lib/marketattack/captura_actual.json"
MAX_TEXTO = 30000
MAX_ADJUNTO = 20 * 1024 * 1024


SOLICITUD_COMPLETA = """¡Hola [NOMBRE]! 🙌 Bienvenido(a) a MARKETATTACK.

Para dejarte la tienda completa y vendiendo desde el primer día, cuéntame esto. Puedes responder en un solo mensaje o por partes. Si algo no lo tienes, escribe “no tengo”.

<b>1) NEGOCIO</b>
• Nombre exacto como debe aparecer:
• Nombre de quien atiende / dueño:
• ¿Qué vendes? (una frase):
• ¿Qué te hace diferente?:
• Historia o años del negocio (opcional):

<b>2) CONTACTO</b>
• WhatsApp para pedidos (con 57, sin + ni espacios):
• Teléfono alterno:
• Ciudad, barrio y dirección o punto de referencia:
• ¿Local físico visitable?:
• Instagram / Facebook / TikTok:
• Página web o catálogo actual:

<b>3) CATÁLOGO (lo más importante)</b>
• Lista de productos así: nombre | precio | descripción corta | categoría | disponible (sí/no)
  Ej: Arepa de queso | 8000 | Queso doble | Arepas | sí
• ¿Cuántos productos manejas en total?:
• ¿Hay agotados, por encargo o de temporada?:
• ¿Combos, promociones o precios por mayor?:
• ¿Cada cuánto cambian los precios?:

<b>4) PEDIDOS Y ENTREGA</b>
• Horario de atención (días y horas):
• ¿Cómo prefieres recibir pedidos? WhatsApp / llamada / ambos:
• ¿Domicilio? Zonas y costo:
• Tiempo promedio de preparación o entrega:
• ¿Pedido mínimo?:
• ¿Qué hacemos si un producto no está disponible?:
• ¿Pedidos para fechas especiales o por encargo?:

<b>5) PAGOS</b>
• Métodos: Nequi / Daviplata / transferencia / efectivo / tarjeta:
• Número o titular para pagos (solo si quieres mostrarlo):
• ¿Pago contra entrega?:
• ¿Pides anticipo? ¿En qué casos?:
• ¿Quién confirma el pago y cómo?:

<b>6) MARCA E IMAGEN</b>
• Logo (archivo o foto; si no tienes, lo hacemos):
• De 3 a 10 fotos de productos o del local:
• Colores o estilo que te gustan:
• Frase de bienvenida o promoción:
• ¿Algo que NO quieres que aparezca?:

<b>7) OPERACIÓN Y SOPORTE</b>
• ¿Quién responde los pedidos y en qué horario?:
• ¿Qué hacemos fuera de horario?:
• ¿Garantía, cambios o devoluciones?:
• ¿Qué datos necesitas del comprador? (nombre, dirección, referencia…):
• ¿Alguna regla especial? (zona, edad, mínimo…):

<b>8) LEGAL Y AUTORIZACIÓN</b>
• ¿Persona natural o empresa con RUT/NIT?:
• ¿Autorizas usar tu logo y fotos en la tienda y redes de MARKETATTACK?:
• ¿Autorizas que los pedidos lleguen a tu WhatsApp?:
• Nombre y documento de quien autoriza (opcional):

📎 Si tienes logo, fotos o lista de precios en PDF/Excel, envíalos por aquí.
✅ Con esto armo tu tienda, te mando el link para revisar y publicamos."""


SOLICITUD_CORTA = """¡Hola [NOMBRE]! 🙌 Para arrancar tu tienda necesito:

1. Nombre del negocio:
2. Tu nombre:
3. WhatsApp para pedidos (con 57, sin + ni espacios):
4. ¿Qué vendes? (una frase):
5. Horario de atención:
6. Ciudad / barrio / dirección:
7. Productos: nombre | precio | descripción (5 a 10 principales):
8. ¿Domicilio? Zonas y costo:
9. Métodos de pago que aceptas:
10. Logo y fotos (opcional, envíalos por aquí):

✅ Con esto te mando el link de tu tienda para revisar."""


CAMPOS_CONOCIDOS = {
    "nombre del negocio": "negocio", "nombre negocio": "negocio",
    "negocio": "negocio", "nombre comercial": "negocio",
    "nombre": "contacto", "tu nombre": "contacto",
    "nombre de quien atiende": "contacto", "dueno": "contacto",
    "propietario": "contacto", "contacto": "contacto",
    "whatsapp": "whatsapp", "whatsapp para pedidos": "whatsapp",
    "telefono": "telefono", "telefono alterno": "telefono",
    "ciudad": "ciudad", "barrio": "ciudad", "zona": "ciudad",
    "direccion": "direccion", "ubicacion": "ciudad",
    "horario": "horario", "horario de atencion": "horario",
    "que vendes": "descripcion", "descripcion": "descripcion",
    "que te hace diferente": "diferencial",
    "productos": "productos", "productos con precio": "productos",
    "menu": "productos", "catalogo": "productos",
    "domicilio": "domicilio", "metodos de pago": "pagos", "pagos": "pagos",
    "promocion": "promocion", "redes sociales": "redes", "redes": "redes",
    "logo": "logo", "pedido minimo": "pedido_minimo",
    "tiempo de entrega": "entrega", "tiempo promedio de entrega": "entrega",
}


def _ahora():
    return datetime.datetime.now()


def _texto_limpio(t):
    """Quita caracteres de control y limita el tamaño. No interpreta nada."""
    t = (t or "").replace("\x00", "")
    t = "".join(ch for ch in t if ch in "\n\t" or ord(ch) >= 32)
    return t.strip()[:MAX_TEXTO]


def _permiso(ruta):
    """Los archivos los crea root; se los dejo legibles al dueño del proyecto."""
    try:
        st = os.stat(DIARIO)
        os.chown(ruta, st.st_uid, st.st_gid)
        os.chmod(ruta, 0o640)
    except Exception:
        pass


def _preparar_dirs():
    for d in (os.path.join(DIARIO, "05_CLIENTES"), DIR_ENTRADAS, DIR_ADJUNTOS):
        os.makedirs(d, exist_ok=True)
        try:
            st = os.stat(DIARIO)
            os.chown(d, st.st_uid, st.st_gid)
            os.chmod(d, 0o750)
        except Exception:
            pass


def _norm_campo(s):
    s = unicodedata.normalize("NFKD", (s or "").lower())
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"^\s*\d+\s*[.)]?\s*", "", s)
    s = re.sub(r"[¿?*_]", "", s)
    return re.sub(r"\s+", " ", s).strip(" :.-")


def _extraer_campos(texto):
    """Detecta los campos de la ficha sin depender del orden."""
    campos = {}
    for linea in texto.splitlines():
        if ":" not in linea:
            continue
        k, v = linea.split(":", 1)
        nk = _norm_campo(k)
        v = v.strip()
        if not nk or not v or len(nk) > 80:
            continue
        for alias, clave in CAMPOS_CONOCIDOS.items():
            if nk == alias or nk.startswith(alias + " ") or nk.startswith(alias + "("):
                campos.setdefault(clave, v[:600])
                break
    return campos


def _parece_ficha(texto):
    """True solo si el mensaje trae varios campos de la ficha."""
    campos = _extraer_campos(texto)
    return len(campos) >= 4 and ("whatsapp" in campos or "productos" in campos
                                 or "negocio" in campos)


def _guardar_entrada(texto, origen="Telegram", etiqueta=""):
    texto = _texto_limpio(texto)
    if not texto:
        return None, {}
    _preparar_dirs()
    base = _ahora().strftime("cliente_%Y%m%d_%H%M%S")
    ruta = os.path.join(DIR_ENTRADAS, base + ".txt")
    n = 2
    while os.path.exists(ruta):
        ruta = os.path.join(DIR_ENTRADAS, f"{base}_{n}.txt")
        n += 1
    campos = _extraer_campos(texto)
    cab = ("# DATOS DE CLIENTE · MARKETATTACK\n"
           f"Fecha: {_ahora().strftime('%Y-%m-%d %H:%M:%S')}\n"
           f"Origen: {origen}\n"
           f"Etiqueta: {etiqueta or '-'}\n"
           + "=" * 52 + "\n\n")
    with open(ruta, "w", encoding="utf-8") as fh:
        fh.write(cab + texto + "\n")
    meta = {
        "fecha": _ahora().isoformat(timespec="seconds"),
        "origen": origen,
        "etiqueta": etiqueta,
        "archivo": os.path.basename(ruta),
        "campos": campos,
        "texto": texto,
    }
    ruta_json = ruta[:-4] + ".json"
    with open(ruta_json, "w", encoding="utf-8") as fh:
        json.dump(meta, fh, ensure_ascii=False, indent=2)
    _permiso(ruta)
    _permiso(ruta_json)
    return ruta, campos


def _confirmar_guardado(ruta, campos):
    nombres = {"negocio": "🏪 Negocio", "contacto": "👤 Contacto",
               "whatsapp": "📱 WhatsApp", "ciudad": "📍 Ciudad",
               "horario": "🕒 Horario", "pagos": "💳 Pagos",
               "productos": "🧾 Productos"}
    detalle = []
    for k, titulo in nombres.items():
        if campos.get(k):
            detalle.append(f"{titulo}: {html.escape(campos[k][:90])}")
    rel = os.path.relpath(ruta, DIARIO)
    extra = ("\n\n" + "\n".join(detalle)) if detalle else ""
    return (f"✅ <b>Datos guardados</b>\n\n"
            f"📂 <code>{rel}</code>{extra}\n\n"
            f"Quedó en la carpeta privada del proyecto. Si falta algo, "
            f"sigue enviándolo o usa <code>/captura</code>.")


def _leer_captura():
    try:
        with open(ARCHIVO_CAPTURA, encoding="utf-8") as fh:
            return json.load(fh)
    except Exception:
        return None


def _guardar_captura(d):
    os.makedirs(os.path.dirname(ARCHIVO_CAPTURA), exist_ok=True)
    with open(ARCHIVO_CAPTURA, "w", encoding="utf-8") as fh:
        json.dump(d, fh, ensure_ascii=False)


def _borrar_captura():
    try:
        os.remove(ARCHIVO_CAPTURA)
    except OSError:
        pass


def cmd_solicitud(arg=""):
    a = (arg or "").lower()
    if "corta" in a or "breve" in a or "rapida" in a:
        return SOLICITUD_CORTA
    return SOLICITUD_COMPLETA


def cmd_captura(arg=""):
    cap = _leer_captura()
    if cap:
        return ("⚠️ <b>Ya hay una captura abierta</b>\n\n"
                f"Mensajes guardados: {cap.get('mensajes', 0)}\n"
                "Sigue enviando datos o escribe <code>/fin</code> para archivar.")
    _preparar_dirs()
    base = _ahora().strftime("_borrador_%Y%m%d_%H%M%S")
    ruta = os.path.join(DIR_ENTRADAS, base + ".txt")
    open(ruta, "w", encoding="utf-8").close()
    _permiso(ruta)
    _guardar_captura({"archivo": ruta, "inicio": _ahora().isoformat(timespec="seconds"),
                      "mensajes": 0})
    return ("🎙 <b>CAPTURA ACTIVADA</b>\n\n"
            "Envíame los datos en uno o varios mensajes. Todo se guarda en "
            "un solo archivo.\n\n"
            "Cuando termines: <code>/fin</code>\n"
            "Para descartar: <code>/cancelar</code>")


def _agregar_captura(texto):
    cap = _leer_captura()
    if not cap:
        return None
    texto = _texto_limpio(texto)
    if not texto:
        return None
    n = int(cap.get("mensajes", 0)) + 1
    with open(cap["archivo"], "a", encoding="utf-8") as fh:
        fh.write(f"\n--- mensaje {n} · {_ahora().strftime('%Y-%m-%d %H:%M')} ---\n")
        fh.write(texto + "\n")
    cap["mensajes"] = n
    cap["actualizado"] = _ahora().isoformat(timespec="seconds")
    _guardar_captura(cap)
    return (f"📥 Guardado en el borrador ({n} mensaje{'s' if n != 1 else ''}).\n"
            "Sigue enviando o escribe <code>/fin</code> para archivar.")


def cmd_fin():
    cap = _leer_captura()
    if not cap:
        return ("No hay una captura abierta.\n\n"
                "Abre una con <code>/captura</code> o guarda un mensaje "
                "suelto con <code>/datos</code>.")
    ruta = cap.get("archivo", "")
    try:
        with open(ruta, encoding="utf-8") as fh:
            contenido = fh.read()
    except OSError:
        contenido = ""
    if len(contenido.strip()) < 5:
        try:
            os.remove(ruta)
        except OSError:
            pass
        _borrar_captura()
        return "🗑 La captura estaba vacía. No se guardó nada."
    # Guardar primero y solo borrar el borrador si el archivo final quedó bien.
    destino, campos = _guardar_entrada(contenido, "Telegram (captura)")
    if not destino:
        return "⚠ No pude guardar la captura. El borrador sigue abierto; prueba /fin otra vez."
    try:
        os.remove(ruta)
    except OSError:
        pass
    _borrar_captura()
    return _confirmar_guardado(destino, campos)


def cmd_cancelar():
    cap = _leer_captura()
    if not cap:
        return "No hay una captura abierta."
    try:
        os.remove(cap.get("archivo", ""))
    except OSError:
        pass
    _borrar_captura()
    return "🗑 Captura cancelada. No se guardó nada."


def cmd_datos(arg=""):
    a = (arg or "").strip()
    if not a:
        cap = _leer_captura()
        estado = (f"Hay una captura abierta ({cap.get('mensajes', 0)} mensajes). "
                  "Escribe <code>/fin</code> para archivarla."
                  if cap else "No hay captura abierta.")
        return ("📥 <b>GUARDAR DATOS DE UN CLIENTE</b>\n\n"
                "<b>En un solo mensaje:</b>\n"
                "<code>/datos\n"
                "Nombre del negocio: ...\n"
                "WhatsApp: ...\n"
                "Productos: ...</code>\n\n"
                "<b>Por partes (recomendado):</b>\n"
                "<code>/captura</code> → envía los datos → <code>/fin</code>\n\n"
                "También puedes pegar la ficha completa sin comando: si trae "
                "varios campos, la guardo automáticamente.\n\n"
                f"ℹ️ {estado}")
    low = a.lower()
    if low in ("fin", "terminar", "listo"):
        return cmd_fin()
    if low in ("cancelar", "borrar", "descartar"):
        return cmd_cancelar()
    if low in ("iniciar", "captura", "empezar"):
        return cmd_captura()
    destino, campos = _guardar_entrada(a, "Telegram (/datos)")
    if not destino:
        return "⚠ No había texto para guardar."
    return _confirmar_guardado(destino, campos)


def _guardar_adjunto(file_id, nombre_sugerido):
    """Descarga una foto o documento a la carpeta privada de entradas."""
    _preparar_dirs()
    try:
        d = tg("getFile", file_id=file_id)
        if not d or not d.get("ok"):
            return None
        ruta_tg = d["result"]["file_path"]
        nombre = os.path.basename(nombre_sugerido or ruta_tg)
        nombre = re.sub(r"[^A-Za-z0-9._-]+", "_", nombre)[:80] or "archivo"
        base = _ahora().strftime("%Y%m%d_%H%M%S_") + nombre
        destino = os.path.join(DIR_ADJUNTOS, base)
        url = f"https://api.telegram.org/file/bot{TOKEN}/{ruta_tg}"
        total = 0
        with urllib.request.urlopen(url, timeout=120) as r, open(destino, "wb") as fh:
            while True:
                trozo = r.read(65536)
                if not trozo:
                    break
                total += len(trozo)
                if total > MAX_ADJUNTO:
                    fh.close()
                    os.remove(destino)
                    return None
                fh.write(trozo)
        _permiso(destino)
        return destino
    except Exception as e:
        print("adjunto:", e)
        return None


def procesar_adjunto(msg):
    foto = msg.get("photo") or []
    doc = msg.get("document") or {}
    if foto:
        file_id = foto[-1].get("file_id")
        nombre = f"foto_{int(time.time())}.jpg"
    elif doc:
        file_id = doc.get("file_id")
        nombre = doc.get("file_name") or f"archivo_{int(time.time())}"
    else:
        return None
    if not file_id:
        return "⚠ No pude identificar el archivo."
    destino = _guardar_adjunto(file_id, nombre)
    if not destino:
        return "⚠ No pude guardar el archivo (puede pesar más de 20 MB)."
    leyenda = _texto_limpio(msg.get("caption") or "")
    if leyenda:
        try:
            with open(destino + ".txt", "w", encoding="utf-8") as fh:
                fh.write(leyenda + "\n")
            _permiso(destino + ".txt")
        except OSError:
            pass
    cap = _leer_captura()
    if cap:
        try:
            with open(cap["archivo"], "a", encoding="utf-8") as fh:
                fh.write(f"\n--- adjunto: {os.path.basename(destino)} ---\n")
                if leyenda:
                    fh.write(leyenda + "\n")
            cap["mensajes"] = int(cap.get("mensajes", 0)) + 1
            _guardar_captura(cap)
        except OSError:
            pass
    rel = os.path.relpath(destino, DIARIO)
    extra = ""
    if leyenda and not cap and _parece_ficha(leyenda):
        ruta_txt, campos = _guardar_entrada(
            leyenda, f"Telegram (adjunto: {os.path.basename(destino)})")
        if ruta_txt:
            extra = ("\n\nLos datos del texto también quedaron guardados:\n"
                     f"<code>{os.path.relpath(ruta_txt, DIARIO)}</code>")
    return (f"📎 <b>Archivo guardado</b>\n\n"
            f"📂 <code>{rel}</code>\n"
            + ("Se sumó al borrador de la captura.\n" if cap else "")
            + "Si es el logo o fotos del cliente, quedó en su carpeta privada."
            + extra)


def cmd_estado():
    web = sh("curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1/tienda.html").strip()
    ext = sh("curl -s -o /dev/null -w '%{http_code}' --max-time 10 " + WEB + "/tienda.html").strip()
    disco = sh("df -h / | tail -1 | awk '{print $4\" de \"$2\" libres\"}'").strip()
    ram = sh("free -m | awk '/Mem:/{print $7\" MB de \"$2\" libres\"}'").strip()
    nres = sh("ls -1 /var/backups/marketattack/completos/completo_*.tar.gz 2>/dev/null | wc -l").strip()
    nesp = sh("ls -1 /root/marketattack-rescate/completo_*.tar.gz 2>/dev/null | wc -l").strip()
    ult = sh("ls -1t /var/backups/marketattack/completos/completo_*.tar.gz 2>/dev/null | head -1 | xargs -r ls -lh | awk '{print $6\" \"$7\" \"$8}'").strip()
    nent = len(glob.glob(os.path.join(DIR_ENTRADAS, "cliente_*.txt")))
    srv = sh("systemctl is-active opencode").strip()
    puent = sh("systemctl is-active puente-telegram").strip()
    return (f"📊 <b>ESTADO</b>\n\n"
            f"Web servidor: <b>{web}</b> {'✅' if web == '200' else '❌'}\n"
            f"Web internet: <b>{ext}</b> {'✅' if ext == '200' else '❌'}\n"
            f"opencode: <b>{srv}</b> · puente: <b>{puent}</b>\n\n"
            f"💾 {disco}\n🧠 {ram}\n🗄 Respaldos: {nres} · espejo {nesp} · último {ult or '—'}\n"
            f"📥 Entradas de clientes: {nent}\n"
            f"🕒 Copia diaria 3:00 AM (sin PC)")


def cmd_clientes():
    d = sh("ls -1 /var/www/marketattack/clientes/ 2>/dev/null")
    if not d.strip():
        return "📂 <b>Clientes</b>\n\nTodavía no hay tiendas creadas.\nMándame <code>/cliente</code> y hacemos la primera."
    out = "📂 <b>Tiendas creadas</b>\n\n"
    for s in [x.strip() for x in d.splitlines() if x.strip()]:
        code = sh(f"curl -s -o /dev/null -w '%{{http_code}}' --max-time 8 http://127.0.0.1/clientes/{s}/tienda.html").strip()
        qr = sh(f"curl -s -o /dev/null -w '%{{http_code}}' --max-time 8 http://127.0.0.1/clientes/{s}/qr.png").strip()
        out += f"✅ <b>{s}</b> (web {code}, QR {qr})\n   {WEB}/clientes/{s}/tienda.html\n\n"
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
        m = re.match(r"^(\S+)(?:\s+(.*))?$", txt, re.S)
        c = (m.group(1) if m else txt).lower()
        arg = (m.group(2) or "").strip() if m else ""
        if c in ("/start", "/ayuda", "ayuda", "?"):
            return AYUDA
        if c in ("/solicitud", "/pedir", "/ficha"):
            return cmd_solicitud(arg)
        if c in ("/datos", "/guardar"):
            return cmd_datos(arg)
        if c == "/captura":
            return cmd_captura(arg)
        if c in ("/fin", "/terminar"):
            return cmd_fin()
        if c in ("/cancelar", "/descartar"):
            return cmd_cancelar()
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
            return (f"🔗 <b>ENLACES</b>\n\nDemo: {WEB}/tienda.html\n"
                    f"Portafolio: {WEB}/kit.html\nNetlify: https://marketattack.netlify.app/tienda.html")
        if c == "/qr":
            ruta = "/tmp/qr_actual.png"
            sh(f"python3 /usr/local/bin/qr_tienda.py '{WEB}/tienda.html' '{ruta}' 'MARKETATTACK'")
            if os.path.exists(ruta):
                tg_foto(ruta, f"QR de la tienda\n{WEB}/tienda.html")
            return
        if c == "/leer":
            return "📋 CONTEXTO.md\n\n" + open(f"{DIARIO}/CONTEXTO.md", errors="ignore").read()[:3400]
        if c == "/nueva":
            sid = oc("POST", "/session", {"title": "MarketAttack"})["id"]
            open(SESS_FILE, "w").write(sid)
            return "✅ Conversación nueva."
        # Si no es un comando conocido, trátalo como conversación natural con el agente
        return agente(txt)
    cap = _leer_captura()
    if cap:
        r = _agregar_captura(txt)
        if r:
            return r
    if _parece_ficha(txt):
        destino, campos = _guardar_entrada(txt, "Telegram (ficha automática)")
        if destino:
            return _confirmar_guardado(destino, campos)
    auto = intento_prospecto(txt)
    if auto:
        return auto
    return agente(txt)


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
            tiene_adj = bool(msg.get("photo") or msg.get("document"))
            if chat != int(CHAT) or (not t and not tiene_adj):
                continue
            print(">", (t or "[adjunto]")[:70])
            try:
                if (t and not tiene_adj and not t.startswith("/")
                        and not _leer_captura() and not _parece_ficha(t)):
                    tg("sendMessage", chat_id=CHAT, text="📥 Recibido, pensando…")
                res = procesar_adjunto(msg) if tiene_adj else procesar(t)
                if res:
                    enviar(res)
            except Exception as e:
                enviar(f"⚠ Error: {e}")
        time.sleep(1)


if __name__ == "__main__":
    main()
