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
import argparse, base64, html, json, os, re, shutil, subprocess, sys, unicodedata

# Rutas relativas al propio script -> funciona en cualquier PC y en el VPS.
def _base_proyecto():
    """Carpeta del proyecto, sea cual sea desde donde se ejecute."""
    env = os.environ.get("MA_BASE")
    if env:
        return env
    aqui = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    if os.path.isdir(f"{aqui}/02_DEMO"):
        return aqui
    # instalado en /usr/local/bin: usar la copia del proyecto del servidor
    for candidato in ("/home/personalamd/Documentos/Default Project", "/opt/marketattack"):
        if os.path.isdir(f"{candidato}/02_DEMO"):
            return candidato
    return aqui


BASE_PROY = _base_proyecto()
MOTOR = f"{BASE_PROY}/02_DEMO"
WEB = os.environ.get("MA_WEB", "/var/www/marketattack")
CLIENTES = f"{WEB}/clientes"
SCRIPTS = f"{BASE_PROY}/scripts"

# Dominio público con el que se comparten la tienda y el QR.
# Se puede cambiar sin tocar el código:  MA_URL_BASE="https://midominio.com" ...
URL_BASE = (os.environ.get("MA_URL_BASE") or "https://marketattack.duckdns.org").rstrip("/")


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


def construir_autocontenida(demo_dir):
    """Reconstruye assets/tienda_autocontenida.html a partir de las partes."""
    a = f"{demo_dir}/assets"
    html_ = open(f"{demo_dir}/tienda.html", encoding="utf-8").read()
    html_ = html_.replace('<link rel="stylesheet" href="assets/style.css">',
                          "<style>\n" + open(f"{a}/style.css", encoding="utf-8").read() + "\n</style>")
    # demo.js puede llevar versión (?v=...) para saltar la caché: se acepta igual
    html_ = re.sub(r'<script src="assets/demo\.js[^"]*"></script>',
                   lambda _: "<script>\n" + open(f"{a}/demo.js", encoding="utf-8").read() + "\n</script>",
                   html_)
    html_ = html_.replace('<script src="assets/carrito.js"></script>',
                          "<script>\n" + open(f"{a}/carrito.js", encoding="utf-8").read() + "\n</script>")
    # el ícono se incrusta para que el archivo funcione aunque se mueva de carpeta
    fav = f"{a}/favicon.png"
    if os.path.exists(fav):
        with open(fav, "rb") as fh:
            data = "data:image/png;base64," + base64.b64encode(fh.read()).decode()
        html_ = html_.replace('href="assets/favicon.png"', 'href="' + data + '"')
    open(f"{a}/tienda_autocontenida.html", "w", encoding="utf-8").write(html_)


def bloque_head(datos, base):
    """Etiquetas de vista previa (Open Graph / Twitter) + SEO (JSON-LD)."""
    e = html.escape
    nombre = datos["nombreComercial"]
    tagline = datos["marca"]["tagline"] or nombre
    info = datos["info"]
    img = f"{base}/assets/portada.png"
    url = f"{base}/tienda.html"
    lineas = [
        '<link rel="icon" type="image/png" href="assets/favicon.png">',
        '<link rel="manifest" href="manifest.webmanifest">',
        '<meta name="theme-color" content="#e63946">',
        f'<meta name="description" content="{e(tagline)}">',
        '<meta property="og:type" content="website">',
        '<meta property="og:site_name" content="MarketAttack">',
        f'<meta property="og:title" content="{e(nombre)}">',
        f'<meta property="og:description" content="{e(tagline)}">',
        f'<meta property="og:image" content="{e(img)}">',
        f'<meta property="og:url" content="{e(url)}">',
        '<meta name="twitter:card" content="summary_large_image">',
        f'<meta name="twitter:title" content="{e(nombre)}">',
        f'<meta name="twitter:description" content="{e(tagline)}">',
        f'<meta name="twitter:image" content="{e(img)}">',
    ]
    ld = {
        "@context": "https://schema.org",
        "@type": "LocalBusiness",
        "name": nombre,
        "description": tagline,
        "telephone": datos.get("whatsapp", ""),
        "image": img,
        "url": url,
    }
    if info.get("ubicacion"):
        ld["address"] = info["ubicacion"]
    if info.get("horario"):
        ld["openingHours"] = info["horario"]
    lineas.append('<script type="application/ld+json">'
                  + json.dumps(ld, ensure_ascii=False) + '</script>')
    return "\n".join(lineas)


