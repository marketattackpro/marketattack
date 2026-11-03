#!/usr/bin/env python3
"""
╔═══════════════════════════════════════════════════════════╗
║  MARKETATTACK · Imagen de portada + ícono (favicon)        ║
║  Genera una tarjeta 1200x630 (para la vista previa al       ║
║  compartir el link) y un favicon 128x128. Sin internet.    ║
╚═══════════════════════════════════════════════════════════╝
Uso:
  portada_tienda.py "<nombre>" "<tagline>" <portada.png> [favicon.png] [<zona>]
"""
import os, sys, textwrap

from PIL import Image, ImageDraw, ImageFont

AZUL = (29, 53, 87)      # #1d3557
AZUL_OSC = (20, 33, 61)  # #14213d
ROJO = (230, 57, 70)     # #e63946
CLARO = (168, 218, 220)  # #a8dadc
BLANCO = (245, 247, 250)
GRIS = (150, 165, 180)

FUENTES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
]
FUENTE_NORMAL = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
]


def _f(candidatos, tam):
    for ruta in candidatos:
        if os.path.exists(ruta):
            try:
                return ImageFont.truetype(ruta, tam)
            except Exception:
                pass
    return ImageFont.load_default()


def _envolver(draw, texto, font, ancho_max):
    """Envuelve el texto en varias líneas midiendo el ancho real."""
    palabras, lineas, actual = texto.split(), [], ""
    for p in palabras:
        prueba = (actual + " " + p).strip()
        if draw.textlength(prueba, font=font) <= ancho_max or not actual:
            actual = prueba
        else:
            lineas.append(actual)
            actual = p
    if actual:
        lineas.append(actual)
    return lineas


def _tam_para(draw, texto, ancho_max, alto_max, tam_max, tam_min, candidatos):
    """Baja el tamaño de fuente hasta que el texto envuelto quepa."""
    for tam in range(tam_max, tam_min - 1, -2):
        f = _f(candidatos, tam)
        lineas = _envolver(draw, texto, f, ancho_max)
        h = len(lineas) * (tam + 8)
        if h <= alto_max:
            return f, lineas, tam
    f = _f(candidatos, tam_min)
    return f, _envolver(draw, texto, f, ancho_max), tam_min


def portada(nombre, tagline, salida, zona=""):
    W, H = 1200, 630
    img = Image.new("RGB", (W, H), AZUL_OSC)
    d = ImageDraw.Draw(img)

    # degradado vertical suave
    for y in range(H):
        t = y / H
        r = int(AZUL[0] + (AZUL_OSC[0] - AZUL[0]) * t)
        g = int(AZUL[1] + (AZUL_OSC[1] - AZUL[1]) * t)
        b = int(AZUL[2] + (AZUL_OSC[2] - AZUL[2]) * t)
        d.line([(0, y), (W, y)], fill=(r, g, b))

    # adornos
    d.ellipse([W - 320, -160, W + 120, 280], fill=(35, 66, 105))
    d.ellipse([-140, H - 200, 220, H + 160], fill=(35, 66, 105))
    d.rectangle([0, 0, W, 14], fill=ROJO)

    # marca
    d.text((70, 46), "MARKETATTACK", font=_f(FUENTES, 30), fill=CLARO)

    # título (auto-ajuste)
    f_tit, lineas, _ = _tam_para(d, nombre, 1050, 250, 100, 46, FUENTES)
    y = 150
    for ln in lineas[:3]:
        d.text((70, y), ln, font=f_tit, fill=BLANCO)
        y += f_tit.size + 12

    # tagline
    if tagline:
        f_t, lin_t, _ = _tam_para(d, tagline, 1000, 120, 42, 26, FUENTE_NORMAL)
        y += 10
        for ln in lin_t[:2]:
            d.text((70, y), ln, font=f_t, fill=CLARO)
            y += f_t.size + 6

    # pie: pastilla "Pide por WhatsApp"
    pill = _f(FUENTES, 30)
    txt = "Pide por WhatsApp"
    tw = d.textlength(txt, font=pill)
    px, py, ph = 70, H - 96, 54
    d.rounded_rectangle([px, py, px + tw + 60, py + ph], radius=27, fill=ROJO)
    d.text((px + 30, py + 10), txt, font=pill, fill=BLANCO)

    if zona:
        d.text((px + tw + 90, py + 14), zona[:60], font=_f(FUENTE_NORMAL, 26), fill=GRIS)

    img.save(salida, "PNG", optimize=True)
    return salida


def icono(nombre, salida, S=128):
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    radio = max(8, S // 5)
    d.rounded_rectangle([0, 0, S, S], radius=radio, fill=ROJO)
    letra = (nombre.strip()[:1] or "M").upper()
    f = _f(FUENTES, int(S * 0.62))
    bb = d.textbbox((0, 0), letra, font=f)
    d.text(((S - (bb[2] - bb[0])) / 2 - bb[0],
            (S - (bb[3] - bb[1])) / 2 - bb[1]), letra, font=f, fill=BLANCO)
    img.save(salida, "PNG", optimize=True)
    return salida


def main():
    if len(sys.argv) < 4:
        print("Uso: portada_tienda.py <nombre> <tagline> <portada.png> [favicon.png] [zona] [icono512.png]")
        raise SystemExit(2)
    nombre = sys.argv[1]
    tagline = sys.argv[2]
    salida = sys.argv[3]
    fav = sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] else None
    zona = sys.argv[5] if len(sys.argv) > 5 else ""
    icon512 = sys.argv[6] if len(sys.argv) > 6 and sys.argv[6] else None
    os.makedirs(os.path.dirname(os.path.abspath(salida)), exist_ok=True)
    portada(nombre, tagline, salida, zona)
    if fav:
        icono(nombre, fav, 128)
    if icon512:
        icono(nombre, icon512, 512)
    print(f"PORTADA_OK={salida}" + (f" FAVICON_OK={fav}" if fav else "")
          + (f" ICONO_OK={icon512}" if icon512 else ""))


if __name__ == "__main__":
    main()