def rellenar_head(texto, datos, base):
    """Sustituye el bloque entre <!--MA_HEAD:BEGIN--> y END por el del cliente."""
    ini = texto.find("<!--MA_HEAD:BEGIN-->")
    fin = texto.find("<!--MA_HEAD:END-->")
    if ini == -1 or fin == -1:
        return texto
    fin += len("<!--MA_HEAD:END-->")
    return texto[:ini] + bloque_head(datos, base) + texto[fin:]


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
    ap.add_argument("--url-base", default="",
                    help="Dominio público para link y QR (por defecto el del proyecto)")
    a = ap.parse_args()

    # El link público y el QR SIEMPRE apuntan al dominio (nunca a IP ni file://)
    url_base = (a.url_base or URL_BASE).rstrip("/")
    if not url_base.startswith(("http://", "https://")):
        raise SystemExit("ERROR: --url-base/MA_URL_BASE debe empezar por http:// o https://")

    s = slug(a.nombre)

    # ¿Se puede publicar en el webroot (VPS con nginx)? Si no, modo local.
    publica = False
    try:
        os.makedirs(CLIENTES, exist_ok=True)
        publica = os.access(CLIENTES, os.W_OK)
    except Exception:
        publica = False
    if publica:
        destino = f"{CLIENTES}/{s}"
    else:
        destino = f"{BASE_PROY}/05_CLIENTES/{s}"

    # dirección pública de la tienda (para la vista previa y el QR)
    # Siempre HTTPS/dominio: sirve igual si se genera en el VPS o en el PC.
    base = f"{url_base}/clientes/{s}"
    url = f"{base}/tienda.html"

    # 1) preparar estructura
    if os.path.exists(destino):
        shutil.rmtree(destino)
    os.makedirs(os.path.dirname(destino), exist_ok=True)
    shutil.copytree(MOTOR, destino)

    # 1b) borrar los artefactos de la demo (se regeneran para el cliente); si
    #     algo falla, es mejor que falten a que quede una imagen del ejemplo.
    for art in ("assets/portada.png", "assets/favicon.png", "assets/icono.png",
                "assets/menu.png", "assets/menu.pdf", "manifest.webmanifest", "qr.png",
                "README.md", "demo-server.sh", "encender_web.sh"):
        p = f"{destino}/{art}"
        if os.path.exists(p):
            os.remove(p)

    # 2) datos del cliente en el formato que la tienda realmente lee
    menu = []
    for m in a.menu:
        p = [x.strip() for x in m.split("|")]
        while len(p) < 3:
            p.append("")
        precio = p[1] or "0"
        solo_digitos = re.sub(r"[^\d]", "", precio)
        if solo_digitos:
            precio = "$" + f"{int(solo_digitos):,}".replace(",", ".")
        elif not precio.startswith("$"):
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

    # 3b) personalizar los HTML del motor (nombre, marcadores y vista previa)
    for html_file in (f"{destino}/tienda.html",
                      f"{destino}/assets/tienda_autocontenida.html"):
        if os.path.exists(html_file):
            h = open(html_file, encoding="utf-8").read()
            h = h.replace("{NOMBRE}", a.nombre)
            h = h.replace("{TAGLINE}", a.tagline or a.nombre)
            h = h.replace("Market Burger", a.nombre)
            h = rellenar_head(h, datos, base)
            open(html_file, "w", encoding="utf-8").write(h)

    # 3c) portada (vista previa al compartir) + ícono del sitio
    try:
        pg = subprocess.run([sys.executable, f"{SCRIPTS}/portada_tienda.py",
                             a.nombre, a.tagline or a.nombre,
                             f"{destino}/assets/portada.png",
                             f"{destino}/assets/favicon.png", a.ubicacion,
                             f"{destino}/assets/icono.png"],
                            capture_output=True, text=True, timeout=120)
        if pg.returncode != 0:
            print(f"AVISO_PORTADA={(pg.stderr or pg.stdout or 'sin detalle').strip()[:200]}")
    except Exception as e:
        print(f"AVISO_PORTADA={e}")

    # 3c-2) regenerar el archivo autocontenido (ya con portada e ícono)
    try:
        construir_autocontenida(destino)
    except Exception as e:
        print(f"AVISO_AUTOCONTENIDA={e}")

    # 3c-3) menú imprimible (PNG + PDF) para el negocio
    try:
        menu_png = f"{destino}/assets/menu.png"
        menu_pdf = f"{destino}/assets/menu.pdf"
        mm = [sys.executable, f"{SCRIPTS}/menu_tienda.py",
              "--nombre", a.nombre, "--salida", menu_png, "--pdf", menu_pdf,
              "--whatsapp", a.contacto or a.whatsapp, "--horario", a.horario,
              "--ubicacion", a.ubicacion, "--tagline", a.tagline or a.nombre]
        for m in menu:
            mm += ["--item", f"{m['nombre']}|{m['precio']}|{m['desc']}"]
        mn = subprocess.run(mm, capture_output=True, text=True, timeout=120)
        if mn.returncode != 0:
            print(f"AVISO_MENU={(mn.stderr or mn.stdout or 'sin detalle').strip()[:200]}")
    except Exception as e:
        print(f"AVISO_MENU={e}")

    # 3c-4) manifest: permite "Agregar a inicio" (se ve como una app)
    try:
        manifest = {
            "name": a.nombre,
            "short_name": a.nombre[:12],
            "start_url": "index.html",
            "scope": "./",
            "display": "standalone",
            "background_color": "#1d3557",
            "theme_color": "#e63946",
            "icons": [
                {"src": "assets/favicon.png", "sizes": "128x128", "type": "image/png"},
                {"src": "assets/icono.png", "sizes": "512x512", "type": "image/png"},
            ],
        }
        with open(f"{destino}/manifest.webmanifest", "w", encoding="utf-8") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"AVISO_MANIFEST={e}")

    # 3d) la carpeta del cliente debe mostrar SOLO su tienda:
    #     - index.html = la tienda (así /clientes/<slug>/ abre la tienda)
    #     - se eliminan las páginas de plataforma que no aplican al cliente
    if os.path.exists(f"{destino}/tienda.html"):
        shutil.copyfile(f"{destino}/tienda.html", f"{destino}/index.html")
    for extra in ("kit.html", "recuperar.html"):
        p = f"{destino}/{extra}"
        if os.path.exists(p):
            os.remove(p)

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
    qr_script = f"{SCRIPTS}/qr_tienda.py"
    if not os.path.exists(qr_script):
        qr_script = "/usr/local/bin/qr_tienda.py"
    q = subprocess.run([sys.executable, qr_script, url,
                        f"{destino}/qr.png", a.nombre.upper()[:22]],
                       capture_output=True, text=True, timeout=120)
    qr_ok = os.path.exists(f"{destino}/qr.png") and q.returncode == 0
    if not qr_ok:
        print(f"AVISO_QR={(q.stderr or q.stdout or 'sin detalle').strip()[:200]}")

    # 6) VERIFICACIÓN
    def pedir(u):
        """Devuelve (codigo_http, cuerpo_en_bytes). Siempre bytes, nunca texto."""
        p = subprocess.run(["curl", "-s", "-w", "\n%{http_code}", "--max-time", "12", u],
                           capture_output=True, timeout=30)
        cuerpo, _, cod = p.stdout.rpartition(b"\n")
        return cod.decode("utf-8", "ignore").strip(), cuerpo

    if publica:
        # verificación interna: no depende de la URL pública ni de internet
        rel = os.path.relpath(destino, WEB).replace(os.sep, "/")
        base_interno = f"http://127.0.0.1/{rel}"
        c_web, _ = pedir(f"{base_interno}/tienda.html")
        c_js, js = pedir(f"{base_interno}/assets/demo.js")
        c_qr, _ = pedir(f"{base_interno}/qr.png")
        txt = js.decode("utf-8", "ignore")
        con_datos = (f'"{s}"' in txt) and (a.nombre in txt)
        code = "200" if (c_web == "200" and c_js == "200" and c_qr == "200"
                         and con_datos and qr_ok) else f"FALLO({c_web}/{c_js}/{c_qr}/datos={con_datos})"
    else:
        # Modo local: verificamos los archivos del disco
        txt = open(f"{destino}/assets/demo.js", encoding="utf-8").read()
        con_datos = (f'"{s}"' in txt) and (a.nombre in txt)
        existe = all(os.path.exists(f"{destino}/{f}") for f in
                     ("tienda.html", "index.html", "manifest.webmanifest", "assets/demo.js",
                      "assets/carrito.js", "assets/tienda_autocontenida.html",
                      "assets/portada.png", "assets/favicon.png", "assets/icono.png", "assets/menu.png"))
        code = "LOCAL_OK" if (existe and con_datos and qr_ok) else f"LOCAL_FALLO(archivos={existe}/datos={con_datos}/qr={qr_ok})"

    # 7) permisos legibles por nginx
    subprocess.run(["chmod", "-R", "a+rX", destino], check=False)

    print(f"NOMBRE={a.nombre}")
    print(f"SLUG={s}")
    print(f"MODO={'VPS' if publica else 'LOCAL'}")
    print(f"LINK={url}")
    if publica:
        print(f"QR={url_base}/clientes/{s}/qr.png")
    else:
        print(f"QR={destino}/qr.png")
        print(f"QR_PUBLICO={url_base}/clientes/{s}/qr.png")
    print(f"URL_BASE={url_base}")
    print(f"FICHA={ficha}")
    print(f"VERIFICADO={code}")
    print(f"PRODUCTOS={len(menu)}")


if __name__ == "__main__":
    main()
